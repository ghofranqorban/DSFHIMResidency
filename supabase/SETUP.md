# Phase 0 setup steps

## 1. Create the Supabase project
1. Go to supabase.com, sign up / log in, click "New Project".
2. Pick any name/region, set a database password (save it somewhere — this is separate from resident passwords).
3. Wait ~2 min for the project to spin up.

## 2. Run the schema
1. In the Supabase dashboard, open **SQL Editor > New query**.
2. Paste the entire contents of [schema.sql](schema.sql) and click Run.
3. Confirm no errors — you should see the new tables under **Table Editor**.

## 3. Get your API keys
Go to **Project Settings > API**. You'll see:
- **Project URL** — send this to me.
- **anon public key** — send this to me too (this is the one that ships in the frontend; it's safe to share, RLS protects the data).
- **service_role key** — do **not** send this to me. Keep it secret; you'll use it once, locally, for the seed step below.

## 4. Seed the existing residents/mentors (run this yourself, not me)
This creates real login accounts for everyone currently in the hardcoded list, so keep the service role key local to your machine.

```bash
cd "/Users/drghof/Documents/Claude/Projects/Residents/supabase"
npm install @supabase/supabase-js
SUPABASE_URL="https://YOUR-PROJECT.supabase.co" \
SUPABASE_SERVICE_ROLE_KEY="YOUR-SERVICE-ROLE-KEY" \
node seed.mjs
```

This prints a CSV of `username,temporary_password,role` at the end — **save that output**, it's the only time the passwords are shown. That's what you'll relay to each resident/mentor (or just log in as `pd.director` yourself and reset individual passwords later once we build that screen).

## 5. Send me
- Project URL
- anon public key

Once I have those I'll wire the frontend to real login (Phase 1) and we can verify people can log in with their own credentials.
