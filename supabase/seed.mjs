// One-time seed script: migrates the hardcoded RESIDENTS/CONSULTANTS/MENTORS
// data from SFH_Residency_Portal.html into Supabase (Auth + tables).
//
// Usage:
//   1. npm install @supabase/supabase-js
//   2. SUPABASE_URL=... SUPABASE_SERVICE_ROLE_KEY=... node seed.mjs
//      (Service role key is found in Project Settings > API. Keep it secret —
//      never put it in frontend code, only run this script locally/once.)
//   3. The script prints a CSV of username -> temporary password at the end.
//      Save that output somewhere safe and relay credentials to each person;
//      it will NOT be shown again (Supabase doesn't let you re-read a password).

import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = process.env.SUPABASE_URL;
const SERVICE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;
if (!SUPABASE_URL || !SERVICE_KEY) {
  console.error('Set SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY env vars first.');
  process.exit(1);
}
const supabase = createClient(SUPABASE_URL, SERVICE_KEY);

const CURRENT_ACADEMIC_YEAR = 2025; // the 2025-2026 cycle, adjust if seeding at a different time
const YEAR_OFFSET = { R1: 0, R2: -1, R3: -2, R4: -3 };
const EMAIL_DOMAIN = 'dsfh.local';

const PD_CHIEF = [
  { user: 'pd.director', role: 'pd', name: 'Dr. Ghofran' },
  { user: 'chief.res', role: 'chief', name: 'Chief Resident' },
];

const CONSULTANTS = [
  { id: 101, name: 'Dr. Al-Ansari', user: 'consultant1' },
  { id: 102, name: 'Dr. Hamdan', user: 'consultant2' },
  { id: 103, name: 'Dr. Saleh', user: 'consultant3' },
  { id: 104, name: 'Dr. Zayed', user: 'consultant4' },
];

const RESIDENTS = [
  { id: 1, name: 'Dr. Harbi', user: 'harbi', level: 'R4', ph: 'HA' },
  { id: 2, name: 'Dr. Joharji', user: 'joharji', level: 'R4', ph: 'JO' },
  { id: 3, name: 'Dr. Bashanfar', user: 'bashanfar', level: 'R4', ph: 'BA' },
  { id: 4, name: 'Dr. Omar B', user: 'omarb', level: 'R4', ph: 'OB' },
  { id: 5, name: 'Dr. Zahra', user: 'zahra', level: 'R4', ph: 'ZA' },
  { id: 6, name: 'Dr. Yara', user: 'yara', level: 'R4', ph: 'YA' },
  { id: 7, name: 'Dr. Rafal', user: 'rafal', level: 'R4', ph: 'RA' },
  { id: 8, name: 'Dr. Abdulmoty', user: 'abdulmoty', level: 'R3', ph: 'AB' },
  { id: 9, name: 'Dr. Alhussain', user: 'alhussain', level: 'R3', ph: 'AL' },
  { id: 10, name: 'Dr. Omar H', user: 'omarh', level: 'R3', ph: 'OH' },
  { id: 11, name: 'Dr. Rowidh', user: 'rowidh', level: 'R3', ph: 'RO' },
  { id: 12, name: 'Dr. Nawaf', user: 'nawaf', level: 'R3', ph: 'NA' },
  { id: 13, name: 'Dr. Mansour', user: 'mansour', level: 'R3', ph: 'MA' },
  { id: 14, name: 'Dr. Raghda', user: 'raghda', level: 'R3', ph: 'RA' },
  { id: 15, name: 'Dr. Sarah', user: 'sarah', level: 'R3', ph: 'SA' },
  { id: 16, name: 'Dr. Rasha', user: 'rasha', level: 'R3', ph: 'RA' },
  { id: 17, name: 'Dr. Bayazeed', user: 'bayazeed', level: 'R2', ph: 'BA' },
  { id: 18, name: 'Dr. Nuha', user: 'nuha', level: 'R2', ph: 'NU' },
  { id: 19, name: 'Dr. Hamza', user: 'hamza', level: 'R2', ph: 'HA' },
  { id: 20, name: 'Dr. Bajubair', user: 'bajubair', level: 'R2', ph: 'BA' },
  { id: 21, name: 'Dr. Farid', user: 'farid', level: 'R2', ph: 'FA' },
  { id: 22, name: 'Dr. Deema', user: 'deema', level: 'R2', ph: 'DE' },
  { id: 23, name: 'Dr. Samah', user: 'samah', level: 'R2', ph: 'SA' },
  { id: 24, name: 'Dr. Khalid', user: 'khalid', level: 'R2', ph: 'KH' },
  { id: 25, name: 'Dr. Bakur', user: 'bakur', level: 'R2', ph: 'BA' },
  { id: 26, name: 'Dr. Shifa', user: 'shifa', level: 'R2', ph: 'SH' },
  { id: 27, name: 'Dr. Waad', user: 'waad', level: 'R2', ph: 'WA' },
  { id: 28, name: 'Dr. Batool', user: 'batool', level: 'R1', ph: 'BA' },
  { id: 29, name: 'Dr. Ghadeer', user: 'ghadeer', level: 'R1', ph: 'GH' },
  { id: 30, name: 'Dr. Ahmed', user: 'ahmed', level: 'R1', ph: 'AH' },
  { id: 31, name: 'Dr. Ibtihal', user: 'ibtihal', level: 'R1', ph: 'IB' },
  { id: 32, name: 'Dr. Abdulmajeed', user: 'abdulmajee', level: 'R1', ph: 'AB' },
  { id: 33, name: 'Dr. Safa', user: 'safa', level: 'R1', ph: 'SA' },
  { id: 34, name: 'Dr. Lamar', user: 'lamar', level: 'R1', ph: 'LA' },
  { id: 35, name: 'Dr. Norah', user: 'norah', level: 'R1', ph: 'NO' },
  { id: 36, name: 'Dr. Sumiah', user: 'sumiah', level: 'R1', ph: 'SU' },
  { id: 37, name: 'Dr. Ghufran', user: 'ghufran', level: 'R1', ph: 'GH' },
  { id: 38, name: 'Dr. Abdulrahim', user: 'abdulrahim', level: 'R1', ph: 'AB' },
  { id: 39, name: 'Dr. Moh. Khalaf', user: 'mohkhalaf', level: 'R1', ph: 'MK' },
  { id: 40, name: 'Dr. Boshra', user: 'boshra', level: 'R1', ph: 'BO' },
];

const MENTORS = { 1:101,2:101,3:101,4:101,5:101,6:101,7:101,8:101,9:101,10:101,
  11:102,12:102,13:102,14:102,15:102,16:102,17:102,18:102,19:102,20:102,
  21:103,22:103,23:103,24:103,25:103,26:103,27:103,28:103,29:103,30:103,
  31:104,32:104,33:104,34:104,35:104,36:104,37:104,38:104,39:104,40:104 };

function tempPassword() {
  return Math.random().toString(36).slice(2, 8) + Math.floor(Math.random() * 90 + 10);
}

async function createAuthUser(username, password) {
  const { data, error } = await supabase.auth.admin.createUser({
    email: `${username}@${EMAIL_DOMAIN}`,
    password,
    email_confirm: true,
  });
  if (error) throw new Error(`auth create failed for ${username}: ${error.message}`);
  return data.user.id;
}

async function main() {
  const credentials = [];

  // 1. PD + chief
  for (const p of PD_CHIEF) {
    const pass = tempPassword();
    const authId = await createAuthUser(p.user, pass);
    await supabase.from('profiles').insert({
      id: authId, username: p.user, role: p.role, display_name: p.name,
    });
    credentials.push([p.user, pass, p.role]);
  }

  // 2. Consultants (mentors)
  const consultantIdMap = {}; // old hardcoded id -> new DB id
  for (const c of CONSULTANTS) {
    const { data: row, error } = await supabase.from('consultants')
      .insert({ name: c.name, username: c.user }).select().single();
    if (error) throw error;
    consultantIdMap[c.id] = row.id;
    const pass = tempPassword();
    const authId = await createAuthUser(c.user, pass);
    await supabase.from('profiles').insert({
      id: authId, username: c.user, role: 'consultant', display_name: c.name, consultant_id: row.id,
    });
    credentials.push([c.user, pass, 'consultant']);
  }

  // 3. Residents
  for (const r of RESIDENTS) {
    const mentorOldId = MENTORS[r.id];
    const mentorNewId = mentorOldId ? consultantIdMap[mentorOldId] : null;
    const yearStarted = CURRENT_ACADEMIC_YEAR + YEAR_OFFSET[r.level];
    const { data: row, error } = await supabase.from('residents')
      .insert({
        name: r.name, username: r.user, level: r.level, photo_initials: r.ph,
        mentor_id: mentorNewId, year_started: yearStarted,
      }).select().single();
    if (error) throw error;
    const pass = tempPassword();
    const authId = await createAuthUser(r.user, pass);
    await supabase.from('profiles').insert({
      id: authId, username: r.user, role: 'resident', display_name: r.name, resident_id: row.id,
    });
    credentials.push([r.user, pass, 'resident']);
  }

  console.log('\nusername,temporary_password,role');
  for (const [u, p, role] of credentials) console.log(`${u},${p},${role}`);
  console.log(`\nSeeded ${credentials.length} accounts. Save the CSV above now — passwords are not recoverable later.`);
}

main().catch((e) => { console.error(e); process.exit(1); });
