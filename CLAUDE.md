# DSFH IM Residency Portal

> Auto-loaded every session. Full detail lives in `CLAUDE_CONTEXT.md` — read
> that in full before touching any code.

## What this is

Single-page web app for the Dr. Sulaiman Fakeeh Hospital IM residency
program: rotations, KPIs, attendance, leave, counseling, mentor notes.

## Where things are

```
Residents/
├── SFH_Residency_Portal.html   # the app — all JS/CSS inline, this is the source of truth
├── index.html                   # GitHub Pages copy — must always mirror the file above
├── CLAUDE_CONTEXT.md            # full session context — read in full first
├── DESIGN.md
├── PRODUCT.md
└── supabase/                    # SQL migrations
```

## Rules

- Read `CLAUDE_CONTEXT.md` in full, and check your memory files, before
  making any code change or doing anything else.
- Run the JS syntax check before and after every change (command is in
  `CLAUDE_CONTEXT.md`).
- After every code change: run the JS syntax check, then
  `cp SFH_Residency_Portal.html index.html`, then
  `git add SFH_Residency_Portal.html index.html && git commit && git push origin main`.
- Check in before pushing design changes or major edits.
- Don't remove `.nojekyll` — breaks GitHub Pages.
