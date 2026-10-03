// DSFH Residency Portal — Edge Function: external-vote
//
// Receives ONE Stars (Best Resident) vote from a nurse or a consultant. They have no portal
// account; they vote on a Google Form, and an Apps Script on the form's response sheet posts
// each response here.
//
// WHO IS CALLING is settled by the secret, never by anything in the body: the nurses' sheet
// holds EXTERNAL_VOTE_SECRET_NURSE, the consultants' sheet holds EXTERNAL_VOTE_SECRET_CONSULTANT.
// A leaked nurses' script therefore cannot cast a vote as a consultant. The source column in the
// database comes from which secret matched.
//
// WHICH QUARTER is the one whose voting is open right now (best_resident_winners.voting_open,
// not announced, deadline not passed). When none is open the vote is refused with 409; the sheet
// keeps the row and the script's syncAll() can send it again once the PD opens voting.
//
// WHO THEY VOTED FOR is matched to residents.name, ignoring case, "Dr." and spacing. A name that
// matches nobody, or more than one resident, is refused with 422 and the reason, never guessed.
//
// One vote per person per quarter: the same name again replaces the earlier vote.
//
// Body:    { "name": "Dr. Someone", "senior": "Dr. Omar H", "junior": "Dr. Ibtihal",
//            "submittedAt": "2026-10-03T18:20:00Z" }       (submittedAt optional)
// Header:  x-vote-secret: <secret>
//
// Deploy:  supabase functions deploy external-vote --no-verify-jwt
//          (config.toml pins verify_jwt=false: Apps Script sends no Supabase JWT.)
// Secrets: supabase secrets set EXTERNAL_VOTE_SECRET_NURSE=... EXTERNAL_VOTE_SECRET_CONSULTANT=...
// Never pass --prune: it deletes any function not present locally.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

function json(obj: unknown, status = 200) {
  return new Response(JSON.stringify(obj), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

// Constant-time comparison, so response time says nothing about how much of a guess was right.
function same(a: string, b: string) {
  if (!a || !b || a.length !== b.length) return false;
  let d = 0;
  for (let i = 0; i < a.length; i++) d |= a.charCodeAt(i) ^ b.charCodeAt(i);
  return d === 0;
}

// How the nurses' form spells a resident, where it is not how the portal does. Keys and values are
// already normalised (see norm). Add a line here when a form shows a name the function refuses.
const ALIASES: Record<string, string> = {
  "omar": "omar h",                         // the only R3 Omar; Omar B is an R4
  "shifaa": "shifa",
  "safaa": "safa",
  "abdulraheem": "abdulrahim",
  "abdullah farid": "farid",
  "abdullah bayazeed": "bayazeed",
  "khalaf": "moh khalaf",
};

// "Dr.  Omar  H (R3)" -> "omar h"
function norm(s: unknown) {
  const k = String(s ?? "")
    .toLowerCase()
    .replace(/\(\s*r\s*\d\s*\)/g, " ")   // a level written after the name
    .replace(/\bdr\b\.?/g, " ")
    .replace(/[^\p{L}\p{N}]+/gu, " ")
    .trim();
  return ALIASES[k] ?? k;
}

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") return json({ error: "POST only" }, 405);

  const given = req.headers.get("x-vote-secret") ?? "";
  const nurse = Deno.env.get("EXTERNAL_VOTE_SECRET_NURSE") ?? "";
  const consultant = Deno.env.get("EXTERNAL_VOTE_SECRET_CONSULTANT") ?? "";
  const source = same(given, nurse) ? "nurse" : same(given, consultant) ? "consultant" : null;
  if (!source) return json({ error: "Not allowed" }, 401);

  let body: Record<string, unknown>;
  try { body = await req.json(); } catch { return json({ error: "Body must be JSON" }, 400); }

  const voterName = String(body.name ?? "").trim().slice(0, 120);
  const voterKey = norm(voterName);
  if (!voterKey) return json({ error: "The voter's name is missing" }, 422);

  const sb = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  // The quarter being voted on.
  const { data: open, error: openErr } = await sb
    .from("best_resident_winners")
    .select("academic_year,quarter,voting_deadline")
    .eq("voting_open", true)
    .eq("announced", false)
    .order("academic_year", { ascending: false })
    .order("quarter", { ascending: false });
  if (openErr) return json({ error: "Could not read the voting status" }, 500);
  const now = Date.now();
  const period = (open ?? []).find((r) => !r.voting_deadline || new Date(r.voting_deadline).getTime() > now);
  if (!period) return json({ error: "Voting is not open" }, 409);

  // Names -> resident ids.
  const { data: res, error: resErr } = await sb.from("residents").select("id,name");
  if (resErr) return json({ error: "Could not read the residents" }, 500);
  const pick = (label: string, typed: unknown) => {
    const k = norm(typed);
    if (!k) return { err: `${label} is missing` };
    const hits = (res ?? []).filter((r) => norm(r.name) === k);
    if (hits.length === 1) return { id: hits[0].id as number };
    return { err: hits.length ? `${label} "${typed}" matches more than one resident` : `${label} "${typed}" matches no resident` };
  };
  const s = pick("Senior", body.senior);
  const j = pick("Junior", body.junior);
  if ("err" in s) return json({ error: s.err }, 422);
  if ("err" in j) return json({ error: j.err }, 422);

  const at = body.submittedAt ? new Date(String(body.submittedAt)) : new Date();
  const { error: upErr } = await sb.from("best_resident_external_votes").upsert({
    source,
    voter_name: voterName,
    voter_key: voterKey,
    academic_year: period.academic_year,
    quarter: period.quarter,
    voted_senior_id: s.id,
    voted_junior_id: j.id,
    submitted_at: isNaN(at.getTime()) ? new Date().toISOString() : at.toISOString(),
  }, { onConflict: "source,voter_key,academic_year,quarter" });
  if (upErr) return json({ error: "Could not save the vote" }, 500);

  return json({ ok: true, source, academic_year: period.academic_year, quarter: period.quarter });
});
