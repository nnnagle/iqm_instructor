# How this project is organized

This folder is your **project** for the whole semester. You will keep working in
it lab after lab — you never start over. Keeping the structure below intact is
what makes your work reproducible and what lets you and your teammates move work
between projects without anything breaking.

## The folders

```
<project>/
├── <project>.Rproj      Open THIS in RStudio. It sets the working directory.
├── 00_setup.R           Packages and options. Run first each session.
├── 01_get_data.R        Your numbered scripts, in run order.
├── 02_...               (more scripts appear as the semester goes)
├── README.md            What the project is; how to run it.
├── PROJECT_STRUCTURE.md This file.
├── CHANGELOG.md         One short entry per lab: what changed and why.
├── data_raw/            Source data, EXACTLY as downloaded. Never edited by hand.
├── data_processed/      Data your scripts create. Safe to delete and rebuild.
├── R/                   Reusable helper functions you write (not top-level scripts).
├── figures/             Saved maps and plots (code generates these).
├── tables/              Saved tables.
├── metadata/            Source inventory, data dictionary, provenance notes.
└── report/             Rendered deliverables (your Quarto documents and PDFs).
```

## The two rules everything depends on

1. **Open the `.Rproj`, and use only relative paths** like
   `"data_raw/tn_acs_starter.csv"` — never `"C:/Users/you/..."` or
   `"/Users/you/..."`. Because every path is relative to the project root, the
   project runs the same on your laptop, a teammate's laptop, or a lab machine.
2. **Raw data is read-only.** Everything else — every join, rate, score, model,
   figure, table — is produced by a script and written to `data_processed/`,
   `figures/`, etc. If you can't rebuild it by re-running your scripts, it isn't
   done.

## Your individual project and the team project are the same shape

Your personal copy and your team's shared project use this **identical**
structure. That is deliberate: because the folders and relative paths match,
you can copy work from one into the other and it just runs — no path edits.

**Copying INTO your project** (e.g. Lab 8 says "start from the team's project as
it stood at the end of Lab 7"): copy the team project's files into the matching
folders of your project (or copy the whole project folder and open its
`.Rproj`). Same paths, so your scripts find everything.

**Copying OUT to the team project** (e.g. your Lab 6 turned out great and the
team wants it): copy the specific files you changed — a script from the root or
`R/`, an output in `data_processed/`, a figure — into the **same locations** in
the team project. Then re-run from a clean session to confirm it still builds.

### Rules that keep copying safe

- **Copy whole files to matching paths.** Don't hand-merge two versions of a
  script line by line — you will lose work. Replace the file, run it, check.
- **Only one person edits a given file at a time** in the shared project.
- **Add a `CHANGELOG.md` line** whenever you move something in: what you copied,
  from where, and why.
- **Never copy these:** your Census API key (it lives in `~/.Renviron`, never in
  the project) and the `.Rproj.user/` folder (that's just your local RStudio
  state). `data_raw/` is pinned and identical everywhere, so it rarely needs
  copying at all.
