import { createClient } from '@supabase/supabase-js';
const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_ROLE_KEY);

const { data: usersPage, error: uerr } = await supabase.auth.admin.listUsers({ perPage: 200 });
if (uerr) throw uerr;
console.log(`Auth users: ${usersPage.users.length}`);
usersPage.users.forEach(u => console.log(' -', u.email, u.id));

for (const table of ['profiles', 'residents', 'consultants']) {
  const { count, error } = await supabase.from(table).select('*', { count: 'exact', head: true });
  if (error) console.log(table, 'ERROR', error.message);
  else console.log(table, 'rows:', count);
}
