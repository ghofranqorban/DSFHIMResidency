// DSFH Residency Portal — Edge Function: admin-create-login
//
// Called from the Admin Panel's "Create Login" button. Runs on Supabase's
// servers (never in the browser), so it's the only place allowed to use the
// service_role key — the browser only ever sends the signed-in PD/Chief's own
// session token, never a secret.
//
// What it does, step by step:
// 1. Reads the token of whoever clicked the button.
// 2. Confirms that person's role is "pd" or "chief" (looked up server-side —
//    a resident or mentor calling this directly would be rejected).
// 3. Confirms the target resident/mentor doesn't already have a login.
// 4. Generates a random temporary password.
// 5. Creates the real Supabase Auth account (username@dsfh.local + password).
// 6. Creates their "profiles" row linking the login to the resident/mentor record.
// 7. Returns the username + temporary password ONCE, to show to the PD.
//
// Deploy: Supabase Dashboard > Edge Functions > Deploy a new function >
// name it exactly "admin-create-login" > paste this whole file > Deploy.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(obj: unknown, status = 200) {
  return new Response(JSON.stringify(obj), {
    status,
    headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
  });
}

function tempPassword() {
  return Math.random().toString(36).slice(2, 8) + Math.floor(Math.random() * 90 + 10);
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS_HEADERS });

  try {
    const authHeader = req.headers.get("Authorization") || "";
    const jwt = authHeader.replace(/^Bearer\s+/i, "");
    if (!jwt) return json({ error: "Missing auth token" }, 401);

    const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
    const SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const admin = createClient(SUPABASE_URL, SERVICE_KEY);

    // Who is calling?
    const { data: callerData, error: callerErr } = await admin.auth.getUser(jwt);
    if (callerErr || !callerData?.user) return json({ error: "Invalid or expired session" }, 401);

    const { data: callerProfile } = await admin
      .from("profiles")
      .select("role")
      .eq("id", callerData.user.id)
      .single();
    if (!callerProfile || !["pd", "chief"].includes(callerProfile.role)) {
      return json({ error: "Only the Program Director or Chief Resident can create logins." }, 403);
    }

    const body = await req.json().catch(() => ({}));
    const { type, recordId, username, displayName } = body as {
      type?: string; recordId?: number; username?: string; displayName?: string;
    };
    if (!type || !["resident", "consultant"].includes(type) || !recordId || !username) {
      return json({ error: "Missing or invalid fields." }, 400);
    }

    const linkCol = type === "resident" ? "resident_id" : "consultant_id";
    const { data: existing } = await admin
      .from("profiles")
      .select("id")
      .eq(linkCol, recordId)
      .maybeSingle();
    if (existing) return json({ error: "This account already has a login." }, 400);

    const email = username.trim().toLowerCase() + "@dsfh.local";
    const password = tempPassword();

    const { data: newUser, error: createErr } = await admin.auth.admin.createUser({
      email, password, email_confirm: true,
    });
    if (createErr || !newUser?.user) {
      return json({ error: createErr?.message || "Could not create the login." }, 400);
    }

    const role = type === "resident" ? "resident" : "consultant";
    const { error: profErr } = await admin.from("profiles").insert({
      id: newUser.user.id,
      username: username.trim(),
      role,
      display_name: displayName || username,
      resident_id: type === "resident" ? recordId : null,
      consultant_id: type === "consultant" ? recordId : null,
    });
    if (profErr) {
      await admin.auth.admin.deleteUser(newUser.user.id); // don't leave an orphaned auth account
      return json({ error: profErr.message }, 400);
    }

    return json({ username, password });
  } catch (e) {
    return json({ error: String(e) }, 500);
  }
});
