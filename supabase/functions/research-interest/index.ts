// DSFH Residency Portal — Edge Function: research-interest
//
// Receives ONE response to the Research Committee's Google Form ("IM Residents Research Committee —
// Registration & Interest Survey"). An Apps Script bound to the form posts each response here; the
// portal shows them in Research > Residents and interests.
//
// WHO IS CALLING is settled by the secret in the x-form-secret header (RESEARCH_FORM_SECRET).
//
// WHICH RESIDENT: the form asks for a FULL name and the portal mostly holds a short one ("Dr. Lamar",
// "Dr. Omar H"), so the match runs in tiers, stopping at the first tier that points at exactly one
// resident (see matchResident): the Gmail address against the account's contact e-mail; the whole
// name; every word of the portal's name found among the typed words (a single letter such as the
// "H" of "Omar H" matches a typed word starting with it); the same again with spelling loosened
// (Ghufran / Ghofran, Shifa / Shifaa). When a tier finds several, the level typed on the form
// decides, and if it cannot the answer is left unlinked for a committee lead to link by hand in the
// portal. A hand-made link is never overwritten by a resend.
//
// The questions are recognised by their wording, not their position, so the committee can reorder
// the form or add questions without breaking this. A question that is not recognised is kept under
// answers.other with its own title.
//
// Body:   { "responseId": "…", "submittedAt": "2026-11-15T09:00:00Z",
//           "answers": [ { "title": "Full Name", "answer": "…" }, … ] }   (answer: text or list)
// Header: x-form-secret: <secret>
//
// Deploy:  supabase functions deploy research-interest
//          (config.toml pins verify_jwt=false: Apps Script sends no Supabase JWT.)
// Secret:  supabase secrets set RESEARCH_FORM_SECRET=...
// Never pass --prune: it deletes any function not present locally.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

function json(obj: unknown, status = 200) {
  return new Response(JSON.stringify(obj), { status, headers: { "Content-Type": "application/json" } });
}

// Constant-time comparison, so response time says nothing about how much of a guess was right.
function same(a: string, b: string) {
  if (!a || !b || a.length !== b.length) return false;
  let d = 0;
  for (let i = 0; i < a.length; i++) d |= a.charCodeAt(i) ^ b.charCodeAt(i);
  return d === 0;
}

// "Dr.  Lamar  Wazira (R2)" -> "lamar wazira"
function norm(s: unknown) {
  return String(s ?? "")
    .toLowerCase()
    .replace(/\(\s*r\s*\d\s*\)/g, " ")
    .replace(/\bdr\b\.?/g, " ")
    .replace(/[^\p{L}\p{N}]+/gu, " ")
    .trim();
}

// Spelling loosened: vowels after the first letter dropped, doubled letters collapsed, so that
// transliterations of one Arabic name land on the same key ("ghufran"/"ghofran" -> "ghfrn").
function skel(w: string) {
  if (w.length <= 1) return w;
  return (w[0] + w.slice(1).replace(/[aeiouy]/g, "")).replace(/(.)\1+/g, "$1");
}

type Res = { id: number; name: string; level?: string | null };

// Returns the one resident the typed name points at, or null when none or more than one does.
function matchResident(all: Res[], typedName: unknown, typedLevel: unknown): number | null {
  const k = norm(typedName);
  if (!k) return null;
  const typed = k.split(" ");
  const lvl = (String(typedLevel ?? "").toUpperCase().match(/R\s*([1-5])/) || [])[1];
  // Every word of the portal's name must be found among the typed words. A one-letter word is an
  // initial: it matches any typed word after the first that starts with it.
  const covers = (r: Res, eq: (a: string, b: string) => boolean) => {
    const w = norm(r.name).split(" ").filter(Boolean);
    if (!w.length) return false;
    return w.every((x, i) => x.length === 1 && i > 0
      ? typed.slice(1).some((t) => t[0] === x)
      : typed.some((t) => eq(t, x)));
  };
  const tiers: ((r: Res) => boolean)[] = [
    (r) => norm(r.name) === k,
    (r) => covers(r, (a, b) => a === b),
    (r) => covers(r, (a, b) => skel(a) === skel(b)),
  ];
  for (const tier of tiers) {
    let hits = all.filter(tier);
    if (!hits.length) continue;
    if (hits.length > 1) {
      // "Omar H" is a closer match than "Omar" when both cover the typed name.
      const most = Math.max(...hits.map((r) => norm(r.name).split(" ").length));
      hits = hits.filter((r) => norm(r.name).split(" ").length === most);
    }
    if (hits.length > 1 && lvl) {
      const same = hits.filter((r) => String(r.level ?? "").toUpperCase() === "R" + lvl);
      if (same.length) hits = same;
    }
    return hits.length === 1 ? hits[0].id : null;   // several left: never guess
  }
  return null;
}

// Question wording -> the key the portal reads. First match wins, so the order matters where two
// questions share words ("second preferred" before "preferred").
const FIELDS: [RegExp, string][] = [
  [/full\s*name/i, "full_name"],
  [/resident\s*id/i, "resident_ref"],
  [/educational\s*level|level/i, "level_text"],
  [/phone|what'?s\s*(up|app)/i, "phone"],
  [/gmail|e-?mail/i, "gmail"],
  [/whatsapp\s*group|added to/i, "whatsapp_ok"],
  [/how many research projects|previously participated/i, "prior_projects"],
  [/peer-?reviewed|publications/i, "publications"],
  [/research tasks/i, "tasks"],
  [/first preferred/i, "pref1"],
  [/second preferred/i, "pref2"],
  [/third preferred/i, "pref3"],
  [/outside your preferred/i, "outside_ok"],
  [/statistical/i, "stats"],
  [/leadership experience/i, "leadership"],
  [/lectures|workshops/i, "lectures"],
  [/lead a resident research group|willing to lead/i, "lead_group"],
  [/how would you like to participate/i, "participate"],
  [/availability/i, "availability"],
  [/suggestions|ideas/i, "ideas"],
  [/comments|notes/i, "comments"],
];
const COLUMNS = ["full_name", "resident_ref", "level_text", "phone", "gmail", "whatsapp_ok"];

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") return json({ error: "POST only" }, 405);

  const given = req.headers.get("x-form-secret") ?? "";
  const secret = Deno.env.get("RESEARCH_FORM_SECRET") ?? "";
  if (!same(given, secret)) return json({ error: "Not allowed" }, 401);

  let body: Record<string, unknown>;
  try { body = await req.json(); } catch { return json({ error: "Body must be JSON" }, 400); }

  const responseKey = String(body.responseId ?? "").trim().slice(0, 200);
  if (!responseKey) return json({ error: "responseId is missing" }, 422);
  const list = Array.isArray(body.answers) ? body.answers as Record<string, unknown>[] : [];
  if (!list.length) return json({ error: "No answers in the response" }, 422);

  const cols: Record<string, string | null> = {};
  const answers: Record<string, unknown> = {};
  const other: Record<string, unknown> = {};
  for (const item of list) {
    const title = String(item?.title ?? "").trim();
    const raw = item?.answer;
    const value = Array.isArray(raw)
      ? raw.map((x) => String(x ?? "").trim()).filter(Boolean).slice(0, 40).map((x) => x.slice(0, 300))
      : String(raw ?? "").trim().slice(0, 4000);
    if (!title || (Array.isArray(value) ? !value.length : !value)) continue;
    const hit = FIELDS.find(([re]) => re.test(title));
    if (!hit) { other[title.slice(0, 200)] = value; continue; }
    const key = hit[1];
    if (COLUMNS.includes(key)) { if (cols[key] == null) cols[key] = Array.isArray(value) ? value.join(", ") : value; }
    else if (answers[key] === undefined) answers[key] = value;
  }
  if (Object.keys(other).length) answers.other = other;

  const sb = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);

  // A link made by hand in the portal stays, whatever name the resend carries.
  const { data: prior, error: priorErr } = await sb.from("research_interest")
    .select("resident_id,matched_by").eq("response_key", responseKey).maybeSingle();
  if (priorErr) return json({ error: "Could not read the earlier answer" }, 500);

  let residentId: number | null = null, matchedBy: string | null = null;
  if (prior && prior.matched_by === "manual") { residentId = prior.resident_id; matchedBy = "manual"; }
  else {
    const { data: res, error: resErr } = await sb.from("residents").select("id,name,level,active");
    if (resErr) return json({ error: "Could not read the residents" }, 500);
    const all = (res ?? []).filter((r) => r.active !== false) as Res[];
    // The Gmail address, when it is the contact e-mail of exactly one resident's account.
    const mail = String(cols.gmail ?? "").trim().toLowerCase();
    if (mail.includes("@")) {
      const { data: profs } = await sb.from("profiles").select("resident_id,contact_email").not("resident_id", "is", null);
      const own = (profs ?? []).filter((p) => String(p.contact_email ?? "").trim().toLowerCase() === mail);
      if (own.length === 1 && all.some((r) => r.id === own[0].resident_id)) residentId = own[0].resident_id as number;
    }
    if (residentId == null) residentId = matchResident(all, cols.full_name, cols.level_text);
    if (residentId != null) matchedBy = "name";
  }

  const at = body.submittedAt ? new Date(String(body.submittedAt)) : new Date();
  const { error: upErr } = await sb.from("research_interest").upsert({
    response_key: responseKey,
    submitted_at: isNaN(at.getTime()) ? new Date().toISOString() : at.toISOString(),
    full_name: cols.full_name ?? null,
    resident_ref: cols.resident_ref ?? null,
    level_text: cols.level_text ?? null,
    phone: cols.phone ?? null,
    gmail: cols.gmail ?? null,
    whatsapp_ok: cols.whatsapp_ok ?? null,
    answers,
    resident_id: residentId,
    matched_by: matchedBy,
    updated_at: new Date().toISOString(),
  }, { onConflict: "response_key" });
  if (upErr) return json({ error: "Could not save the answer: " + upErr.message }, 500);

  return json({ ok: true, linked: residentId != null });
});
