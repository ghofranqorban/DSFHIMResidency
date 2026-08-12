# DSFH IM Residency Portal — Claude Session Context

> Read this file AND the memory files (`~/.claude/projects/.../memory/*.md`) at the start of every new session, before touching any code. This file is the living reference (schema, roles, gotchas, workflow) — kept short on purpose. Full session-by-session history lives in `SESSION_LOG_ARCHIVE.md`; only grep it when you need historical rationale for something specific, don't read it wholesale.

---

## Project Overview

A **single-page web app** for the Dr. Sulaiman Fakeeh Hospital Internal Medicine residency program. It manages residents, rotations, KPIs, attendance, leave, counseling, and mentor notes.

- **Frontend:** One HTML file with all JS/CSS inline — `SFH_Residency_Portal.html`
- **Netlify copy (auto-deployed):** `index.html` — always keep in sync with the main file
- **Backend:** Supabase (Postgres + Auth + Row Level Security)
- **Hosting:** GitHub Pages → `https://ghofranqorban.github.io/DSFHIMResidency/`
- **Repo:** `https://github.com/ghofranqorban/DSFHIMResidency`
- **Local path:** `/Users/drghof/Documents/Claude/Projects/Residents/`

---

## Tech Stack Rules

- **No build step, no npm, no React.** Pure JS in a single HTML file.
- **`el(tag, attrs, ...children)`** — custom DOM builder used everywhere. Never use innerHTML.
- **`set(stateObj)`** — merges into `STATE` and calls `render()`. This is how all UI updates work.
- **`render()`** — rebuilds the entire DOM from scratch on every state change. No diffing.
- **Supabase client:** `const sb = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY)`
- **After every change:** copy `SFH_Residency_Portal.html` → `index.html`, then commit and push to `main`.
- **`.nojekyll` file is in repo root** — do not remove it (prevents GitHub Pages Jekyll errors).

---

## User Roles

| Role | Access |
|---|---|
| `pd` | Full access to everything |
| `deputy_pd` | Same as PD except some admin actions |
| `chief` | Most PD views, no admin panel |
| `consultant` | Own assigned residents only |
| `resident` | Own data only; some residents have extra privileges |

RLS helper functions in Supabase: `is_pd_or_chief()`, `app_role()`, `app_resident_id()`, `app_consultant_id()`

---

## Key Global Data Structures

```js
RESIDENTS        // [{id, name, user, level, ph, yearStarted, chiefRole}]
CONSULTANTS      // [{id, name, user}]
MENTORS          // {resident_id: consultant_id}
FULL_ROTA        // {resident_id: {block_number: rotation_name}}
MM_SESSIONS      // [{id, block_number, session_date, topic, presenter_resident_id, moderator_resident_id}]
TEACH_SESSIONS   // [{id, block_number, session_date, topic, presenter_label}]
MM_ATT           // {block: {date: {resident_id: status}}}   status = P|L|A|E|O
MM_ATT_CMT       // {block: {date: {resident_id: comment}}}
TEACH_ATT        // same shape as MM_ATT
TEACH_ATT_CMT    // same shape as MM_ATT_CMT
QUIZZES          // [{id, title, max, published, sc: {resident_id: score}}]
KPI_SCORES       // {resident_id: {commScore, researchDone, qiDone, bonusPublished, bonusOral, bonusPoster, awardsHonors, volunteering}}
KPI_QUARTERLY    // {resident_id: {quarter: {research_milestone, research_achieved, improvement_area, improvement_achieved, ...}}}
KPI_PROPOSALS    // [{id, resident_id, field_key, quarter, note, proposed_by_role, status, ...}]
LEAVE_DATA       // {resident_id: {rota:[], manual:[], absences:[], requests:[]}}
LEAVE_PENDING_COUNT  // int
COUNSEL_CACHE    // {resident_id: [records] | null | undefined}
MENTOR_NOTES     // {resident_id: [notes]}
ANNOUNCEMENTS    // [{id, title, description, deadline_date, category, target_all, target_level, target_resident_id}]
ACCOUNT_PRIVS    // {profile_id: Set(privilege_key)}
PROMOTION_NEEDED // bool
QUIZZES_LOAD_ERR // string|null — set if quizzes table missing in Supabase
CHIEF_ELECTION   // {academic_year, nomination_start, nomination_end, voting_start, voting_end} | null
CHIEF_NOMINEES   // [{id, resident_id, academic_year, nominated_at}]
CHIEF_VOTES      // [{id, voter_profile_id, candidate_resident_id}] — PD sees all, resident sees own only (RLS)
R4_PREFS         // {resident_id: {elective1_block, elective1_subspecialty, elective1_location, elective2_*, clinic1_block, clinic2_block, status}}
R4_PREFS_STATUS  // {academic_year, is_open, opened_at, deadline} | null
```

---

## Supabase Tables

| Table | Purpose |
|---|---|
| `profiles` | Auth link, role, username, display_name |
| `residents` | Resident records (name, level, mentor_id, active) |
| `consultants` | Mentor records |
| `account_privileges` | Per-profile privilege flags |
| `mm_sessions` | Morning meeting schedule |
| `mm_attendance` | MM attendance per session per resident |
| `teaching_sessions` | Teaching session schedule |
| `teaching_attendance` | Teaching attendance |
| `rotations` | Full rota grid (resident_id, block_number, rotation_name) |
| `kpi_scores` | Yearly KPI fields (committee_score, research, QI, bonuses, awards_honors, volunteering) |
| `kpi_quarterly` | Per-resident per-quarter milestones + improvement areas ⚠️ needs migration |
| `kpi_proposals` | Achievement submissions pending PD approval ⚠️ needs migration |
| `quizzes` | Quiz metadata |
| `quiz_scores` | Per-resident quiz marks |
| `leave_records` | All leave types |
| `counseling` | Counseling records (countersign fields ⚠️ needs migration) |
| `mentor_notes` | Mentor observations |
| `announcements` | PD-set deadlines/tasks with targeting |
| `promotion_log` | Annual promotion history ⚠️ needs migration |

**Attendance status values:** `P` (Present) · `L` (Late) · `A` (Absent) · `E` (Excused) · `O` (On Leave)

---

## Features Built (Complete)

### Authentication & Accounts
- Supabase Auth with synthetic emails (`username@dsfh.local`)
- Username + password change in account modal
- Per-profile privilege system

### Rota
- Full rota grid — Excel import via SheetJS
- Block view, timeline view, full table view, rotation tracker

### Morning Meetings & Teaching
- Schedule management (add/edit/delete) — Add/Edit now opens as a **modal popup** (not inline), same `modal-overlay`/`modal-card` pattern as On-Call/Account modals
- **Draft/Publish workflow (17 Jul 2026):** new sessions default to draft (`published:false` DB default); block-level "Publish Block"/"Unpublish Block" toggle + status badge (`renderPublishControls()`) visible only to editors. SELECT RLS gates on `published OR is_pd_or_chief() OR has_priv(...)`. Requires `add_schedule_draft_publish.sql` (see migrations table).
- **MM row highlights:** all 6 built-in presets (Special, Night Team Case, Dr. Nahed, ACS, Grand Round, Journal Club) migrated into the `mm_highlights` table so every highlight (built-in + custom) is editable/deletable via the pencil/trash icons in the schedule form — previously only custom ones were editable.
- **Current Week highlight (17 Jul 2026):** whichever week's `session_date` range contains today gets a terracotta top/bottom border on its row group plus a small "Current Week" chip next to the week-number cell (Option B of 3 previewed designs). Computed via `currentWeekInBlock(blk)`, applied inside the shared `renderScheduleTable()` so both MM and Teaching get it automatically.
- **Schedule import — built, then removed (17 Jul 2026).** Tried three approaches in one session: (1) Excel/paste import matched columns by exact header name — broke on the real MM/Teaching Excel template, which labels the date column "Day" instead of "Date" (fixed once, via content-based date-column detection); (2) an AI-vision (Anthropic API) image import was built but never deployed, then accidentally shipped client-side wiring in a commit that wasn't reviewed closely enough — removed; (3) a free client-side OCR (Tesseract.js) replacement was built, had a `render()`-wipes-DOM bug (see Gotchas), fixed, then removed anyway as "too complicated." **End state: no in-app import feature exists.** Schedules are now entered by the user sending the source file/screenshot to Claude directly in chat, who reads it and inserts rows via direct Supabase calls (done successfully for the Aug 2026 MM schedule, Block 12). If asked to rebuild an import feature, get explicit fresh buy-in first — this was tried 3 ways and rejected each time.
- Attendance logging (P/L/A/E/O) with comment field
- MM overview table · Export to Excel
- **Excel export on all modules (6 Aug 2026):** "Export Excel" button on Rota (full table), MM Schedule (per block), Academic Day Schedule (per block), On-Call (per block), Quiz Marks (all published, with averages), and Leave Summary. All use SheetJS `XLSX.writeFile()`. Functions: `exportRota()`, `exportSchedule(type,blk)`, `exportOncall(blk)`, `exportQuizAll()`, `exportLeave()`.

### KPI Dashboard (rebuilt Jul 2026, weights overhauled Jul 2026)
**Central weight table:** `KPI_W` (~line 417) — all scoring below derives from this constant. **When changing `KPI_W`, grep for every consumer** — `calcKPI()`, `calcKPIQ()`, `renderKPI()`'s duplicate `yearlyRaw` calc, and the independent `kpiOngoingScore()` (Best Resident module) all hardcode/derive weights separately and have gone out of sync before (see Known Bugs/Gotchas + session log).

**3-tab structure per resident:**
- **📊 Ongoing (50%):** Quiz 15% · MM Att 15% · Teaching 15% · Presenter/Moderator 5% — all auto-tracked, **scoped to `CURRENT_ACADEMIC_YEAR` only** (MM/Teaching attendance and presenter/moderator sessions are filtered by academic_year before aggregating)
  - **Outside-rotation attendance (18 Jul 2026):** the `O` attendance status (electives, Cardiology, etc.) is excluded entirely from MM/Teaching attendance % — not counted for or against, same as an unmarked day. `E` (Excused) still counts as full credit. If a resident has zero non-`O` days recorded for the whole year, `calcKPI()` returns `mmPct`/`tPct` as `null` (shown as gray "N/A" everywhere, excluded from cohort averages/at-risk flags) instead of the old behavior of defaulting to 100%.
- **📆 Quarterly (informational, not scored):** Mentor sets Research Milestone + Area of Improvement per quarter as text. Anyone can submit "achieved" → PD approves. Resident can see (read-only).
- **🏆 Yearly (50%):** Committee 10% (PD scores 0–10) + 5 achievement cards: QI Project 10% · Research Publication 10% · Oral-or-Poster Presentation 10% (merged bucket — either counts, no double credit) · Awards/Honors 5% · Volunteering 5%

**Proposal/approval flow:** Resident, mentor, chief, or PD can submit any yearly achievement. PD entries are auto-approved. All others show as ⏳ Pending — PD sees inline Approve/Reject. Approved proposals update `kpi_scores` and `kpi_proposals`.

**Summary card** shows Ongoing score/50 + Quarterly quarter + Yearly score/50 as clickable tiles.

**All-residents table** adds Achievements column (X/5) with pending indicator.

`exportKpiPDF(res, k)` generates a 3-section print report (Ongoing · Yearly · Quarterly).

`renderProfileKPI` in admin panel shows compact version with link to full KPI tab.

**Best Resident Live Rankings detail modal:** clicking a resident row opens `renderBrDetailModal()` (`STATE.brDetailRid`), showing the same 4 Ongoing components plus vote count and the final KPI 50% + Votes 50% score — added so rankings can be sanity-checked against `calcKPI()`.

### Quiz Marks
- Add/edit/delete/publish quizzes · Bulk Excel import
- If `quizzes` table missing → shows red error banner with instructions (QUIZZES_LOAD_ERR)

### Annual Leave
- Rota-detected leave · Manual addition · Leave request flow (resident → PD approval)
- Pending count alert on PD home · Unapproved absences tracking

### Counseling
- Add/edit/delete · Countersign flow (resident acknowledges, locks record)
- ⚠️ Requires `supabase/add_counseling_countersign.sql`

### Mentor Notes
- Table view: Strength / Improvement / Interest columns
- Only visible to PD + writing mentor

### Calendar (.ics Download)
- Rotation blocks · Approved leave · MM duties · Deadlines

### Announcements / Deadlines
- PD creates with targeting (all/level/resident) + deadline
- Shown as alerts on resident home screen (next 30 days)
- **📢 Broadcast button** on PD/chief home screen — quick modal to send to all or by level

### Global Search
- Search bar in sidebar — searches residents, quizzes, MM sessions, teaching sessions
- Floating results overlay, click to navigate. Esc to close.
- State key: `STATE.searchQ`

### PD Overview Dashboard
- Summary cards · Full resident table · At-risk highlight · Filter/sort

### October Auto-Promotion
- Triggers Oct–Dec on PD login · Modal with level changes · Per-resident skip
- ⚠️ Requires `supabase/add_promotion_log.sql`

### AY Plan 26-27 Module (`leave_plan`)
- **Landing cards:** 4 cards — Suggested Leave, Suggested GIM Rotations, Chief Resident Election, R4 Rotation Preferences
- **Suggested Leave:** 2× 2-week leave periods, deadline countdown, over-cap backup ("Second Preference"), PD decision modal (approve/decline/assign), DB-backed deadline (`leave_plan_status`)
- **GIM Rotation Prefs:** block picker, open/close window (`gim_rota_status`), PD matrix overlay
- **Chief Resident Election (6 Aug 2026):** PD sets 4 datetime fields (nomination start/end, voting start/end) → auto-transitions phases. R2/R3 self-nominate during nomination window. All residents vote (single vote, confirmation dialog). Vote counts hidden until voting closes — PD sees results (count + %), residents see "PD will announce." Tables: `chief_election`, `chief_nominations`, `chief_votes`. State: `CHIEF_ELECTION`, `CHIEF_NOMINEES`, `CHIEF_VOTES`. Functions: `chiefPhase()`, `chiefPhaseLabel()`, `loadChiefElection()`, `saveChiefElection()`, `chiefNominate()`, `chiefWithdraw()`, `chiefVote()`. UI: `chiefSection()` inside `renderLeavePlan()`.
- **R4 Rotation Preferences (6 Aug 2026):** Current R3s (upcoming R4s) pick 2 Elective blocks (with subspecialty + location text fields) + 2 Clinic blocks (just block pick). All 4 must be different blocks. PD/chief/plan_rota open/close window (`r4_prefs_status`), see submission matrix. Save Draft / Submit flow. Tables: `r4_rota_prefs`, `r4_prefs_status`. State: `R4_PREFS`, `R4_PREFS_STATUS`, `STATE.r4e1Block/r4e1Sub/r4e1Loc/r4e2Block/r4e2Sub/r4e2Loc/r4c1Block/r4c2Block`. Functions: `r4PrefsIsOpen()`, `loadR4Prefs()`, `loadR4PrefsStatus()`, `r4PrefsOpenWindow()`, `r4PrefsCloseWindow()`, `saveR4Prefs()`. UI: `r4PrefsSection()` inside `renderLeavePlan()`.
- **"All Residents" tab:** PD matrix with leave dots + GIM tint + control panels for GIM/leave deadline/R4 prefs

### Admin Panel
- Residents: add/edit/archive/login · Mentors: add/edit/assign/login
- Accounts + privilege grid · Deadlines · Import Rota (Excel wizard)

---

## SQL Migrations (in `supabase/` folder)

| File | Status | Purpose |
|---|---|---|
| `fix_attendance_status_constraint.sql` | ✅ Run | Allow E and O statuses |
| `add_attendance_comments.sql` | ✅ Run | Add comment column to attendance tables |
| `fix_residents_attendance_rls.sql` | ✅ Run | RLS fix for privileged residents |
| `add_announcements.sql` | ✅ Run | Announcements/deadlines table |
| `add_counseling_countersign.sql` | ✅ Run | Countersign columns + RPC on counseling |
| `add_promotion_log.sql` | ✅ Partially run | promotion_log table exists (policy already existed error — table is present) |
| `add_kpi_quarterly_proposals.sql` | ✅ Partially run | kpi_quarterly + kpi_proposals tables exist (policy already existed error — tables are present) |
| `fix_attendance_rls_and_deputy_pd.sql` | ⛔ Do NOT run | Adds consultants to attendance write policy — not needed. Attendance committee = privileged residents only, already covered by `has_priv('edit_mm_attendance')` in the original migration_003 policy. |
| `add_oncall_resident_name.sql` | ✅ Run | Adds `resident_name text` column to `oncall_schedule` for free-text / outside-rotator entries. |
| `add_notifications.sql` | ✅ Run | In-app notification bell — `notifications` table with RLS (users see own only, any auth can insert) |
| `add_activity_log.sql` | ✅ Run | Audit trail — `activity_log` table, immutable (no UPDATE/DELETE policies), PD/chief/dio can read all |
| `add_leave_plan.sql` | ✅ Run (11 Jul, modified) | `leave_plan` table for AY 2026-27 planning. Original `write leave_plan` policy using `app_resident_id()` failed with `column "user_id" does not exist` — replaced with a direct `profiles.username = residents.username` lookup instead. |
| `fix_leave_plan_rls.sql` | ✅ Run (17 Jul) | Reverts `write leave_plan` policy from the fragile `profiles.username = residents.username` join back to `app_resident_id()` (same proven pattern as `counseling`/`leave_records`/`rotations`). Root cause of residents getting "violates row-level security policy" on Save Draft/Submit: the username-join breaks for any resident whose login username was changed after their resident record was created (`profiles.username` and `residents.username` no longer match, since editing login username doesn't touch `residents.username`). `app_resident_id()` uses the `profiles.resident_id` FK directly, so it's immune to username drift. |
| `fix_leave_records_rls.sql` | ✅ Run (17 Jul) | Original `leave_records` write policy (schema.sql) was `is_pd_or_chief()` only — residents could never insert their own leave request row, so every resident "Request Leave" submission failed with an RLS error. Opens INSERT for a resident's own pending `type='leave_request', approved=false` row only; UPDATE/DELETE (approve/reject) stay PD/chief-only. |
| `add_leave_plan_alt.sql` | ✅ Run (17 Jul) | Adds `first_leave_alt_key`/`second_leave_alt_key` to `leave_plan` for the backup-period "Suggestion" feature (over-cap picks get a named backup; PD matrix shows a red-ringed dot + tooltip). |
| `add_leave_plan_decision.sql` | ✅ Run (17 Jul) | Adds `first_leave_approved`/`second_leave_approved` boolean columns to `leave_plan`. Powers the PD decision modal (click a dot in the matrix → Approve / Decline (falls back to named backup, else reverts to draft) / Assign Period directly). Resident's own `saveLeavePlan()` resets both flags on every save (re-triggers PD review). |
| `add_gim_rota_prefs.sql` | ✅ Run (17 Jul) | `gim_rota_prefs` table for "Academic Year Plan 26-27" GIM rotation block-preference feature — fully wired and live. |
| `add_gim_rota_status.sql` | ✅ Run (17 Jul) | `gim_rota_status` table (`is_open`,`opened_at`,`deadline`) — backs the PD/`plan_rota` open/close control panel for the GIM window (`gimControlPanel()`), replacing the old hardcoded `GIM_OPEN` const. |
| `add_leave_plan_status.sql` | ✅ Run (17 Jul) | `leave_plan_status(academic_year pk, deadline)` — single source of truth for the Leave Plan deadline, replacing a hardcoded `LP_DEADLINE` Date duplicated in both client and the `ical` edge function. PD/deputy_pd/chief/`plan_rota` can edit it live from the "All Residents" tab. |
| `add_mm_highlights.sql` | ✅ Run (17 Jul) | Morning meeting highlights feature — table exists, has rows. |
| `fix_calendar_rls.sql` | ✅ Run (17 Jul) | Adds `set_my_calendar_token`/`set_my_calendar_prefs` security-definer RPCs so non-PD/chief residents can save their own calendar token/prefs (the `profiles_write` RLS policy only allowed pd/chief to write to `profiles` at all, even their own row). |
| `fix_leave_records_source_check.sql` | ✅ Run (confirmed 18 Jul 2026 via direct test insert/delete against Supabase) | Fixes `leave_records_source_check` blocking **all** leave requests (annual + educational) with "violates check constraint" — `submitLeaveRequest()`/`approveLeaveRequest()` insert `source:'resident'`/`'request'` but the constraint only allowed `rota_import`/`manual`. App code is correct; constraint was stale. |
| `add_schedule_draft_publish.sql` | ✅ Run (confirmed 18 Jul 2026 — `mm_sessions.published` column exists) | Adds `published boolean not null default false` to `mm_sessions`/`teaching_sessions`, updates SELECT RLS to `published OR is_pd_or_chief() OR has_priv(...)`, and backfills all *existing* rows to `published=true` (so nothing currently visible disappears on run). Publish/Unpublish buttons now actually restrict draft visibility. |
| `fix_kpi_evidence_storage_rls.sql` | ✅ Run (confirmed 18 Jul 2026 — logged in as a real resident account and successfully uploaded/cleaned up a test file via the exact storage path the app uses) | Fixes KPI achievement evidence file uploads failing with "new row violates row-level security policy" for every resident/mentor/chief/PD (reported by Dr. Lamar, 18 Jul 2026). Root cause: the `kpi-evidence` Storage bucket was created private (10 Jul 2026) but no RLS policies were ever added on `storage.objects` — only the service_role key could read/write it. Adds INSERT/SELECT/UPDATE policies scoped to `bucket_id = 'kpi-evidence'` for any authenticated user. |
| `fix_kpi_scores_read_rls.sql` | ✅ Run (confirmed 18 Jul 2026 — see below) | Fixes Performance Report leaderboard showing different rankings/percentages depending on who's logged in (reported 18 Jul 2026 — Deema saw a completely different top-5 than the PD view). Root cause: `kpi_scores` SELECT RLS (`add_kpi_scores.sql`) restricted reads to PD/chief/own-mentee/own-row only, but `calcKPI()` reads the globally-cached `KPI_SCORES` for every resident to build the cohort-wide leaderboard — so a resident's session only ever saw their own Committee Score + yearly bonus flags, and everyone else's silently defaulted to 0/false in that session's score math. Widens SELECT to all authenticated (write policy unchanged), same pattern as `rotations`/`mm_attendance`/`teaching_attendance`/`quiz_scores`.
| `add_ceo_role.sql` | ✅ Run (confirmed 27 Jul 2026 — profile insert with role='ceo' succeeded) | Adds `'ceo'` to the `profiles.role` check constraint, same pattern as `'dio'`. Backs Dr. Sohail Bajammal's (CEO) account — full PD-level access via `effectiveRole()`/`isPdRole()`, displayed as "CEO" badge. Run manually in the Supabase SQL Editor (no raw-SQL RPC exists for Claude to execute DDL directly). |
| `add_oncall_draft_publish.sql` | ✅ Run (confirmed 1 Aug 2026) | Adds `oncall_schedule.published` column + RLS select policy; existing rows backfilled to `published=true`. |
| `add_chief_election.sql` | ✅ Run (6 Aug 2026) | `chief_election` (PD configures nomination/voting windows), `chief_nominations` (R2/R3 self-nominate), `chief_votes` (one per voter, PD/chief read all, residents read own only). |
| `add_r4_rota_prefs.sql` | ✅ Run (6 Aug 2026) | `r4_rota_prefs` (2 elective blocks with subspecialty/location + 2 clinic blocks, per R3 resident) + `r4_prefs_status` (open/close window, same pattern as `gim_rota_status`). |

---

## Known Bugs / Gotchas — CRITICAL, read before every edit

- **CDN pinning:** Supabase JS pinned to `@2.39.0` — do NOT change. Newer versions break `window.supabase`.
- **async callbacks:** Any callback using `await` must be `async`. Missing it caused a site-wide crash (Jul 2026).
- **Single script block = total failure:** One JS syntax error anywhere blanks the entire page with no visible error. Always validate before committing (see below).
- **Curly/smart quotes in JS:** NEVER use `"` `"` `'` `'` inside JS strings or template expressions. They parse as separate tokens → "Unexpected string" crash. Use straight ASCII quotes only. This caused a blank-site incident Jul 2026.
- **Never build inline SVGs with `el("svg",...)`:** `el()` uses `document.createElement`, which is NOT namespace-aware — it silently produces a non-rendering element for `svg`/`path`/etc. This is why the sidebar Home icon was invisible for weeks with no error. Always add icons to `modIcon()`'s `D` map (uses `document.createElementNS`) and call `modIcon(id, size)` instead of hand-rolling SVG via `el()`.
- **`render()` rebuilds the entire DOM from scratch:** never mutate a form element's `.value`/content directly (e.g. `document.getElementById(id).value=...`) and then call `render()` — the freshly-rebuilt element has no memory of that mutation and the change is silently lost. Store the value in a module-level var and pass it back in as the element's rendered content instead (caused the "scanned OCR text disappears after the toast shows" bug, 17 Jul 2026).
- **New Supabase Storage buckets need RLS policies added manually:** creating a private bucket does NOT grant authenticated users any access — only the service_role key can read/write until explicit `storage.objects` INSERT/SELECT/UPDATE policies are added (same category of bug as the `profiles_write` RLS gap that broke calendar tokens). Caused KPI evidence file uploads to fail for every user from 10 Jul until fixed 18 Jul (`fix_kpi_evidence_storage_rls.sql`). If a new feature adds a Storage bucket, write the RLS policies in the same migration that creates it.
- **`KPI_W` has multiple independent consumers — grep all of them before changing weights:** `calcKPI()`/`calcKPIQ()` read it directly, but `renderKPI()` also has its own duplicate `yearlyRaw` calc, and `kpiOngoingScore()` (Best Resident module) is a fully separate function that used to hardcode its own weights instead of deriving from `KPI_W`. During the Jul 2026 weight overhaul (15/15/15/5/10/10/10/10/5/5), `kpiOngoingScore()` was missed in the first pass and kept using stale pre-overhaul weights — silently mis-scored every resident's Best Resident ranking (producing suspicious tied scores) until the user noticed and flagged it. `kpiOngoingScore()` now derives everything from `KPI_W` dynamically — do not re-hardcode it.
- **init() has try-catch:** So render() always runs even if data loading fails.
- **GitHub Actions:** Custom deploy at `.github/workflows/deploy.yml` retries 3×, `cancel-in-progress: true` (changed 6 Aug 2026 — was `false`, which caused new deploys to queue behind stuck runs indefinitely). Don't remove the workflow. The `workflow` scope was added to `gh auth` this session to allow pushing workflow file changes.
- **After every change:** `cp SFH_Residency_Portal.html index.html` then commit+push both.

---

## MANDATORY: JS Syntax Check Before Every Commit

```bash
cd "/Users/drghof/Documents/Claude/Projects/Residents"
rm -f /tmp/_portal_blk*.js && node -e "
const fs=require('fs');const html=fs.readFileSync('SFH_Residency_Portal.html','utf8');
const re=/<script([^>]*)>([\s\S]*?)<\/script>/g;let m,i=0,n=0;
while((m=re.exec(html))!==null){i++;
  if(/\bsrc=/.test(m[1])||!m[2].trim())continue;
  n++;fs.writeFileSync('/tmp/_portal_blk'+i+'.js',m[2]);
  console.log('inline block '+i+': '+m[2].split('\n').length+' lines');}
if(!n){console.error('ERROR: no inline script block found');process.exit(1);}
" && for f in /tmp/_portal_blk*.js; do node --check "$f" || exit 1; done && echo "✅ JS syntax OK"
```

If this fails → fix before committing. Never commit a broken state to main.

> **The old version of this check was silently broken (found 12 Aug 2026).** It hardcoded
> `if(i===3)break;` to grab the 3rd `<script>` tag, which was the inline block at the time.
> When the GSAP + ScrollTrigger CDN `<script src=...>` tags were added during the Performance
> Report redesign, block 3 became an *external* tag with an empty body — so the check wrote a
> **0-byte file** and `node --check` passed vacuously on every run. Verified by injecting a curly-quote
> bug: the old check reported "syntax OK", the new one caught it. The check now selects blocks by
> *absence of a `src` attribute* rather than by index, so adding more CDN tags can't break it again.
> It also hard-fails if no inline block is found, instead of passing on nothing.

---

## Features Pending (Build These Next)

### 1. ~~Cumulative KPI Page~~ ✅ Done (10 Jul 2026)
Built as "Training Record" (`cumulative_kpi`, pd/deputy_pd/chief). Year rows expand to 4-quarter milestone grid. See session log for details.

### 2. ~~KPI Page Redesign~~ ✅ Done (10 Jul 2026)
Hero band, floating tiles, underline tabs, no-box metric rows, achievement list rows — all Eventevia-styled. Quarterly tab + milestone cards also redesigned this session.

### 3. ~~Supabase Storage bucket~~ ✅ Done (10 Jul 2026)
`kpi-evidence` bucket created — private, signed URLs (not public as originally planned).

### 8. Historical KPI data (2024-25, 2023-24, 2022-23)
Still shows "Under Progress" on Performance Report. Phase 2 data-entry work, no ETA.

### 9. Master Rota Builder (planned, starting next week — ~11 Aug 2026)
PD builds the full 13-block rota inside the AY Plan module, with R4 prefs / GIM prefs / leave plan visible as constraints. Finalize in the planner, then "Push Live" when new AY starts → becomes the real `rotations` + `leave_records`.

### 10. October Auto-Promotion Enhancement
Add auto-archiving of graduating R4s (`active=false`) + creation of 15 placeholder R1 accounts (NR1-01 to NR1-15). The existing promotion modal already handles R1→R2, R2→R3, R3→R4 with per-resident skip.

### 4. ~~Quiz Persistence~~ ✅ Done (error banner added)
### 5. ~~KPI PDF Export~~ ✅ Done
### 6. ~~Global Search~~ ✅ Done
### 7. ~~Bulk Broadcast~~ ✅ Done

---

## Workflow for New Sessions

1. Read this file (`CLAUDE_CONTEXT.md`) and the memory files first — before anything else
2. Run JS syntax check (above) to confirm current state is valid
3. Read `SFH_Residency_Portal.html` around the relevant function before editing
4. Make changes to `SFH_Residency_Portal.html`
5. **After every code change:** run the JS syntax check → `cp SFH_Residency_Portal.html index.html` → commit and push both files:
   - Run JS syntax check again (above)
   - `cp SFH_Residency_Portal.html index.html`
   - `git add SFH_Residency_Portal.html index.html && git commit -m "..." && git push origin main`
6. GitHub Pages auto-deploys in ~1 min
7. **Update this file** if new features are added, SQL migrations run, or status changes

---

## Common Patterns

```js
// Add a new module/page:
// 1. Add to MODS array (with roles)
// 2. Add case to switch in render()
// 3. Write renderXxx() function

// Load data from Supabase:
const { data, error } = await sb.from("table").select("*").eq("field", value);

// Save/upsert:
await sb.from("table").upsert({...}, { onConflict: "unique_col" });

// Re-render after async:
await loadSomething();
render();

// Color helpers:
kpiColor(v) // v>=80 green, v>=60 amber, v<60 red (defined locally in functions that need it)

// Modal overlay pattern:
el("div",{cls:"modal-overlay",onClick:e=>{if(e.target===e.currentTarget)close();}},
  el("div",{cls:"modal-card",st:{width:"500px",maxWidth:"100%"}}, ...content...)
)
// Wire into render() before appendAccountModal(app):
if(STATE.showMyModal) app.appendChild(renderMyModal());

// KPI proposal flow:
// submitKpiProposal(resId, fieldKey, quarter|null, note|null)
// reviewProposal(proposalId, approve:bool)
// getApprovedFields(resId) → Set of "fieldKey" strings
```

---

## Session Log

Full session-by-session history has moved to `SESSION_LOG_ARCHIVE.md` (957 lines, not read automatically). Grep it when you need historical rationale, e.g. `grep -n "leave_plan" SESSION_LOG_ARCHIVE.md`. The sections above (schema, roles, gotchas, workflow) are the living reference — keep those current; append new session summaries to the archive file, not here.
