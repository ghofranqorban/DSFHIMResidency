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

### 1. Cumulative KPI Page (planned, not built)
Planned design:
- Shows each resident's full training history (PGY-1 through PGY-4)
- Grid of academic years — click a year → expands to: Yearly KPI achievements (visual badges/icons) → 4 quarters → click a quarter → Ongoing performance details (MM%, Teaching%, Quiz%)
- Data sources: `kpi_scores` (yearly per academic_year) · `kpi_quarterly` (quarterly) · attendance/quiz (already in DB by block → map to academic year)
- Add to MODS array with roles `["pd","deputy_pd","chief"]`

### 2. KPI Page Redesign (discussed, not built)
- User wants a full visual redesign of the KPI dashboard page — agreed to do after proposal flow was finished
- Current design works but feels cluttered; user wants a cleaner, more modern layout

### 3. Supabase Storage bucket needed
- Create bucket named `kpi-evidence` (public) in Supabase for KPI file uploads
- Without it, file upload in proposal modal fails gracefully (text still submits fine)

### 4. ~~Quiz Persistence~~ ✅ Done (error banner added)
### 5. ~~KPI PDF Export~~ ✅ Done
### 4. ~~Global Search~~ ✅ Done
### 5. ~~Bulk Broadcast~~ ✅ Done

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
