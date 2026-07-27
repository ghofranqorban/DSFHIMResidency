# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

## Users

**Program leadership (primary design audience).** The Program Director, Deputy PD, Chief Residents, the DIO (Dr. Arwa Jamal), and the CEO (Dr. Sohail Bajammal) use the portal to run and to *present* the residency program. The scene future design work optimizes for first is a leadership presentation: the Performance Report shown on a large screen to hospital executives, where the program's health has to read instantly and look credible.

**Residents (largest population, heaviest day-to-day use).** R1–R4 internal medicine residents check their rota, on-call assignments, attendance, quiz marks, KPI standing, leave, and counseling records between clinical duties. They also submit work into the system: leave requests, KPI achievement proposals with evidence files, next-year leave and GIM rotation preferences, and Best Resident votes.

**Consultants / mentors.** See only their assigned mentees. They set quarterly research milestones and improvement areas, write private mentor notes, and submit achievements on a mentee's behalf.

Access is role-gated (`pd`, `deputy_pd`, `chief`, `consultant`, `resident`, `dio`, `ceo`) with a per-account privilege layer on top, so individual residents can be granted specific editing rights (e.g. attendance committee members, rota planners) without a role change.

## Product Purpose

A single web portal for the Dr. Sulaiman Fakeeh Hospital Internal Medicine residency program that replaces scattered spreadsheets, PDFs, and WhatsApp threads as the program's system of record. It holds the rota, on-call schedule, morning-meeting and teaching attendance, quiz marks, KPI scoring, annual leave, counseling records, mentor notes, announcements, and the year-over-year training record.

Success is that one number — a resident's or the program's performance — comes from one place, is defensible when leadership asks, and is visible to the resident themselves without anyone re-keying it.

## Positioning

The portal's distinguishing mechanism is that **evaluation is a by-product of daily operations, not a separate exercise.** Attendance logged for a morning meeting, a quiz mark entered, a session presented — each feeds the same KPI weight table (`KPI_W`) that produces the ongoing 50% score, the Best Resident ranking, and the executive Performance Report. Nothing is computed twice from a different source. A generic residency-management tool records activity; this one derives the program's published performance directly from it.

Second differentiator: it is built for *this* program's actual rules — 13 four-week blocks, P/L/A/E/O attendance semantics where outside-rotation days are excluded rather than penalized, per-period leave caps with first/second preference and PD adjudication, GIM rotation preference windows the Chief opens and closes themselves.

## Operating Context

- **Academic year in 13 blocks of 4 weeks.** Nearly every module is block-scoped; a block picker is a recurring interface primitive.
- **Attendance statuses** `P` Present · `L` Late (half credit) · `A` Absent · `E` Excused (full credit) · `O` Outside rotation (excluded from the denominator entirely). Unlogged days are also excluded.
- **Scheduling artifacts arrive as files, not data** — rota and morning-meeting schedules come in as Excel workbooks, PDFs, and phone screenshots (see `/Users/drghof/Documents/Residents dsfh/25-26/`). An in-app import feature was attempted three separate ways and rejected each time; schedules are now entered by sending the source file to Claude in chat for direct insertion. Do not rebuild an import feature without fresh explicit buy-in.
- **Approval flows are real workflow, not decoration.** KPI achievements, leave requests, counseling countersignatures, and next-year leave periods all move through a submit → PD review → approved state that other views depend on.
- **Calendar subscription** via a Supabase edge function serving `.ics`; residents add it manually as a subscribed calendar (no `webcal://` scheme, no `.mobileconfig` — both were tried and abandoned).
- **Deployment is push-to-live.** Commits to `main` deploy to GitHub Pages within about a minute; there is no staging environment and the users are the real program.

## Capabilities and Constraints

**Modules currently live:** Rota Schedule · On-Call Schedule · Rotation Tracker · Morning Meetings · Teaching Attendance · Performance Report (executive) · KPI Dashboard · Quiz Marks · Annual Leave · Counseling · Mentor Notes · PD Admin Panel · Overview Dashboard · Training Record · Best Resident · AY Plan 26-27.

**Hard technical constraints:**
- **One HTML file, no build step, no npm, no framework.** All JS and CSS inline in `SFH_Residency_Portal.html`, mirrored to `index.html` for deploy. A single JS syntax error anywhere blanks the entire site with no visible error — syntax must be validated before every commit.
- **Custom DOM builder `el()` and full-rebuild `render()`.** No innerHTML, no diffing; every state change rebuilds the DOM. Direct DOM mutations are lost on the next render. `el()` is not SVG-namespace-aware — icons go through `modIcon()`.
- **Supabase JS pinned to `@2.39.0`** — newer versions break the global client.
- **Backend is Supabase Postgres with Row Level Security.** Schema changes ship as `.sql` files in `supabase/` that the user runs manually in the SQL Editor; there is no mechanism for executing DDL programmatically.
- **Must run on older hospital-issued PCs and browsers.** Weight, animation cost, and modern-CSS dependence are real constraints, not preferences.

**Undecided / open:**
- Whether the On-Call Statistics tab opens beyond PD.
- Whether the Leave Plan deadline extends past 18 Jul 2026.
- Historical KPI data for 2024-25, 2023-24, 2022-23 — no ETA; those years show "Under Progress".

## Brand Commitments

- **Name:** DSFH Internal Medicine Residency Portal (Dr. Sulaiman Fakeeh Hospital).
- **Names in data carry the "Dr." prefix** and are stripped for display via `dname()`/`ini()`.
- A warm terracotta/cream visual world is already established and documented separately; product work should not treat the interface as visually greenfield.
- No hospital logo asset is currently in the build — the login mark is typographic.

## Evidence on Hand

- `CLAUDE_CONTEXT.md` — 1,250-line engineering and decision record, including a dated session log and the full SQL migration status table. Authoritative for technical history.
- Live production data in Supabase: real residents, real attendance, real KPI scores, real leave records. Nothing needs to be mocked, and nothing may be fabricated.
- Source scheduling artifacts (rota spreadsheets, on-call block images, morning-meeting screenshots) in `/Users/drghof/Documents/Residents dsfh/25-26/`.
- **Absent — do not invent:** there are no testimonials, no benchmark comparisons against other residency programs, no accreditation claims, no pricing or licensing, and no published outcome statistics. Historical KPI data for years before 2025-26 does not exist in the system.

## Product Principles

1. **One source per number.** Any score, percentage, or ranking shown anywhere must derive from the same computation as everywhere else. Duplicated weight logic has silently mis-scored residents before.
2. **Absence of data is not zero.** Unlogged and outside-rotation days are excluded, not counted against a resident; a resident with no attendable days shows "N/A", never 100% and never 0%.
3. **A resident can see what is recorded about them.** Evaluation is transparent to its subject, with countersignature where the record is formal.
4. **The program's rules win over generic patterns.** Blocks, attendance semantics, leave caps, and preference windows are the domain's actual shape — bend the interface to them.
5. **Presentable under scrutiny.** Leadership-facing views must hold up on a projector in front of executives, and any figure shown must be traceable back to its inputs.

## Accessibility & Inclusion

- **English-only UI today; Arabic and RTL are a planned future requirement.** Do not introduce anything that would block an RTL flip — avoid hard-coded left alignment, directional margins where logical properties work, and layouts that assume left-to-right reading order.
- **Must remain usable on older hospital PCs and browsers** — no reliance on bleeding-edge CSS or heavy runtime animation as a load-bearing part of any view.
