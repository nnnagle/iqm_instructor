# GEOG 415 — Instructor Build

The **instructor side** of GEOG 415. This repo is a build system, not course
content: it takes authored source and public data as **input** and produces the
**output** distributed to students for each lab — data files and a handout,
delivered as a ready folder and a matching `.zip`.

The course is one cumulative, semester-long project: a **Community Primary Care
Priority Rating** for Tennessee census tracts, built from public data across 12
labs. See [`docs/`](docs/) for the design and the session-by-session map.

## Input → output

```
INPUT (authored, versioned here)          OUTPUT (generated, handed to students)
  config.R          pinned vintages          dist/<year>/lab01/GEOG415_Project/  (+ .zip)
  data/*.R          acquire + clean          dist/<year>/lab01/lab01_handout.pdf
  labs/<lab>/       handout + templates      dist/<year>/lab02/project_files.zip
  R/                shared helpers           dist/<year>/lab02/lab02_handout.pdf
```

`dist/` and `data/build/` are generated and git-ignored. `data/processed/` (the
cleaned, pinned canonical data) may be committed so the repo is a self-contained
record of a given year.

## Layout

```
config.R              # SINGLE source of truth: state, year, pinned vintages, variables
build.R               # driver: builds canonical data, then each lab -> dist/
R/                    # shared helpers (Census API, IO, packaging)
data/
  acs.R  tiger.R      # acquire + clean each public source -> data/processed/<year>/
  analytic.R          # analysis-ready candidate-indicator table (shipped in Lab 3)
  build/<year>/       # raw downloads + provenance (git-ignored)
  processed/<year>/   # cleaned canonical data, shared by all labs
labs/
  lab01/
    manifest.R        # what this lab ships
    build.R           # assembles this lab's student package
    handout/lab01.qmd # student handout (Quarto)
    templates/        # .Rproj boilerplate, 00_setup.R, student README
dist/<year>/          # student packages (git-ignored)
docs/                 # semester map + project plan
```

## Requirements

R plus:

```r
install.packages(c("sf", "dplyr", "readr", "jsonlite"))
```

[Quarto](https://quarto.org) is used to render handouts to PDF/HTML. If Quarto
is not on `PATH`, the build copies the `.qmd` source into the package instead of
rendering it.

The Census Data API requires a free key. Get one at
<https://api.census.gov/data/key_signup.html>, then set it before building:

```sh
export CENSUS_API_KEY='YOUR_KEY_HERE'   # or add CENSUS_API_KEY=... to ~/.Renviron
```

Do not commit the key or ship it in a student package.

## Build

```sh
Rscript build.R          # build all implemented labs (currently lab01)
Rscript build.R lab01    # build one lab
```

The canonical data are built once and reused. Delete `data/processed/<year>/`
to force a re-download.

## Refreshing for a new academic year

1. In `config.R`, bump `academic_year`.
2. Set `acs_year` / `tiger_year` to `NA` and build once to see the newest
   available vintages; inspect the result.
3. **Pin** `acs_year` and `tiger_year` to the tested vintages so the data cannot
   silently change once students have started using them.
4. Rebuild, then verify the package on the classroom R/RStudio setup: open the
   `.Rproj`, run `00_setup.R`, read both data files, do the join, make the first
   map.
5. Distribute from `dist/<year>/lab01/`: the `GEOG415_Project.zip` (or the folder)
   is the student project; `lab01_handout.pdf` is the handout.

## Distribution model

Each lab's outputs live under `dist/<year>/<lab>/`. Two kinds of thing ship, and
they are kept separate:

- **The handout** (`<lab>_handout.pdf`) — reference material, delivered on its
  own. Handouts are never placed inside the student project.
- **Project content** — Lab 1 ships the whole starter project
  (`GEOG415_Project.zip`, unzipped once and opened); later labs ship
  `project_files.zip`, a `project_files/` folder mirroring the project layout
  that students unpack and drag into the project they already have.

## Adding a lab

Create `labs/<lab>/` with a `manifest.R`, a `build.R`, `templates/`, and a
`handout/`. Register the lab in `build.R` (`implemented_labs`), and if it draws
on the canonical pinned data, add it to `labs_needing_data` there too. An
increment lab lists its additions in the manifest as `project_files`
(destination-relative-to-project = source), and its `build.R` stages them under
`project_files/` and zips that (see `labs/lab02/`).

A lab may also carry a `solution/` folder — an instructor/TA answer key (e.g.
`labs/lab02/solution/lab02_solution.qmd`). It is versioned here but is **not**
referenced by any manifest, so it never ships to students; only its rendered
output is git-ignored.

Lab 2 onward, students acquire data themselves (`tidycensus` + the HRSA CSV), so
those labs ship no data — only a handout and templates. Each student needs a free
Census API key in `~/.Renviron` (see `labs/lab02/templates/Renviron.example`).
