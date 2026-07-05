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
| `add_counseling_countersign.sql` | ⏳ **NOT RUN** | Countersign columns + RPC on counseling |
| `add_promotion_log.sql` | ⏳ **NOT RUN** | promotion_log table |
| `add_kpi_quarterly_proposals.sql` | ⏳ **NOT RUN** | kpi_quarterly + kpi_proposals tables; awards_honors + volunteering columns on kpi_scores |

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

### 2. ~~Quiz Persistence~~ ✅ Done (error banner added)
### 3. ~~KPI PDF Export~~ ✅ Done
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
