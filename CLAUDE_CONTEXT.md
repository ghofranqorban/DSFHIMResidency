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
QUIZZES         // [{id, title, max, published, sc: {resident_id: score}}]
KPI_SCORES      // {resident_id: {commScore, researchDone, qiDone, bonusPublished, bonusOral, bonusPoster}}
LEAVE_DATA      // {resident_id: {rota:[], manual:[], absences:[], requests:[]}}
LEAVE_PENDING_COUNT  // int — pending leave requests for PD home alert
COUNSEL_CACHE   // {resident_id: [records] | null (loading) | undefined (not loaded yet)}
MENTOR_NOTES    // {resident_id: [notes]}
ANNOUNCEMENTS   // [{id, title, description, deadline_date, category, target_all, target_level, target_resident_id}]
ACCOUNT_PRIVS   // {profile_id: Set(privilege_key)}
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
| `quizzes` | Quiz metadata |
| `quiz_scores` | Per-resident quiz marks |
| `leave_records` | All leave types: `manual`, `unapproved_absence`, `leave_request`, `leave_rejected` |
| `counseling` | Counseling records |
| `mentor_notes` | Mentor observations (type: strength/improvement/interest) |
| `announcements` | PD-set deadlines/tasks with targeting |

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
- **Comment field per resident per session** (for committee members)
- MM overview table (all residents × all sessions)

### KPI Dashboard
- Calculates: quiz avg, MM %, teaching %, presentation, committee, research, QI, bonus
- Per-resident quarterly KPI card
- PD/mentor can edit manual scores

### Quiz Marks
- Add/edit/delete quizzes
- Publish/unpublish scores
- Per-resident mark entry

### Annual Leave
- Rota-detected leave blocks
- Manual leave addition (Annual + Educational, 28d/7d quotas)
- **Leave Request Flow:** residents submit requests → PD approves/rejects → status shown to resident
- Pending request count shown on PD home screen as alert
- Unapproved absences tracking

### Counseling
- Add/edit/delete counseling records
- Basic acknowledgement (acked boolean)
- Alert levels: green/yellow/red based on record count

### Mentor Notes
- Table view: rows = residents, columns = Strength / Improvement / Interest
- Bulk loaded in one query
- Only visible to PD + the writing mentor

### Calendar (.ics Download)
- Rotation blocks (4-week all-day events)
- Approved leave blocks
- MM presentations + moderator duties (timed 7–9am)
- Announced deadlines (all-day on due date)
- Button: resident Rota view + Admin → Profile → Rota tab

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
- Click row → jumps to resident's KPI tab

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

## Features Pending (Build These Next)

### 1. Counseling Countersign Flow ← **RECOMMENDED NEXT**
When PD issues a counseling record, the resident must formally acknowledge it (not just the current `acked` boolean). The countersign should:
- Add `acknowledged_by` (profile_id) and `acknowledged_at` (timestamp) fields to `counseling` table
- Resident sees a red banner on their home screen: "You have a counseling record requiring your signature"
- Clicking it shows the record and an "I Acknowledge" button
- Once signed: locked (can't be edited), shows timestamp + who signed
- PD sees signed/unsigned status in the counseling view
- SQL needed: `ALTER TABLE counseling ADD COLUMN acknowledged_by uuid REFERENCES auth.users(id); ALTER TABLE counseling ADD COLUMN acknowledged_at timestamptz;`

### 2. October Auto-Promotion Review
- On PD login after Oct 1 of a new academic year, show a promotion review screen
- R1→R2, R2→R3, R3→R4, R4→archived
- Add incoming R1 class
- Log in `promotion_log` table so it doesn't re-prompt

### 3. Quiz Bulk Import
- Import quiz marks from Excel in the Quiz Marks module

### 4. Attendance Export
- Export attendance sheet to Excel per block

---

## SQL Migration Files (in `supabase/` folder)

| File | Status | Purpose |
|---|---|---|
| `fix_attendance_status_constraint.sql` | ✅ Run | Allow E and O statuses |
| `add_attendance_comments.sql` | ✅ Run | Add comment column to attendance tables |
| `fix_residents_attendance_rls.sql` | ✅ Run | RLS fix for privileged residents |
| `add_announcements.sql` | ✅ Run | Announcements/deadlines table |

---

## Workflow for New Sessions

1. Read this file first
2. Read `SFH_Residency_Portal.html` around the relevant function before editing
3. Make changes to `SFH_Residency_Portal.html`
4. `cp SFH_Residency_Portal.html index.html`
5. `git add SFH_Residency_Portal.html index.html && git commit -m "..." && git push origin main`
6. GitHub Pages auto-deploys in ~1 min
7. Update this file if new features are added or status changes

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
```
