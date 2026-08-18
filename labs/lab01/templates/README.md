# GEOG 415 Lab 1 — Student Project

## What this folder is

This is the starting RStudio Project for the semester-long Community Primary
Care Priority Rating project. You will open and advance this same project in
every lab, so keep the folder structure intact.

## Start here

1. Open `GEOG415_Lab1.Rproj` in RStudio.
2. Open and run `00_setup.R`.
3. Follow the Lab 1 handout to write your first script.
4. Save figures in `figures/` and processed data in `data_processed/`.

## Student data files

### `data_raw/tn_acs_starter.csv`

Source: U.S. Census Bureau, {{ACS_YEAR}} American Community Survey 5-year
Detailed Tables. Each row is a {{STATE_NAME}} census tract.

Fields:

- `GEOID`: 11-character census-tract geographic identifier.
- `tract_name`: Census Bureau tract label.
- `total_population`: ACS estimate of total population.
- `total_population_moe`: margin of error for total population.
- `poverty_universe`: population for whom poverty status was determined.
- `poverty_universe_moe`: margin of error for the poverty universe.
- `poverty_count`: population with income below the poverty level.
- `poverty_count_moe`: margin of error for the poverty count.

You will calculate a poverty rate yourself in Lab 1. The rate is intentionally
not included in the starter CSV.

### `data_raw/tn_tracts.gpkg`

Source: U.S. Census Bureau, {{TIGER_YEAR}} TIGER/Line Census Tracts.
GeoPackage layer: `tn_tracts`

Fields:

- `GEOID`: geographic identifier used to join to the ACS table.
- `tract_name`: tract label.
- `land_area_m2`: land area in square meters.
- `water_area_m2`: water area in square meters.
- `geometry`: census-tract polygon geometry.

## Important workflow rule

Do not edit the files in `data_raw/` by hand. Treat them as source data. Any
changes, calculations, joins, exclusions, or recodes should be made in R and
saved as new outputs in `data_processed/`.

## Provenance

- ACS vintage: {{ACS_YEAR}}
- TIGER/Line vintage: {{TIGER_YEAR}}
- State: {{STATE_NAME}} (FIPS {{STATE_FIPS}})
