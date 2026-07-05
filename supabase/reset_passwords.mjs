// Resets the password for every already-created @dsfh.local account and
// prints a fresh username/password CSV. Safe to re-run.
import { createClient } from '@supabase/supabase-js';
const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_ROLE_KEY);
const EMAIL_DOMAIN = 'dsfh.local';

function tempPassword() {
  return Math.random().toString(36).slice(2, 8) + Math.floor(Math.random() * 90 + 10);
}

const { data: usersPage, error: uerr } = await supabase.auth.admin.listUsers({ perPage: 200 });
if (uerr) throw uerr;

const target = usersPage.users.filter(u => u.email.endsWith('@' + EMAIL_DOMAIN));
const rows = [];
for (const u of target) {
  const username = u.email.replace('@' + EMAIL_DOMAIN, '');
  const pass = tempPassword();
  const { error } = await supabase.auth.admin.updateUserById(u.id, { password: pass });
  if (error) { console.error('FAILED', username, error.message); continue; }
  rows.push([username, pass]);
}

rows.sort((a, b) => a[0].localeCompare(b[0]));
console.log('\nusername,new_password');
for (const [u, p] of rows) console.log(`${u},${p}`);
console.log(`\nReset ${rows.length} account passwords.`);
