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
RESIDENTS       // [{id, name, user, level, ph, yearStarted, chiefRole}]
CONSULTANTS     // [{id, name, user}]
MENTORS         // {resident_id: consultant_id}
FULL_ROTA       // {resident_id: {block_number: rotation_name}}
MM_SESSIONS     // [{id, block_number, session_date, topic, presenter_resident_id, moderator_resident_id}]
TEACH_SESSIONS  // [{id, block_number, session_date, topic, presenter_label}]
MM_ATT          // {block: {date: {resident_id: status}}}   status = P|L|A|E|O
MM_ATT_CMT      // {block: {date: {resident_id: comment}}}
TEACH_ATT       // same shape as MM_ATT
TEACH_ATT_CMT   // same shape as MM_ATT_CMT
QUIZZES         // [{id, title, max, published, sc: {resident_id: score}}] — DB-backed via quizzes + quiz_scores tables
KPI_SCORES      // {resident_id: {commScore, researchDone, qiDone, bonusPublished, bonusOral, bonusPoster}}
LEAVE_DATA      // {resident_id: {rota:[], manual:[], absences:[], requests:[]}}
LEAVE_PENDING_COUNT  // int — pending leave requests for PD home alert
COUNSEL_CACHE   // {resident_id: [records] | null (loading) | undefined (not loaded yet)}
MENTOR_NOTES    // {resident_id: [notes]}
ANNOUNCEMENTS   // [{id, title, description, deadline_date, category, target_all, target_level, target_resident_id}]
ACCOUNT_PRIVS   // {profile_id: Set(privilege_key)}
PROMOTION_NEEDED // bool — set by checkPromotionNeeded() on PD login in Oct–Dec
```

---

## Supabase Tables

| Table | Purpose |
|---|---|
| `profiles` | Auth link, role, username, display_name |
| `residents` | Resident records (name, level, mentor_id, active) |
| `consultants` | Mentor records |
| `account_privileges` | Per-profile privilege flags (e.g. `edit_mm_attendance`) |
| `mm_sessions` | Morning meeting schedule |
| `mm_attendance` | MM attendance per session per resident (`status`, `comment`) |
| `teaching_sessions` | Teaching session schedule |
| `teaching_attendance` | Teaching attendance (`status`, `comment`) |
| `rotations` | Full rota grid (resident_id, block_number, rotation_name) |
| `kpi_scores` | Manual KPI fields (committee score, research, QI, bonuses) |
| `quizzes` | Quiz metadata (title, date, max_score, block_number, published, assigned_mentor_id) |
| `quiz_scores` | Per-resident quiz marks (quiz_id, resident_id, score) |
| `leave_records` | All leave types: `manual`, `unapproved_absence`, `leave_request`, `leave_rejected` |
| `counseling` | Counseling records (includes countersign fields — see SQL migration below) |
| `mentor_notes` | Mentor observations (type: strength/improvement/interest) |
| `announcements` | PD-set deadlines/tasks with targeting |
| `promotion_log` | Annual promotion history — one row per academic year |

**Attendance status values:** `P` (Present) · `L` (Late) · `A` (Absent) · `E` (Excused) · `O` (On Leave)

---

## Features Built (Complete)

### Authentication & Accounts
- Supabase Auth with synthetic emails (`username@dsfh.local`)
- Real login replacing hardcoded passwords
- Username change UI in account modal
- Per-resident privilege system (`account_privileges` table)

### Rota
- Full rota grid — imported from Excel via SheetJS
- Block view, timeline view, full table view
- Rotation tracker showing where each resident is

### Morning Meetings & Teaching
- Schedule management (add/edit/delete sessions)
- Attendance logging with 5 statuses (P/L/A/E/O)
- Comment field per resident per session (for committee members)
- MM overview table (all residents × all sessions)
- **Export to Excel** — "⬇ Export Excel" button in Attendance Table card header (both MM and Teaching)

### KPI Dashboard
- Calculates: quiz avg, MM %, teaching %, presentation, committee, research, QI, bonus
- Per-resident quarterly KPI card
- PD/mentor can edit manual scores

### Quiz Marks
- Add/edit/delete quizzes (with delete confirmation)
- Publish/unpublish scores
- Per-resident mark entry
- **Bulk import from Excel** — "⬆ Import Excel" in Resident Marks header (PD/assessor only); Col A = name, Col B = score

### Annual Leave
- Rota-detected leave blocks
- Manual leave addition (Annual + Educational, 28d/7d quotas)
- Leave Request Flow: residents submit → PD approves/rejects → status shown
- Pending request count shown on PD home screen as alert
- Unapproved absences tracking
- **Date validation:** rejects requests where 'To' is before 'From'

### Counseling
- Add/edit/delete counseling records
- **Countersign flow:** resident receives red banner → clicks → sees record → clicks "Countersign / Acknowledge" → record locks with timestamp
- PD sees Pending/Countersigned badge per record
- Alert levels: green/yellow/red based on record count
- ⚠️ Requires SQL migration — see `supabase/add_counseling_countersign.sql`

### Mentor Notes
- Table view: rows = residents, columns = Strength / Improvement / Interest
- Bulk loaded in one query
- Only visible to PD + the writing mentor

### Calendar (.ics Download)
- Rotation blocks (4-week all-day events)
- Approved leave blocks
- MM presentations + moderator duties (timed 7–9am)
- Announced deadlines (all-day on due date)

### Announcements / Deadlines
- PD creates: title, category, deadline, description, targeting (all/level/resident)
- Resident home screen shows upcoming deadlines (next 30 days)
- Included in .ics download
- Admin Panel → "Deadlines & Tasks" tab

### PD Overview Dashboard
- Summary cards: total residents, avg KPI, at-risk count, with-counseling count
- Full resident table with KPI, MM%, Teaching%, Quiz%, counseling count
- At-risk highlight box (any metric < 60%)
- Filter by level, sort by any column

### October Auto-Promotion
- On PD login during Oct–Dec: checks `promotion_log` for current academic year
- If not found, shows yellow alert on home screen
- Modal: all residents with current → proposed level (R1→R2, R2→R3, R3→R4, R4→Archive)
- Per-resident skip toggle; "Confirm" updates `residents.level`, inserts `promotion_log` row
- ⚠️ Requires SQL migration — see `supabase/add_promotion_log.sql`

### Admin Panel
- Residents: add/edit/archive/create login
- Mentors: add/edit/assign/create login
- Accounts: list all accounts, privilege grid
- Deadlines & Tasks: manage announcements
- Import Rota: Excel import wizard

### UI / Design
- Warm cream sidebar (`#ede5d8`) with terracotta accents (`#c96a4a`)
- Mobile topbar for small screens
- Account modal with username change + password change

---

## SQL Migrations (in `supabase/` folder)

| File | Status | Purpose |
|---|---|---|
| `fix_attendance_status_constraint.sql` | ✅ Run | Allow E and O statuses |
| `add_attendance_comments.sql` | ✅ Run | Add comment column to attendance tables |
| `fix_residents_attendance_rls.sql` | ✅ Run | RLS fix for privileged residents |
| `add_announcements.sql` | ✅ Run | Announcements/deadlines table |
| `add_counseling_countersign.sql` | ⏳ **NOT RUN YET** | Countersign columns + RPC on counseling table |
| `add_promotion_log.sql` | ⏳ **NOT RUN YET** | promotion_log table for October auto-promotion |

---

## Known Bugs / Gotchas (avoid repeating these)

- **CDN pinning:** Supabase JS is pinned to `@2.39.0` — do NOT change to `@2` (unpinned). Newer versions broke `window.supabase`.
- **async callbacks:** Any callback that uses `await` must be declared `async`. Missing `async` on `reader.onload` caused a site-wide crash (fixed Jul 2026).
- **init() has try-catch:** `(async function init(){...})()` is wrapped in try-catch so render() always runs.
- **GitHub Actions:** Custom deploy workflow at `.github/workflows/deploy.yml` retries 3x — don't remove it.
- **After every change:** `cp SFH_Residency_Portal.html index.html` then commit+push both files.

---

## Features Pending (Build These Next)

### 1. Quiz Persistence Verification
Quizzes ARE DB-backed (`loadQuizzes()` fetches from `quizzes` + `quiz_scores`). The tables need to exist in Supabase. If they don't, run the relevant section of `schema.sql`.

### 2. KPI Report / PDF Export
PD can export a resident's full KPI summary as a printable PDF or formatted report.

### 3. Bulk Resident SMS/Email Notifications
PD can push an announcement to all residents via a notification channel.

### 4. Search / Global Filter
Global search bar in sidebar to quickly jump to any resident, session, or quiz.

---

## Workflow for New Sessions

1. Read this file first
2. Read `SFH_Residency_Portal.html` around the relevant function before editing
3. Make changes to `SFH_Residency_Portal.html`
4. `cp SFH_Residency_Portal.html index.html`
5. `git add SFH_Residency_Portal.html index.html && git commit -m "..." && git push origin main`
6. GitHub Pages auto-deploys in ~1 min
7. **Update this file** if new features are added or status changes

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
render(); // or set({}) to trigger re-render

// Color helpers:
kpiColor(v) // v>=80 green, v>=60 amber, v<60 red (defined locally in functions)

// Modal overlay pattern (reuse existing CSS):
el("div",{cls:"modal-overlay",onClick:e=>{if(e.target===e.currentTarget)close();}},
  el("div",{cls:"modal-card",st:{width:"500px",maxWidth:"100%"}}, ...content...)
)
// Inject into render() before appendAccountModal(app):
if(STATE.showMyModal) app.appendChild(renderMyModal());
```
