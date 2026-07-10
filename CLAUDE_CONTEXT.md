# DSFH IM Residency Portal — Claude Session Context

> Read this file at the start of every new session before touching any code.

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
- Schedule management (add/edit/delete)
- Attendance logging (P/L/A/E/O) with comment field
- MM overview table · Export to Excel

### KPI Dashboard (rebuilt Jul 2026)
**3-tab structure per resident:**
- **📊 Ongoing (60%):** Quiz 20% · MM Att 15% · Teaching 15% · Presenter/Moderator 10% — all auto-tracked
- **📆 Quarterly (informational, not scored):** Mentor sets Research Milestone + Area of Improvement per quarter as text. Anyone can submit "achieved" → PD approves. Resident can see (read-only).
- **🏆 Yearly (40%):** Committee 10% (PD scores 0–10) + 6 achievement cards: QI Project 5% · Research Publication 5% · Oral Presentation 5% · Poster Presentation 3% · Awards/Honors 4% · Volunteering 3%

**Proposal/approval flow:** Resident, mentor, chief, or PD can submit any yearly achievement. PD entries are auto-approved. All others show as ⏳ Pending — PD sees inline Approve/Reject. Approved proposals update `kpi_scores` and `kpi_proposals`.

**Summary card** shows Ongoing score/60 + Quarterly quarter + Yearly score/40 as clickable tiles.

**All-residents table** adds Achievements column (X/6) with pending indicator.

`exportKpiPDF(res, k)` generates a 3-section print report (Ongoing · Yearly · Quarterly).

`renderProfileKPI` in admin panel shows compact version with link to full KPI tab.

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

---

## Known Bugs / Gotchas — CRITICAL, read before every edit

- **CDN pinning:** Supabase JS pinned to `@2.39.0` — do NOT change. Newer versions break `window.supabase`.
- **async callbacks:** Any callback using `await` must be `async`. Missing it caused a site-wide crash (Jul 2026).
- **Single script block = total failure:** One JS syntax error anywhere blanks the entire page with no visible error. Always validate before committing (see below).
- **Curly/smart quotes in JS:** NEVER use `"` `"` `'` `'` inside JS strings or template expressions. They parse as separate tokens → "Unexpected string" crash. Use straight ASCII quotes only. This caused a blank-site incident Jul 2026.
- **init() has try-catch:** So render() always runs even if data loading fails.
- **GitHub Actions:** Custom deploy at `.github/workflows/deploy.yml` retries 3× — don't remove.
- **After every change:** `cp SFH_Residency_Portal.html index.html` then commit+push both.

---

## MANDATORY: JS Syntax Check Before Every Commit

```bash
cd "/Users/drghof/Documents/Claude/Projects/Residents"
node -e "
const fs=require('fs');const html=fs.readFileSync('SFH_Residency_Portal.html','utf8');
const re=/<script[^>]*>([\s\S]*?)<\/script>/g;let m,i=0;
while((m=re.exec(html))!==null){i++;if(i===3)break;}
fs.writeFileSync('/tmp/_portal_check.js',m[1]);
" && node --check /tmp/_portal_check.js && echo "✅ JS syntax OK"
```

If this fails → fix before committing. Never commit a broken state to main.

---

## Features Pending (Build These Next)

### 1. ~~Cumulative KPI Page~~ ✅ Done (10 Jul 2026)
Built as "Training Record" (`cumulative_kpi`, pd/deputy_pd/chief). Year rows expand to 4-quarter milestone grid. See session log for details.

### 2. ~~KPI Page Redesign~~ ✅ Done (10 Jul 2026)
Hero band, floating tiles, underline tabs, no-box metric rows, achievement list rows — all Eventevia-styled. Quarterly tab + milestone cards also redesigned this session.

### 3. Supabase Storage bucket needed
- Create bucket named `kpi-evidence` (public) in Supabase for KPI file uploads
- Without it, file upload in proposal modal fails gracefully (text still submits fine)

### 4. ~~Quiz Persistence~~ ✅ Done (error banner added)
### 5. ~~KPI PDF Export~~ ✅ Done
### 6. ~~Global Search~~ ✅ Done
### 7. ~~Bulk Broadcast~~ ✅ Done

---

## Workflow for New Sessions

1. Read this file first
2. Run JS syntax check (above) to confirm current state is valid
3. Read `SFH_Residency_Portal.html` around the relevant function before editing
4. Make changes to `SFH_Residency_Portal.html`
5. Run JS syntax check again
6. `cp SFH_Residency_Portal.html index.html`
7. `git add SFH_Residency_Portal.html index.html && git commit -m "..." && git push origin main`
8. GitHub Pages auto-deploys in ~1 min
9. **Update this file** if new features are added, SQL migrations run, or status changes

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

### Session — 5 Jul 2026
**Bugs fixed:**
- `calcKPI()` was missing `const tPct = ...` → caused blank KPI page (ReferenceError). Fixed line ~1076.
- `loadKpiQuarterly()` and `loadKpiProposals()` were only called on fresh login, not on session restore (`init()`). Added both to `init()`.

**Features built:**
- **KPI Proposal Modal** (`renderKpiProposalModal`): replaces `window.prompt`. Per-type structured fields: Research (title, authors, year, journal, link, PDF), Oral/Poster (title, event, date, file), QI (title, description, date, supervisor name + email), Awards (title, issuer, date, certificate), Volunteering (activity, org, date). File uploads via Supabase Storage bucket `kpi-evidence` (bucket must be created manually — public). Data serialized as JSON into `note` field — no schema change needed. `STATE.kpiPropModal`, `STATE.kpiPropFields`, `STATE.kpiPropUploading`.
- **Undo Verification** (`revokeKpiApproval`): PD-only ↩ Undo button next to ✅ Verified badge. Sets proposal → "rejected" and flips `kpi_scores` field to false.
- **Structured PD review panel** (`renderProposalDetails`): shows parsed JSON fields in the inline approval panel instead of raw text.
- **Removed PD instant-approve bypass**: PD uses the same modal (PD submissions still auto-approve). Submit buttons say specific labels: "+ Submit Research Publication", etc.
- **Pending KPI Approvals on PD home**: yellow alert block listing each pending submission by resident name + type + title, clicking navigates to their KPI Yearly tab.
- **Hero: Broadcast Announcement button** moved into the hero section, below block subtitle.
- **Hero: time added** to eyebrow line — e.g. "GOOD EVENING · SUNDAY, 5 JULY 2026 · 10:23 PM".
- **Hero info card**: repositioned to `position:absolute; right:48px; top:50%; transform:translateY(-50%)`. Added drop shadow. Left column gets `maxWidth: calc(100% - 330px)`.

**Key functions added/modified (all in SFH_Residency_Portal.html):**
- `revokeKpiApproval(resId, fieldKey)` — revokes an approved achievement
- `parseProposalNote(note)` — safely parses JSON or returns `{raw: note}`
- `uploadKpiFile(file, resId, fieldKey)` — uploads to Supabase Storage `kpi-evidence`
- `renderKpiProposalModal()` — standalone modal, wired in `render()` as `if(STATE.kpiPropModal)app.appendChild(...)`
- `renderProposalDetails(p)` — renders structured proposal fields for review
- `renderAchievement()` inside `renderKPI()` — updated for modal, undo, approved details display

**Still TODO next session:**
- Create `kpi-evidence` bucket in Supabase (public) for file uploads to work
- **KPI page redesign** — full visual overhaul, user confirmed to do this next

---

### Session — 5 Jul 2026 (continued — Executive Report + DIO role)

**Features built:**
- **🏆 Performance Report page** (mod id: `kpi_exec`, label: "Performance Report", roles: pd/deputy_pd/chief): Executive KPI dashboard for CMO/CEO/DIO presentations. 5 full-screen scroll sections with beige portal theme (not dark), IntersectionObserver fade-in animations.
  - **Section 1:** Program health ring (overall %) + podium (top 3 residents — gold/silver/bronze SVG rings)
  - **Section 2:** Academic year selector cards — 2025-26 active, others show "Under Progress 🔒"
  - **Section 3:** Cohort KPI summary for selected year — continuous score bars (quiz, MM, teaching) + yearly achievement counts per category
  - **Section 4:** Resident roster by level — avatar rings with score color, gold ★ for ≥80%, click → drill-down
  - **Section 5:** Individual resident profile — full score breakdown + approved achievements list
  - State keys: `STATE.kpiExYear` (default CURRENT_ACADEMIC_YEAR), `STATE.kpiExResident` (null = show cohort)
  - CSS injected fresh on each render via `id="kpix-css"` style element (removes old before inserting)
  - Helpers: `ring(score,sz,w,track,fill)` SVG ring, `ini(name)` initials (strips "Dr." prefix), `dname(name)` display name (strips "Dr."), `sbar(label,val,max,color)` progress bar, `podCard()` podium card, `achCount(field)` achievement count

- **`dio` role added** throughout portal:
  - `isPdRole(r)` — returns true for pd/deputy_pd/dio
  - `effectiveRole(r)` — maps 'dio' → 'pd' for MODS access checks and render() guard; no need to add 'dio' to every module's roles array
  - `ROLE_LABELS` map — `{pd:"Program Director", deputy_pd:"Deputy PD", chief:"Chief Resident", consultant:"Consultant", resident:"Resident", dio:"DIO"}` — used in sidebar and home screen
  - Sidebar: uses `effectiveRole()` to filter modules; role badge uses 'dio' color (same as pd: #c96a4a); displays "DIO" text
  - `canEditKPI()` updated to allow 'dio' role

**Key functions added/modified:**
- `isPdRole(r)`, `effectiveRole(r)`, `ROLE_LABELS` — role helpers (inserted ~line 1117)
- `renderKPIExecutive()` — ~415-line function, inserted before render()
- `renderSidebar()` — updated for effectiveRole + ROLE_LABELS
- `canEditKPI()` — updated to include 'dio'
- render() switch: `case "kpi_exec": content = renderKPIExecutive(); break;`
- render() access guard: uses `effectiveRole(u.role)` for module permission check

**Resident name fix:** All DB names are "Dr. Firstname Lastname". `ini()` and `dname()` both strip the "Dr." prefix. Use these everywhere in the executive page.

**✅ Dr. Arwa Jamal (DIO) account — COMPLETE (6 Jul 2026)**
- Auth user: `drarwajamal@dsfh.local` (id: `3af83db8-e421-4598-9894-a85747fa31ea`)
- Login username: `DrArwaJamal` (no dot)
- Role: `dio` — had to first ALTER TABLE profiles DROP/ADD profiles_role_check constraint to include 'dio'
- SQL run: `ALTER TABLE public.profiles DROP CONSTRAINT profiles_role_check; ALTER TABLE public.profiles ADD CONSTRAINT profiles_role_check CHECK (role IN ('pd','deputy_pd','chief','consultant','resident','dio'));`

**Still TODO:**
- Create `kpi-evidence` Supabase Storage bucket (public) for KPI file uploads
- Upload historical KPI data for 2024-25, 2023-24, 2022-23 (Phase 2 — currently show "Under Progress")

---

### Session — 6 Jul 2026

**Bugs fixed:**
- **Submit for Review button never worked**: `el()` was calling `setAttribute("disabled", false)` which still disables the button. Fixed `el()` to handle boolean attributes correctly — `true` sets attribute, `false` skips it entirely.
- **Achievement modal: typing lost focus after every keystroke**: `onInput` was calling `set()` → `render()` → full DOM rebuild → focus lost. Replaced with module-level `_kpiPropLive` mutable object; typing updates it without triggering render. File changes still call `render()` for filename display only.
- **KPI attendance scoring wrong**: P/E/O now = full mark (1.0), L (Late) = half mark (0.5), A (Absent) = 0, unlogged/O = excluded from total. Fixed in both `calcKPI()` and `calcKPIQ()`. Previously E and O were counting against residents.
- **DIO home page blank**: `renderModGrid()` was filtering MODS by `u.role` directly — 'dio' matched nothing. Fixed to use `effectiveRole(u.role)` like the sidebar.
- **Annual Leave: residents could see all residents' data**: Fixed to show only own leave page directly (`renderLeaveDetail(u.rid, null)`).
- **Rota: residents saw only themselves in Block/Full Table views**: `renderRotaBlock()` and `renderRotaTable()` now always use `RESIDENTS` (all), not `visRes()`. Only timeline remains personalized.

**Features built / improved:**
- **Achievement modal mandatory fields**: Each type validates its specific required fields before submit (publication: title+authors+year, oral/poster: title+event+date, awards: title+issuer+date, volunteering: title+organization+date).
- **Performance Report — podium clickable**: Top 3 cards navigate to that resident's individual profile (Section 5).
- **Performance Report — performance tier badge**: Badge below overall % ring — Outstanding (≥80%), Strong Progress (60-79%), Developing (30-59%), Needs Improvement (<30%).
- **Performance Report — 4-tier color scheme**: Gold (#B8860B) ≥80%, Bronze (#CD7F32) 60-79%, Silver (#9ca3af) 30-59%, Red (<30%). Applied to all rings, bars, and score numbers.
- **Performance Report — 0-value bars gray**: Items not yet attempted show neutral gray instead of red.
- **Rota: 3-tab view for residents**: Distribution (all residents block view) · My Rota (own timeline only, no dropdown) · Full Table (complete grid). Download .ics on My Rota tab.

**✅ Supabase RLS fix for rotations — DONE (6 Jul 2026):**
- `rotations` table now allows all authenticated users to read all rows.
- SQL run: `CREATE POLICY "all authenticated users can read rotations" ON public.rotations FOR SELECT TO authenticated USING (true);`

**Key attendance scoring rule (confirmed by PD):**
- P = Present (full), E = Excused (full), O = Outside rotation (full / excluded from denominator), L = Late (half mark), A = Absent (0), unlogged = excluded entirely.

---

### Session — 6 Jul 2026 (continued — Performance Report redesign + home hero)

**Features built / improved:**

- **Performance Report visible to all roles**: Added `"consultant"` and `"resident"` to `kpi_exec` mod's roles array. DIO already covered by `effectiveRole()`.
- **Scroll-to-top on every navigation**: Added `window.scrollTo(0,0)` at start of `render()` so every page change snaps to top.
- **Performance Report Section 1 — swimming confetti**: Canvas-based confetti added to sec1 background. 80 pastel pieces float in random directions with sine-wave oscillation (swimming motion). Stops via IntersectionObserver when section scrolls out of view.
- **Performance Report Section 1 — full redesign** (vertical layout, fits 100vh):
  - **Header**: eyebrow + big title + gold year pill
  - **Program Health band**: glass card — ring (left) + big stat + tier badge + progress bar toward "Outstanding" (right)
  - **Top Performers**: 1st place = full-width gold featured card with accent bar + avatar + name + score; 2nd & 3rd = compact side-by-side cards. All clickable → drill down to Section 5.
  - **Academic Achievements**: 6-column single row of glass tiles (3×2 on mobile)
  - Section clamped to `height:100vh`
- **Performance Report Section 1 — mobile responsive**: Added `.kpix-s1-pods`, `.kpix-s1-pod-card`, `.kpix-s1-pod-score`, `.kpix-s1-ach` CSS classes + `@media(max-width:640px)` rules. Score no longer clips; achievement grid goes 3-col on small screens.
- **Home hero — animated confetti**: Replaced static decorative shape divs (`.home-shape`) with a canvas animation. 32 warm-palette pieces (terracotta, amber, brown) — mix of rectangles and circles — swim very slowly. Self-terminates when canvas leaves DOM. Canvas id: `home-hero-cv`.

**Design decisions / patterns to carry forward:**
- Preview complex UI changes in `/tmp/xxx_preview.html` before applying to portal — user approved this workflow.
- User prefers vertical stacked layouts over side-by-side columns for report pages.
- Confetti speed sweet spot: `speed: 0.08–0.18` for home hero (very gentle), `speed: 0.3–0.5` for performance report (more lively).
- Section 1 uses `height:100vh` (not `min-height`) to hard-clamp to one screen.

---

### Session — 6 Jul 2026 (continued — multiple KPI submissions + Performance Report access)

**Features built / improved:**

- **Multiple KPI achievement submissions per type**: Residents can now submit more than one entry per achievement category (e.g. two QI projects, multiple publications). Previously the submit button was hidden once any entry was pending or approved.
  - `renderAchievement()` updated: `approvedProp` (find) → `approvedProps` (filter). All approved entries rendered individually with dividers.
  - Submit button always visible; label switches to "Submit Another…" once at least one is approved.
  - PD gets a per-entry ↩ Undo button (passes `proposalId`, not just `fieldKey`).
  - `revokeKpiApproval(resId, fieldKey, proposalId)` — only flips `kpi_scores` to false if it was the last approved proposal for that type.
  - Badge shows "✅ Verified (N)" when N > 1.

- **Performance Report visible to all roles — navigation fix**: `kpi_exec` already had "resident" and "consultant" in its `roles` array and `renderKPIExecutive` had no role-based filtering. The bug was `STATE.kpiExResident` persisting from previous session navigation — on re-entry, users landed on their own Section 5 profile instead of the full report.
  - Fixed by resetting `kpiExResident: null` whenever navigating to `kpi_exec` from both sidebar (line ~1411) and home grid (line ~1734).
  - Every visit now starts fresh at Section 1 — program health ring, top performers, cohort stats, full roster.

**Still TODO:**
- Create `kpi-evidence` Supabase Storage bucket (public) for KPI file uploads
- Upload historical KPI data for 2024-25, 2023-24, 2022-23 (Phase 2)
- **KPI page redesign** — full visual overhaul (discussed, user confirmed to do this)

---

### Session — 6 Jul 2026 (On-Call Schedule module)

**Features built:**
- **🏥 On-Call Schedule module** (mod id: `oncall`, roles: all). 3-tab structure:
  - **📅 Schedule tab**: 28-day block grid. Weekday rows = 4 slots (ER Medical, Building 1, Building 2, Consult, 16:00–22:00). Weekend rows (Fri/Sat) highlighted blue = 6 slots (+ CTU Cover A & B, 08:00–16:00 day cover only; full oncall = 08:00–22:00). Extra/penalty slots show ⚠ Extra red badge.
  - **👤 My On-Calls tab**: personal upcoming/past list, today highlighted, `.ics` calendar download.
  - **📊 Statistics tab**: PD-only for now. Per-resident regular vs extra counts, block + all-time. Flip visibility later.
  - Block selector (B1–B13 pills), defaults to CURRENT_PERIOD.
  - Edit modal: per-day slot dropdowns + "Extra" checkbox. Authorized: pd, deputy_pd, chief, privilege `edit_oncall`.
  - Home page alert for residents: shows next upcoming oncall, red if extra penalty.
  - Positioned 2nd in MODS grid (after Rota Schedule).

**New Supabase table:** `oncall_schedule` — migration at `supabase/add_oncall_schedule.sql`.
  - Columns: id (uuid), block_number (int), academic_year (int), schedule_date (date), slot_key (text), resident_id (**bigint** — matches residents.id), is_extra (bool), created_by (uuid), created_at.
  - UNIQUE constraint: (schedule_date, slot_key).
  - RLS: all authenticated can read; pd/deputy_pd/chief/edit_oncall privilege can write.

**New privilege:** `edit_oncall` added to `PRIV_LABELS_RESIDENT` — "Enter/edit On-Call schedule (Oncall Committee)".

**Block 11 data (AY 2025-26):** Full schedule entered via SQL INSERT for 2026-07-05 → 2026-08-01. Extra flags: Raghda (Jul 7 consult), Farid (Jul 14 consult), Mansour (Jul 20 consult), Abdulmajeed (Jul 21 consult), Rasha (Jul 22 consult), Nawaf (Jul 24 bldg2). M. Juninah (outside rotator, id=124 or 125, level='R1', active=false) added for 4 consult slots (Jul 13, 18, 24, 27).

**Critical bugs found and fixed this session:**
- `dname()` was a local function inside `renderKPIExecutive()` — invisible to `renderOncall()`. Promoted to **module-level** (near `resById`). ⚠️ Never re-localize it.
- `resById(id)` changed from `===` to `==` (loose equality) — Supabase returns bigint FK columns as JS strings but `residents.id` may be a number; `==` handles both.
- `blockStartDate(block, academicYear)` adds 1 year for months < 9. Block 11 label = "5/7-1/8" → month 7 < 9 → year = academicYear+1. So block 11 of AY 2025 = **July 2026**, not July 2025. Always use `blockStartDate()` output for date ranges — never hardcode year offsets when inserting oncall data.
- `oncall_schedule.resident_id` must be `bigint` (not uuid) to match `residents.id` type.
- When saving from dropdown: `parseInt(resident_id, 10)` required before Supabase insert.
- **Timezone off-by-one in date generation**: `d.toISOString().split("T")[0]` converts to UTC — in UTC+3, midnight local = 9 PM previous day UTC → all grid dates shifted back one day vs DB dates. Fix: always build date strings from local parts: `d.getFullYear()+"-"+String(d.getMonth()+1).padStart(2,"0")+"-"+String(d.getDate()).padStart(2,"0")`. ⚠️ Apply this pattern anywhere dates are generated from a Date object and compared against DB date strings.

**Still TODO:**
- Statistics tab visibility: currently PD-only. User will decide when to open it to other roles.
- M. Juninah's consult slots: 4 rows inserted (Jul 13, 18, 24, 27) using his resident record.
- Future blocks: enter via Edit modal in the portal, or SQL INSERT with correct 2026/2027 dates.
- `kpi-evidence` Supabase Storage bucket still not created.
- Historical KPI data (Phase 2) still pending.
- KPI page redesign still pending.

---

### Session — 6 Jul 2026 (UX improvements + Oncall redesign)

**Features built / improved:**

- **Oncall column labels updated**: ER Medical → "ER Medical Oncall"; Building 1/2/Consult → "Floor Oncall"
- **Inline double-click editing — Oncall**: double-click any cell opens a type-to-filter resident dropdown. Escape/blur closes. Saves single cell to Supabase immediately. Extra flag still managed via Edit modal.
- **Inline double-click editing — MM & Teaching schedules**: same pattern extended to Morning Meeting (Day, Date, Topic, Presenter, Moderator, Consultant) and Teaching (Day, Date, Specialty, Topic, Presenter). Uses shared helper functions:
  - `schedInlineText(sid, field, val, saveFn, tbl)` — text/date field
  - `schedInlineResident(sid, field, currentResId, currentLabel, saveFn, tbl)` — resident+consultant dropdown with free-text fallback
  - `STATE.schedInlineEdit = {id, field, tbl}` — tbl="mm" or "teach" prevents ID collision
  - Edit/Delete buttons remain for full-form fields (row colour, etc.)
- **sortByLevel()** — global helper (`_LVL_ORD = {R4:0,R3:1,R2:2,R1:3}`). Replaces all `sort((a,b)=>a.name.localeCompare(b.name))` for RESIDENTS everywhere. Stats table also sorted by level.
- **Search input focus fix**: `render()` now saves `document.activeElement?.id==="search-inp"` + cursor position before DOM wipe, restores both after rebuild. Input has `id="search-inp"`.
- **Outside rotator display fix**: `_inactiveResById = {}` global, populated at startup from inactive residents. `anyResById(id)` checks RESIDENTS first then `_inactiveResById`. Fixes "?" display for archived/outside residents like M. Juninah.
- **Free-text oncall entries**: `oncall_schedule` table needs `resident_name text` column (migration `add_oncall_resident_name.sql` — **NOT YET RUN**). `saveOncallCell(blk, date, slotKey, residentId, residentName)` — pass null residentId + name string for free text. Edit modal has text input below each slot dropdown; typing there disables the dropdown.
- **Oncall table redesign**:
  - CSS class `oncall-tbl` (not `data-table`) — warm chocolate brown header (`#4a3828`), alternating rows, hover tint
  - Day column: pill badges — weekday = beige `.oc-day-pill.wd`, weekend = olive `.oc-day-pill.we` (`#4a6741`), today = terracotta `.oc-day-pill.today`
  - Weekend rows: `.oc-we` = sage green `#f1f4ee`
  - Today row: `.oc-today` = warm cream + 4px terracotta left border + `TODAY` badge (`.oc-today-badge`)
  - Table wrapped in rounded card with shadow
- **Color preview workflow confirmed**: User approved previewing complex UI changes in `/tmp/xxx_preview.html` before applying. Always do this for new visual designs.
- **Pilot disclaimer**: Added below eyebrow on hero left (mobile) and below DSFH tag inside info card (desktop). Style: small amber note box (`#fef9ec` bg, `#f0d98a` border, `#92680a` text).

**Key globals / helpers added this session:**
- `_LVL_ORD`, `sortByLevel(arr)` — level-sorted resident list (R4→R1 then alpha)
- `_inactiveResById`, `anyResById(id)` — lookup including inactive residents
- `schedInlineText()`, `schedInlineResident()` — shared inline-edit helpers for schedule tables
- `saveOncallCell(blk, date, slotKey, residentId, residentName)` — single-cell oncall save
- `STATE.schedInlineEdit = {id, field, tbl}` — active inline edit cell tracker
- `STATE.oncallInlineEdit = {date, slotKey}` — active oncall inline edit tracker

**Still TODO (carried forward):**
- Run `supabase/add_oncall_resident_name.sql` in Supabase to enable free-text oncall entries
- `kpi-evidence` Supabase Storage bucket (public) — KPI file uploads still fail without it
- Historical KPI data 2024-25, 2023-24, 2022-23 (Phase 2 — show "Under Progress 🔒")
- KPI page full visual redesign (confirmed by user, still deferred)
- Oncall Statistics tab — currently PD-only; user will decide when to open to other roles

---

### Session — 6 Jul 2026 (Best Resident module)

**Features built:**
- **⭐ Best Resident module** (mod id: `best_resident`, roles: all). Quarterly recognition system — Best Senior (R3/R4) and Best Junior (R1/R2) per quarter.
  - **Quarter mapping**: Q1=Oct–Dec, Q2=Jan–Mar, Q3=Apr–Jun, Q4=Jul–Sep (academic year aligned)
  - **Score formula**: KPI 50% (`kpiOngoingScore(id)` = ongoing KPI normalized to 0–100) + Votes 50% (vote share across all voters). Equal weight for all voter roles. Self-vote blocked.
  - **🗳️ Vote tab**: Two dropdowns (Senior = R3/R4, Junior = R1/R2). One vote per quarter per profile. After voting shows confirmation with who you voted for. Votes anonymous.
  - **📊 Live Rankings tab**: Real-time leaderboard per tier (senior/junior). Shows KPI%, vote count, final combined score. Animated bars. "YOU" badge for logged-in resident.
  - **🏆 Hall of Fame tab**: All announced winners by quarter, loaded lazily via `loadBestResidentAll()`.
  - **PD controls** (pd/deputy_pd only): Open Voting (optional auto-close datetime), Close Voting, Announce Winners (auto-picks top scorer, asks confirmation).
  - **Home page Stars banner** (`renderBestResidentBanner()`): gold gradient banner between hero and alerts. Shows winner cards (crown, name, level, score) when announced; blurred mystery cards + pulsing voting strip with countdown when open; quiet placeholder otherwise.
  - **Confetti on announcement**: Canvas confetti fires once per quarter per user (tracked in `localStorage` key `br_seen_Q_AY`). 120 pieces, warm palette, fades over 3 seconds.

**New Supabase tables** (migration: `supabase/add_best_resident.sql` — ✅ run 6 Jul 2026):
- `best_resident_votes`: profile_id, academic_year, quarter, voted_senior_id (bigint), voted_junior_id (bigint). UNIQUE(profile_id, academic_year, quarter).
- `best_resident_winners`: academic_year, quarter, voting_open, voting_deadline (timestamptz), senior/junior_resident_id (bigint), senior/junior_score, announced (bool), announced_at. UNIQUE(academic_year, quarter).

**Key globals / helpers added:**
- `BEST_VOTES=[]`, `BEST_STATUS=null` — loaded by `loadBestResident()`
- `currentQuarter()`, `quarterLabel(q)`, `quarterMonthsLabel(q)` — quarter helpers
- `kpiOngoingScore(id)` — ongoing KPI (quiz+MM+teaching+pres) normalized to 0–100
- `ini(name)` — initials from display name (strips Dr. prefix) — **promoted to module level** (was already local in kpi_exec)
- `brVoteCountFor(resId, role)`, `brTotalVoters()`, `brMyVote()`, `brComputeRankings()`, `brVotingIsOpen()`, `brDeadlineCountdown()`
- `brCastVote()`, `brOpenVoting()`, `brCloseVoting()`, `brAnnounceWinners()`, `loadBestResidentAll()`
- STATE keys: `STATE.brTab`, `STATE.brVoteSenior`, `STATE.brVoteJunior`, `STATE.brDeadlineInput`, `STATE.brAllWinners`, `STATE.brHofLoaded`

**Design decisions:**
- Preview complex UI in `/tmp/xxx_preview.html` before applying — confirmed workflow.
- No charge nurse logins for now — only residents + consultants vote.
- Voters weighted equally regardless of role.

**Countdown timer design (same session):**
- Stars banner "not yet announced" state replaced with **Design B**: centered layout, four white countdown blocks (Days : Hours : Min : Sec) with gold underline, live-ticking via `requestAnimationFrame`. Winner placeholder cards slightly hazy (`opacity:.78`, `filter:blur(.6px)`, `border:1.5px solid #f0e8d8`), hover brightens them. CSS classes: `.cdb-block`, `.cdb-num`, `.cdb-unit`, `.cdb-sep`, `.cdb-cards`, `.cdb-pending-card`. Tick loop attaches via `setTimeout(()=>{...},0)` after DOM insert and self-cancels when `.cdb-num` leaves DOM.

**Still TODO:**
- Run `supabase/add_oncall_resident_name.sql` (free-text oncall) — still not run
- `kpi-evidence` Supabase Storage bucket — still not created
- Historical KPI data (Phase 2)
- KPI page visual redesign (deferred)
- Oncall Statistics tab visibility (PD decides when to open)

---

### Session — 6 Jul 2026 (Live Calendar Feed) ✅ COMPLETE

**Features built:**
- **📅 Live Calendar subscription feed** — fully live and tested.
  - **Edge Function** (`supabase/functions/ical/index.ts`, deployed as `ical`, JWT verification OFF): takes `?token=UUID`, looks up `profiles.calendar_token`, returns RFC-5545 `.ics`. Refreshes hourly.
  - **SQL migration** (`supabase/add_calendar_token.sql`): ✅ Run. Adds `calendar_token text UNIQUE` and `calendar_prefs jsonb` to `profiles`.
  - **Prefs** (`profiles.calendar_prefs` jsonb): `{rota, oncall, mm_mine, mm_all, teach_mine, teach_all, deadlines}`. `mm_mine` = only sessions where I'm presenter/moderator. `mm_all` = full schedule. `teach_mine` = sessions where my name appears as presenter (name-match). `teach_all` = full schedule. Backward compat: old `mm`/`teach` keys auto-migrate.
  - **Non-resident accounts** (PD, DIO): `mm_mine` shows all sessions (no resId to filter by — correct for roles that attend everything). Rota and oncall sections skip gracefully when resId=null.
  - **Portal UI**: "My Calendar" button in home hero → `renderCalModal()` with 7 checkboxes, generates webcal:// link, Apple Calendar button, Google Calendar button, one-time .ics fallback.
  - **Per-module download buttons removed** — home hero is the single entry point.
  - **MM time corrected**: 08:00–09:00 (was 07:00 in old downloadRotationICS too, now fixed).

**Key constants/functions:**
- `CAL_FEED_FN="ical"` — edge function slug (update if ever redeployed with different slug)
- `_calPrefsDraft` — module-level mutable draft for modal (avoids render() on checkbox toggle)
- `generateCalToken()`, `saveCalPrefs(prefs)`, `renderCalModal()`
- Feed URL: `SUPABASE_URL + "/functions/v1/ical?token=" + STATE.calToken`

**Still TODO (carried forward):**
- Run `supabase/add_oncall_resident_name.sql` (free-text oncall entries) — NOT YET RUN
- `kpi-evidence` Supabase Storage bucket — still not created
- Historical KPI data (Phase 2)
- KPI page visual redesign (deferred)

---

### Session — 6 Jul 2026 (UX polish: counseling redesign, schedules, highlights)

**Bugs fixed:**
- **Counseling: residents could see all records**: `renderCounseling()` was using `visRes()` which returns all residents for privileged residents (attendance committee). Fixed to always filter to own record when `u.role==="resident"`.
- **Oncall mobile scroll broken**: `overflow:"hidden"` on the table wrapper was overriding `overflowX:"auto"`. Removed `overflow:"hidden"`.

**Features built / improved:**
- **Counseling PD view — roster + drawer**: Full-width resident table (sorted by level) with colored counseling count badges (✅ None / ⚠️ 1 / 🚨 N). Clicking a row slides open a sticky 400px drawer from the right — lists records, click to expand details inline with Edit/Delete/Countersign. Page content shifts left to make room. Resident view unchanged (own records only). New functions: `renderCounselRecordsList()`, `renderCounselingDrawer()`. State: `STATE.counselDrawerRes`, `STATE.counselExpandId`.
- **Self-name highlighting** — gold amber pill (`#fde68a` bg, `#b45309` text) applied everywhere a user's name appears:
  - **Oncall schedule**: amber pill on name cell
  - **Rota full table**: amber pill on name in sticky col + warm cream row background + amber left border
  - **Rota block view**: warm `#fffbeb` card background + amber left border
  - **MM/Teaching schedule**: amber pill via `personLabelEl()` (both view-mode and edit-mode via `schedInlineResident()`)
  - `personLabelEl()` also matches by name string as fallback when `presenter_resident_id` is null
- **Resident default tab — Oncall**: opens on "My On-Calls" tab instead of Schedule
- **Oncall: Date + Day sticky columns**: Date pinned at `left:0` (60px), Day pinned at `left:60px` (90px). Header also sticky top:0. Compact date format "5 Jul" instead of "dd/mm/yyyy".
- **Rota full table: sticky header row** (`th { position:sticky; top:0 }`) and sticky level-group rows (`R4 — N RESIDENTS` cells pin at `left:0` when scrolling right).
- **MM schedule: combined Day/Date column**: Day (3-letter abbrev "Mon") + Date ("5 Jul") stacked in one cell — saves a full column on mobile. Uses `shortFmtDate()` helper. Week column shortened to "W1/W2". No sticky left columns (user preference — let them scroll freely).
- **`selfTag()` helper** added (module-level) — originally used as a pill, now replaced by inline styling in all highlight locations.
- **`shortFmtDate(d)`** helper added (module-level) — returns "5 Jul" compact format.

**Key functions added/modified:**
- `renderCounselRecordsList(res, records, u)` — shared record list for drawer and resident view
- `renderCounselingDrawer()` — fixed-position drawer panel
- `selfTag()` — amber pill span (kept for potential future use)
- `shortFmtDate(d)` — compact date formatter
- `personLabelEl(residentId, label)` — updated with name-match fallback + amber highlight
- `schedInlineResident()` — updated to apply amber highlight in display mode when currentResId===u.rid
- `renderScheduleTable()` — updated to support `stickyLeft`, `minW`, `maxW` on cols; wk-cell shows "W1" not "Week 1"

**Still TODO (carried forward):**
- ~~Run `supabase/add_oncall_resident_name.sql`~~ ✅ Done
- `kpi-evidence` Supabase Storage bucket — still not created
- Historical KPI data (Phase 2)
- KPI page visual redesign (deferred)
- Oncall Statistics tab visibility (PD decides when to open to other roles)

---

### Session — 7 Jul 2026 (RLS fixes + consultant access)

**Bugs fixed:**
- **Oncall schedule showing "?" for all names** (reported for Dr. Joharji and Dr. Zahra): DB `resident_id` values are in the 80s–110s range; hardcoded fallback `RESIDENTS` uses ids 1–29. When `loadCoreData()` failed (due to RLS errors on `profiles` or `account_privileges` for some users), `RESIDENTS` was never updated from the DB, so `anyResById(93)` found nothing → "?". Two-part fix:
  1. **Code**: `loadCoreData()` no longer aborts on `profiles`/`account_privileges` errors — only fails on `residents`/`consultants` errors. Non-critical errors are `console.warn`.
  2. **SQL migration** `supabase/fix_read_rls_for_all.sql` ✅ Run: opens SELECT for all authenticated users on `residents`, `consultants`, `profiles`, `account_privileges`, `oncall_schedule`. No role restrictions on reads.
- **Rota Timeline — consultants saw only assigned residents**: `renderRotaTimeline()` was using `visRes()` which filters to assigned residents for the consultant role. Fixed to use `RESIDENTS` (all) for any non-plain-resident role.

**SQL migrations run this session:**
- `supabase/fix_read_rls_for_all.sql` ✅ — open read RLS on 5 core tables
- `supabase/add_oncall_resident_name.sql` ✅ — confirmed already run (column verified)

**Consultant access confirmed working:**
- KPI (assigned residents only) ✅
- All rota views (Block, Timeline, Full Table) ✅
- Oncall schedule (full) ✅
- Morning Meeting schedule ✅
- Teaching schedule ✅

**Also fixed this session:**
- **Username change syncs `residents.username`**: `saveUsername()` previously only updated `profiles.username` + auth email. Now also runs `sb.from("residents").update({username:newUser}).eq("id",u.rid)` when `u.rid` exists. Schedules unaffected (use numeric FK). Contact email (`profiles.contact_email`) is safe for residents to set to their real email — no auth side effects.

**Teaching attendance notes:**
- `canLogTeachAttendance()`: PD/chief/consultant always; residents need `edit_teach_attendance` privilege
- No date lock — any session can be edited anytime
- Session must exist in `teaching_sessions` schedule before attendance can be logged

**Still TODO (carried forward):**
- `kpi-evidence` Supabase Storage bucket — still not created
- Historical KPI data (Phase 2)
- KPI page visual redesign (deferred)
- Oncall Statistics tab visibility (PD decides when to open to other roles)

---

### Session — 7 Jul 2026 (Loading screen, toast/confirm system, notifications, audit trail)

**Features built / improved:**

- **Hardcoded data removed**: `RESIDENTS`, `CONSULTANTS`, `MENTORS`, `ROT_H` arrays cleared to empty. DB is the sole source of truth. `loadCoreData()` already populated them; no logic change needed.
- **Loading screen** (`renderLoading()`): Shown while session check + `loadCoreData()` run on startup. `STATE.loading` flag — set `true` at init start, `false` after. Spinner + "Loading your data…" text. Prevents blank white flash.
- **Toast system** (`showToast(msg, type)`): Replaces all 78 `alert()` calls. Color-coded floating banners (error=red, warning=yellow, success=green, info=blue). Auto-dismiss 5s, manual ✕ close. Appends to `#toast-root` div created on demand.
- **Confirm dialogs** (`showConfirm(msg, onYes, btnLabel, btnClass)`): Replaces all 16 `confirm()` calls. Styled modal with Cancel + action button. Async `onYes` callback.
- **Info modal** (`showInfoModal(title, lines)`): Used for "Login Created" credentials — stays open until admin clicks "I have written this down ✓". Never auto-dismisses.
- **Notification bell** in sidebar: 🔔 icon next to username, red badge shows unread count. Click opens `renderNotifPanel()` — right-side drawer listing notifications. "Mark all read" button. Notifications stored in `notifications` Supabase table.
- **Notifications triggered on**: leave request submitted (→ notify all PD profiles), leave approved (→ notify resident), leave rejected (→ notify resident), KPI proposal submitted (→ notify PD), KPI approved (→ notify resident), KPI rejected (→ notify resident).
- **Activity log** (`logActivity(actionType, entityType, entityId, details)`): Fire-and-forget insert to `activity_log` table. Called on: MM attendance marked, Teaching attendance marked, leave submitted/approved/rejected, KPI submitted/approved/rejected.
- **Activity Log tab** in Admin panel: "📋 Activity Log" tab next to existing tabs. Calls `loadActivityLog()` on tab click. Shows last 200 entries: time ago, who, action type, details.

**New functions:**
- `renderLoading()`, `showToast()`, `showConfirm()`, `showInfoModal()` — UI utilities
- `loadNotifications()`, `createNotification()`, `markNotifRead()`, `markAllNotifsRead()` — notification layer
- `getPdProfileIds()` — returns array of profile IDs with pd/deputy_pd/dio role
- `timeAgo(isoStr)` — "5m ago", "2h ago", "3d ago" formatter
- `renderNotifPanel()` — notification drawer
- `logActivity()`, `loadActivityLog()`, `renderActivityLog()` — audit trail

**SQL migrations run (7 Jul 2026):**
- `supabase/add_notifications.sql` ✅ — notifications table + RLS
- `supabase/add_activity_log.sql` ✅ — activity_log table + RLS (immutable, PD/chief/dio read all)

**Still TODO (carried forward):**
- `kpi-evidence` Supabase Storage bucket — still not created
- Historical KPI data (Phase 2)
- KPI page visual redesign (deferred)
- Oncall Statistics tab visibility (PD decides when to open to other roles)

---

### Session — 7 Jul 2026 (Performance Report visual redesign)

**Bugs fixed:**
- **Silver/bronze medal swap** (3 places): `sc()` (line ~6543) — fixed color order: `v>=80→#B8860B` (gold), `v>=60→#C0C0C0` (silver), `v>=30→#CD7F32` (bronze), `else→#DC2626` (red). Same swap fixed in `perfTier()` (label + bg + border). Legend text also fixed.
- **`&lt;30%` rendered as literal HTML entity** in legend — replaced with literal `<30%` inside `el()` string.

**Visual changes — Performance Report (all in `renderKPIExecutive()`):**

- **Tier-based resident card coloring**: Each card in the roster (sec4) now has a colored stripe at top + matching background + border + shadow based on score tier:
  - Gold (≥80%): `linear-gradient(90deg,#f7e98e,#D4AF37)` stripe, `#fdf8ec` bg
  - Silver (60–79%): `linear-gradient(90deg,#ddd,#b0b0b0)` stripe, `#f5f5f5` bg
  - Bronze (30–59%): `linear-gradient(90deg,#f0c080,#CD7F32)` stripe, `#fdf3e8` bg
  - Red (<30%): `linear-gradient(90deg,#fca5a5,#ef4444)` stripe, `#fdf2f2` bg
  - Card uses `overflow:"hidden"`, `padding:"0"`. First child = 7px stripe div. Second child = body wrapper with `padding:"12px 10px 14px"`.

- **Unified beige background** across all sections: sec2 `"#ede5d8"` → `"#f5ede0"`, sec4 `"#ede5d8"` → `"#f5ede0"`. sec3 was already `"#f5ede0"`. All horizontal `borderBottom` lines removed (sec2, sec3) for seamless single-page feel.

- **Floating background decorations (sec4)**: 8 large blobs (pastel radial gradients), 38 dots in 6 horizontal rows, 6 rotating squares, 6 triangles — all `position:absolute`, `opacity:.55–.70`, behind content via `zIndex:0`. Content wrapped in `el("div",{st:{position:"relative",zIndex:"1"}},...)`.
  - Blob colors: `rgba(255,220,150,...)` / `rgba(255,180,130,...)` / `rgba(255,200,160,...)` etc.
  - Dot colors: `#f5c77e` (soft gold) and `#f0a87a` (peach) — Option A chosen by user.
  - Keyframes added to kpix-css: `kpix-blobLR`, `kpix-blobRL`, `kpix-dotBob`, `kpix-dotBob2`, `kpix-drift`.
  - CSS rules added: `#kpix-s2,#kpix-s3,#kpix-s4{position:relative;overflow:hidden}`, `.kpix-blob{position:absolute;border-radius:50%;pointer-events:none;z-index:0}`, `.kpix-dot{position:absolute;pointer-events:none;z-index:0}`.

- **Hazy centered glow (sec2 + sec3)**: Single 900px radial gradient dot centered behind content. `top:"calc(50% - 450px)"`, `left:"calc(50% - 450px)"`, `background:"radial-gradient(circle,rgba(255,200,130,.45),rgba(255,200,130,0) 65%)"`, `animation:"kpix-drift 9s ease-in-out infinite"`. Content wrapped in `zIndex:1` div to stay above glow. Centered using `calc()` rather than `transform:translate(-50%,-50%)` to avoid conflict with the drift animation.

**Key pattern used**: `calc(50% - 450px)` for centering absolutely-positioned animated elements (avoids transform conflict with existing animation).

**Still TODO (carried forward):**
- `kpi-evidence` Supabase Storage bucket — still not created
- Historical KPI data (Phase 2)
- KPI page visual redesign (deferred)
- Oncall Statistics tab visibility (PD decides when to open to other roles)

---

### Session — 10 Jul 2026 (Eventevia design system + global redesign)

**Features built / improved:**

- **Collapsible roster groups in Performance Report** (`renderKPIExecutive()`): Each level group (R4/R3/R2/R1) is now independently collapsible. Clicking the group header toggles the body. Animated chevron (SVG, rotates -90° when collapsed). Pattern uses imperative `grpWrap.appendChild(hdr); grpWrap.appendChild(body)` with `body.id = "kpix-lvlb-"+lvl` and `getElementById` in the click handler (required because `el()` needs post-hoc ID lookup).

- **Full portal Eventevia design system** — entire `<style>` block replaced with the Eventevia palette:
  - **Palette**: `#FEFBF3` cream canvas · `#F6EFE2` parchment · `#1F1A12` dark · `#c96a4a` terracotta · `#A47A28` gold · `#CBA155` light gold · `#7FB89C` green
  - **Typography**: Playfair Display (serif) for all headings and large stat numbers; existing sans stack for body
  - **Cards** → transparent, no shadow, `border-bottom: 1px solid rgba(31,26,18,.07)` — flowing sections, no boxing
  - **Tabs** → underline-only (`border-bottom: 2px solid transparent`), no background box
  - **Stat boxes** → `background: #F6EFE2`, Playfair Display numbers
  - **Module grid** → `border: none; border-right/bottom: 1px rgba` editorial grid, hover = `#F6EFE2`
  - **Hero / login / loading** → `linear-gradient(148deg, #7c3820 0%, #c96a4a 45%, #e8956d 70%, #fde0c8 100%)`
  - All Best Resident, KPI, counseling, oncall CSS classes updated to Eventevia palette
  - Replacement done via Python script `/tmp/new_css.py` (safe to re-run if needed)

- **Global Eventevia color pass** across all JS render functions (via `/tmp/eventevia_pages.py`):
  - `#111827` / `#374151` → `#1F1A12` (text)
  - `#f8fafc` → `#F6EFE2`, `#f1f5f9` → `#FEFBF3` (backgrounds)
  - `#e5e7eb` / `#e2e8f0` → `rgba(31,26,18,.1)` (borders)
  - `#6b7280` / `#9ca3af` → `rgba(31,26,18,.42)` (muted text)
  - `#16a34a` → `#26523A`, `#d97706` → `#A47A28` (semantic colors)
  - `#1a6a9a` / `#2563eb` → `#c96a4a`, `#7c3aad` → `#A47A28` (accent colors)

- **`renderPDOverview()` structural rewrite** — Playfair Display heading, warm stat boxes, parchment table:
  - Full-width layout (no `.content` wrapper); breadcrumb eyebrow in terracotta, big serif title
  - `statCard()`: parchment bg, Playfair numbers, no emoji icons
  - `colH()`: `#F6EFE2` header cells, warm letter-spacing
  - `pctCell()`: Playfair Display font for percentages
  - `kpiColor`: `#26523A` (green) / `#A47A28` (amber) / `#b52040` (red)
  - `lvlStyle`: warm tints replacing cold blue/green/yellow/purple

- **All emoji stripped** from the portal UI — Unicode regex pass on the entire main JS script block (3rd `<script>` tag only, not SVG or HTML attributes). Manual replacement map for ~40 emoji-prefixed UI strings, then regex sweep for any remaining Unicode emoji characters.

**Key technical patterns used:**
- Large CSS replacement via `content.find('<style>')` + `content.find('</style>')` in Python (avoids Edit tool truncation risk)
- Emoji regex: `re.sub(r'[\U00010000-\U0010FFFF\U00002600-\U000027BF\U0001F300-\U0001FAFF]+', '', ...)` on JS block only
- Preview workflow confirmed: build `/tmp/xxx_preview.html` → headless Chrome `--screenshot` → show user → get approval → apply

**Still TODO (carried forward):**
- **Page-by-page render redesign** — CSS foundation done, `renderPDOverview` done, `renderMorning` done. Remaining: `renderTeaching`, `renderKPI`, `renderLeave`, `renderOncall`, `renderAdmin`, `renderBestResident`, `renderCounseling`, `renderMentorHome`, `renderQuiz`, `renderRota`
- `kpi-evidence` Supabase Storage bucket — still not created
- Historical KPI data (Phase 2)
- Oncall Statistics tab visibility (PD decides when to open to other roles)
- Deduplicate `currentQuarter`, `saveAtt`, `close`, `tick` (4 duplicate function names flagged in code)

---

### Session — 10 Jul 2026 (SVG icons, mobile sidebar, Morning Meetings redesign)

**Features built / improved:**

- **SVG icons for module grid + sidebar**: `modIcon(id, sz)` function added just before `const MODS=[...]`. Uses `document.createElementNS("http://www.w3.org/2000/svg",tag)` (NOT `el()` — SVG requires namespace). Called as `modIcon(m.id,15)` in sidebar and `modIcon(m.id)` in home grid. 14 Lucide-style stroke icons (calendar, clock, map pin, sun, book, bar chart, checkbox, lock+calendar, chat bubble, pencil, gear, eye, monitor+chart, star).

- **Modal close buttons fixed**: All `el("button",{cls:"modal-close",...})` now contain `"×"` (literal × character). Were stripped to `""` during emoji pass.

- **Mobile hamburger + sidebar drawer**:
  - `mob-topbar` always had a `renderMobileTopBar()` call in `render()` — already visible at `<600px`
  - Hamburger: SVG 3-line icon built with `createElementNS`, calls `set({showMobileNav:true})`
  - Sidebar: gets `mob-open` CSS class when `STATE.showMobileNav`. CSS: `position:fixed; left:-260px; transition:left .25s` → `.mob-open { left:0 }` at `<600px`
  - Backdrop: `el("div",{cls:"mob-backdrop mob-open", onClick:()=>set({showMobileNav:false})})` appended in `render()` when `STATE.showMobileNav`
  - X close button: rendered inside `sidebar-brand` row when `STATE.showMobileNav`, calls `set({showMobileNav:false})`
  - All sidebar nav item `onClick`s include `showMobileNav:false`
  - Mobile topbar right: "Account" text button + red "Sign Out" button

- **Morning Meetings redesign** (`renderMorning`, `renderMMSchedule`, `renderMMAttendance`, `renderMMOverview`):
  - Header: terracotta eyebrow, Playfair Display h1, AY + block subtitle, "+ Add Session" pill CTA (PD/chief only)
  - Tabs: underline style (`border-bottom:2px solid #c96a4a` for active), no pill boxes
  - Block selector: compact pill row (no card wrapper), same terracotta active style
  - Stat boxes: 5-column grid, Playfair Display numbers on `#F6EFE2` parchment
  - Tables: `border:1px solid rgba(31,26,18,.08); border-radius:12px; overflow:hidden` wrapper (no `.card`)
  - Overview: serif heading, same clean table wrapper
  - `renderMMAttendance` has local `kpiColor` + `sBox` helpers (not module-level)

**Key patterns / gotchas:**
- `modIcon()` must use `createElementNS` — `el()` uses `document.createElement` which produces non-rendering SVG elements
- Mobile sidebar `position:fixed` in CSS; do NOT add `st:{position:...}` inline to the `<aside>` or it overrides the media query rule
- `STATE.showMobileNav` drives the drawer open/close state

**Still TODO (carried forward):**
- `kpi-evidence` Supabase Storage bucket — still not created
- Historical KPI data (Phase 2)
- Oncall Statistics tab visibility
- Deduplicate `currentQuarter`, `saveAtt`, `close`, `tick`

---

### Session — 10 Jul 2026 (Global page redesigns + leave fixes)

**Features built / improved:**

- **All remaining page redesigns** — Eventevia design system applied to every remaining render function using the same pattern established in `renderMorning` (terracotta eyebrow label + Playfair Display h1 + underline tabs):
  - `renderRota` — eyebrow "Rotation Schedule", both resident and PD branches updated, underline tabs
  - `renderTeaching` — eyebrow "Academic Program", "+ Add Session" CTA in header using `canEditTeachSchedule()`, block + period in subtitle
  - `renderQuiz` — eyebrow "Assessment", "+ New Quiz" CTA pill in header (PD only), stat count in subtitle; error state, detail view back link, and resident view all updated
  - `renderMentorHome` — eyebrow "My Portfolio", quarter pills replace card wrapper, section divider label replaces card-title
  - `renderLeave` — eyebrow "Leave Management", both resident and PD branches; tabs updated; pending count in subtitle
  - `renderCounseling` — eyebrow "Pastoral Care", both resident and PD branches updated
  - `renderMentorNotes` — eyebrow "Mentorship", "+ Add Note" CTA in header
  - `renderAdmin` — eyebrow "Administration", scrollable underline tabs (no `flexWrap`)
  - `renderBestResident` — eyebrow "Recognition", removed old icon-bubble div, underline tabs
  - `renderOncall` — eyebrow "On-Call Schedule", block pills inline (no card wrapper), underline tabs; fixed old `.active` class → `.on` pattern; added `blkPeriodOC` local var for subtitle

- **Leave Requests tab — Rota-Detected Leave section**: `renderLeaveRequests()` now also collects unapproved rota blocks from `LEAVE_DATA[r.id].rota` across all residents. Displays them in a gold-tinted "Rota-Detected Leave" section above formal pending requests. Each row shows resident, block number, date range, days, and an Approve button (calls `addManualLeave` with `"Rota leave B{n}"` comment). Previously only visible one-by-one in each resident's detail view.

- **Prev/Next navigation in leave detail view**: `renderLeaveDetail` now shows a nav bar at the top — `← Dr. Prev Name` · `N / Total` · `Dr. Next Name →`. Uses `visRes()` sorted list and `set({leaveSelRes:r.id})` to navigate. "← Back to List" link preserved on the left.

**Key patterns:**
- Page header pattern: `el("div",{st:{display:"flex",alignItems:"flex-start",...}}, el("div",null, eyebrow-div, h1, subtitle-div), optional-cta-button)`
- Underline tabs: `el("div",{st:{display:"flex",borderBottom:"1px solid rgba(31,26,18,.1)",...}}, ...items.map(t=>{const active=...; return el("div",{st:{borderBottom:"2px solid "+(active?"#c96a4a":"transparent"),...}})}))`
- Block pills (no card wrapper): inline `el("div",{st:{display:"flex",gap:"6px",flexWrap:"wrap",...}}, ...ROTA_PERIODS.map(...))`

**Still TODO (carried forward):**
- `kpi-evidence` Supabase Storage bucket — still not created
- Historical KPI data (Phase 2)
- Oncall Statistics tab visibility (PD decides when to open to other roles)
- Deduplicate `currentQuarter`, `saveAtt`, `close`, `tick`

---

### Session — 10 Jul 2026 (Deduplication + KPI quarterly redesign + Training Record page)

**Bugs / cleanup fixed:**
- **`currentQuarter` duplicate removed**: The version at line ~1441 (inside BEST RESIDENT HELPERS) was deleted. The authoritative version at line ~3705 (inside QUARTERLY KPI HELPERS) is the only one now. Both were functionally identical.
- **Dead functions removed**: `renderOngoing()` and `renderYearlyTab()` were defined but never called — both had been superseded by `renderOngoingNew()` and `renderYearlyNew()` in a prior session. Deleted ~85 lines of dead code.
- **`saveAtt`, `close`, `tick` are NOT global duplicates** — all are defined inside different render function closures, so they don't conflict at runtime. No action needed.

**KPI quarterly tab redesign:**
- `renderQuarterlyTab()` — quarter pills now terracotta-active; cold blue/green/yellow stat boxes replaced with a warm single parchment stat row (`statBox()` helper); milestone cards redesigned inline (no `.card` class).
- `renderQuarterlyKPICard()` (shown on Ongoing tab) — replaced 3 separate cold cards with a segmented parchment bar (3 slots side-by-side with dividers); Playfair Display numbers.
- `milestoneCard()` — dropped `.card` class; warm inline styling; goal text shown as italic quoted block (`"…"`); status pills use Eventevia pill style.

**Training Record page** (new module):
- **Mod id**: `cumulative_kpi` · **Label**: "Training Record" · **Roles**: `pd`, `deputy_pd`, `chief`
- Shows full academic history from `res.yearStarted` → `CURRENT_ACADEMIC_YEAR`, most recent year first.
- Each row: year label, inferred level badge (`R1`→`R4` based on current level), 6 achievement pills (green if earned via `kpi_proposals` or legacy `kpi_scores` flags, faint if not), committee score.
- Click row → expands to 2×2 quarter grid: each quarter shows Research Milestone + Area of Improvement text from `kpi_quarterly`, with "Achieved" marker if set.
- Current year row has "Full KPI" shortcut button → navigates to `mod:"kpi"`.
- PD gets a resident dropdown sorted by level; residents don't see this page.
- `loadCumulativeKpi(resId)` — single `Promise.all` fetching `kpi_scores`, `kpi_quarterly`, `kpi_proposals` for all years in range. Stores in `CUMULATIVE_KPI[resId][year]`. `CUMULATIVE_KPI_LOADING` flag prevents duplicate calls.
- State: `STATE.cumKpiRes` (selected resident), `STATE.cumKpiYear` (expanded year or null).

**Field key mapping note** (important for future edits):
- In `kpi_proposals`, `field_key` values are: `"publication"`, `"qi"`, `"oral"`, `"poster"`, `"awards"`, `"volunteering"`.
- In `kpi_scores` (legacy flags), columns are: `bonus_published`, `qi_participated`, `bonus_oral`, `bonus_poster`, `awards_honors`, `volunteering`.
- `loadCumulativeKpi` maps the legacy kpi_scores columns → proposal field keys when building the `approved` Set.

**Still TODO (carried forward):**
- `kpi-evidence` Supabase Storage bucket — still not created
- Historical KPI data 2024-25, 2023-24, 2022-23 — show as empty rows in Training Record; enter via Supabase or SQL
- Oncall Statistics tab visibility (PD decides when to open to other roles)

---

### Session — 10 Jul 2026 (Consolidation + quick wins + medium-impact UX)

**Consolidation fixes (low-risk, high-value):**
- `loadQuizzes()` added to `init()` — quizzes now load on page refresh, not only after fresh login
- Dead `renderNav()` function removed (returned null, legacy)
- `init()` catch block now renders a visible "Failed to load — Retry" screen instead of silent console.error
- `STATE.user.*` direct mutations (`username`, `name`, `contactEmail`) replaced with `set({user:{...STATE.user,...}})` so sidebar updates immediately after save
- `renderBlockPills(selected, onSelect, opts)` helper extracted — replaces 7 copy-pasted `ROTA_PERIODS.map()` pill rows across MM, Teaching, and Oncall modules. `opts.cur` adds current-period outline; `opts.inactiveBg` sets non-selected background; `opts.st` adds wrapper styles

**kpi-evidence bucket (security):**
- Bucket created as **private** (not public)
- `uploadKpiFile()` now stores storage **path** instead of public URL
- `getKpiFileUrl(fileRef)` generates a 1-hour signed URL on demand via `createSignedUrl()`
- `renderProposalDetails()` "View uploaded file" is now an async button (fetches fresh signed URL on click)
- Legacy full-URL entries in `note.fileUrl` are auto-converted to path before signing

**Quick wins (UX):**
- Search result limits raised: residents 4→8, quizzes/MM/teaching 3→5
- `leaveOverlaps(residentId, from, to)` helper — blocks residents from submitting duplicate leave periods; warns PD when adding overlapping manual leave
- `brCastVote()` now guards `!brVotingIsOpen()` server-side (was UI-only before)
- Mentor Notes module unlocked for `resident` role — residents see their own Strength / Improvement / Interest notes read-only; Concern notes remain hidden

**Medium-impact improvements:**
- Modal CSS: `width:100%!important;max-width:100%!important` in `<600px` media query — inline `st:{width:"Npx"}` can no longer override on mobile
- Activity log (`renderActivityLog()`): resident name text filter + action type dropdown; `STATE.actLogRes`, `STATE.actLogAction`
- PD Overview (`renderPDOverview()`): `counselBox` — amber flag section listing residents with 2+ counseling records as clickable pills → navigates to their counseling drawer
- Rota import (`commitRotaImport()`): leave conflict check before committing — warns with resident names and "Commit Anyway" escape hatch via `showConfirm()`
- KPI Ongoing tab (`renderOngoingNew()`): per-block attendance trend — mini bar chart showing MM (solid) and Teaching (faded) % per block, color-coded green/amber/red, scrollable
- Mentor home (`renderMentorHome()`): per-quiz score breakdown for current quarter — mini progress bars per published quiz below the stat grid

**Key helpers / patterns added:**
- `renderBlockPills(selected, onSelect, opts)` — module-level, near `sortByLevel()`
- `leaveOverlaps(residentId, from, to)` — module-level, before `addManualLeave()`
- `getKpiFileUrl(fileRef)` — module-level, after `uploadKpiFile()`
- `STATE.actLogRes`, `STATE.actLogAction` — activity log filter state keys

**Still TODO (carried forward):**
- Historical KPI data 2024-25, 2023-24, 2022-23 — data entry in Supabase
- Oncall Statistics tab visibility — PD decides when to open to other roles
- `renderKPI()` split (~456 lines) — deferred; tackle when editing that function for another reason
- `renderAdminProfile()` split (~223 lines) — same

---

### Session — 11 Jul 2026 (Annual Leave Plan module for AY 2026-27)

**Features built:**

- **Annual Leave Plan module** (mod id: `leave_plan`, roles: all). Planning-only module for AY 2026-27 leave allocation — entirely separate from `leave_records`.
  - **Resident view**: Deadline countdown banner (18 Jul 2026 midnight). Full list of 26 pre-set half-block periods (B1 1st half → B13 2nd half) grouped by block with exact dates. Resident picks **First Leave** and **Second Leave** — one period each, 2 weeks each = 4 weeks total.
    - Same-block rule: cannot pick both periods from the same block (JS-enforced with toast warning)
    - Blocks 1 & 2 locked for R1s (orientation — "not available" pill shown)
    - Save Draft saves without submitting; Submit requires both periods selected
    - After submission: form locks, shows green confirmation bar
    - Optional note to PD textarea (uses `_lpNoteDraft` module-level variable to survive re-renders)
  - **PD / privileged matrix view** (tab: "All Residents"): Summary strip (submitted count, missing, over-cap periods, deadline status). Resident × 26-period dot matrix — terracotta dot = First Leave, green dot = Second Leave. Bottom cap row shows count per period, red +N badge when > LP_CAP (4). "Send Reminder" button (toast), "Push to Rota — available Oct 2026" button (disabled placeholder).
  - **Access control**: `canManage = isPdRole || chief || hasPriv('plan_rota')`. Regular residents see only their own form. Deema Bakhashab + Abdullah Fared get full matrix via `plan_rota` privilege (grant via Admin Panel).

**New Supabase table:** `leave_plan` — migration at `supabase/add_leave_plan.sql` (**run this in Supabase**).
  - Columns: id (uuid), resident_id (bigint FK), academic_year (int, default 2026), first_leave_key/block/half/from/to, second_leave_key/block/half/from/to, note, status ('draft'|'submitted'), submitted_at, created_at, updated_at.
  - UNIQUE(resident_id, academic_year).
  - RLS: all authenticated SELECT; write via `app_resident_id()` (own row) or pd/deputy_pd/chief/dio role.

**New privilege:** `plan_rota` — "View all residents leave plan & manage AY rota planning" — added to `PRIV_LABELS_RESIDENT`.

**Key constants/globals/functions:**
- `LP_AY=2026`, `LP_CAP=4`, `LP_DEADLINE=new Date("2026-07-18T23:59:59")`
- `LP_PERIODS` — array of 26 period objects: `{key, blk, half, label, from, to, disp, r1lock?}`
- `LEAVE_PLAN={}` — `{resident_id: row}` — loaded by `loadLeavePlan()` on init
- `_lpNoteDraft` — module-level note draft (avoids render on typing)
- `saveLeavePlan(status)` — upserts to `leave_plan` table with `onConflict:"resident_id,academic_year"`
- `renderLeavePlan()` — main module function
- STATE keys: `lpFirstKey` (string|null|undefined), `lpSecondKey` (string|null|undefined), `lpTab` ("mine"|"all")
- Nav resets: both sidebar and home-grid clicks set `{lpFirstKey:undefined,lpSecondKey:undefined,lpTab:undefined}` so navigating back always re-reads from DB

**Design decisions:**
- Leave plan data is completely separate from `leave_records` — it's planning only
- "Push to Rota" button will become active in Oct 2026 when AY starts; for now it's a disabled placeholder
- Period key format: `"6a"` = Block 6 First Half, `"6b"` = Block 6 Second Half

**Still TODO (carried forward):**
- **Run `supabase/add_leave_plan.sql`** in Supabase SQL editor (table not yet created)
- **Grant `plan_rota` privilege** to Deema Bakhashab and Abdullah Fared via Admin Panel
- Historical KPI data 2024-25, 2023-24, 2022-23 — data entry in Supabase
- Oncall Statistics tab visibility — PD decides when to open to other roles
- New AY master rota: promote current residents (Oct auto-promotion handles R1→R2→R3→R4), archive graduating R4s, create 15 placeholder R1 residents with codes (NR1-01 to NR1-15), import new rota via Excel wizard
- "Push to Rota" in leave_plan — implement in Oct 2026 to convert leave_plan rows into leave_records
