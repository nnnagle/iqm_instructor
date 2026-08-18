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
  config.R          pinned vintages          dist/<year>/GEOG415_Lab1/   folder
  data/*.R          acquire + clean          dist/<year>/GEOG415_Lab1.zip
  labs/<lab>/       handout + templates
  R/                shared helpers
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
5. Distribute the folder or the `.zip` from `dist/<year>/`.

## Adding a lab

Create `labs/<lab>/` with a `manifest.R`, a `build.R`, `templates/`, and a
`handout/`. Add its data source to `data/` if it needs one, add any new ACS
codes to `config$acs_variables`, and register the lab in `build.R`. Labs after
Lab 1 distribute *increments* into the project students already have, rather
than a fresh project.
