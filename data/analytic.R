# ==============================================================================
# Analysis-ready tract dataset builder (for Lab 3).
#
# Builds the candidate need-indicator table students explore in Lab 3, so the
# lab does not depend on each student having produced a correct dataset in Lab 2.
# It mirrors what students/TAs do with tidycensus, but uses the raw Census API
# (via the shared read_census_json helper) to avoid adding a dependency.
#
# Two endpoints are combined:
#   - Detailed tables (counts): population, poverty, vehicle access. Kept as
#     numerator/denominator so students can correctly RE-AGGREGATE to county in
#     the MAUP exercise.
#   - Subject tables (percents): uninsured, age 65+, disability. These arrive
#     pre-computed, which is itself a teaching point (you cannot correctly
#     aggregate a percent without its denominator).
#
# Subject-table cell codes (S....) move between vintages — VERIFY with the
# Census variable list for the pinned year before a live semester.
#
# Writes data/processed/<year>/<slug>_tract_analysis.csv and returns its path.
# ==============================================================================

analytic_build <- function(cfg) {
  acs_year <- cfg$acs_year
  if (is.na(acs_year)) acs_year <- find_latest_acs5_year(cfg$state_fips)
  message("Building analysis-ready dataset (ACS 5-year ", acs_year, ") ...")

  base <- sprintf("https://api.census.gov/data/%d/acs/acs5", acs_year)
  in_state <- paste0("&for=tract:*&in=state:", cfg$state_fips)

  # ---- Detailed tables: counts (numerator/denominator kept) ------------------
  det_vars <- c(
    "NAME",
    "B01003_001E",              # total population
    "B17001_001E", "B17001_002E",   # poverty universe, below poverty
    "B08201_001E", "B08201_002E"    # households, no vehicle available
  )
  det <- read_census_json(paste0(base, "?get=", paste(det_vars, collapse = ","), in_state))

  # ---- Subject tables: pre-computed percents --------------------------------
  subj_vars <- c(
    "S2701_C05_001E",   # percent uninsured (VERIFY per vintage)
    "S0101_C02_030E",   # percent age 65 and over (VERIFY)
    "S1810_C03_001E"    # percent with a disability (VERIFY)
  )
  subj <- read_census_json(paste0(base, "/subject?get=", paste(subj_vars, collapse = ","), in_state))

  num <- function(x) {
    x <- suppressWarnings(as.numeric(x))
    x[x < 0] <- NA_real_          # Census uses negative "jam" values for N/A
    x
  }

  det <- det |>
    dplyr::mutate(
      GEOID           = paste0(state, county, tract),
      tract_name      = as.character(NAME),
      total_population = num(B01003_001E),
      poverty_universe = num(B17001_001E),
      poverty_count    = num(B17001_002E),
      households       = num(B08201_001E),
      novehicle_count  = num(B08201_002E)
    ) |>
    dplyr::select(GEOID, tract_name, total_population,
                  poverty_universe, poverty_count, households, novehicle_count)

  subj <- subj |>
    dplyr::mutate(
      GEOID          = paste0(state, county, tract),
      uninsured_pct  = num(S2701_C05_001E),
      age65_pct      = num(S0101_C02_030E),
      disability_pct = num(S1810_C03_001E)
    ) |>
    dplyr::select(GEOID, uninsured_pct, age65_pct, disability_pct)

  analytic <- det |>
    dplyr::left_join(subj, by = "GEOID") |>
    dplyr::mutate(
      county_geoid   = substr(GEOID, 1, 5),
      poverty_rate   = poverty_count / poverty_universe,
      novehicle_rate = novehicle_count / households
    ) |>
    dplyr::select(
      GEOID, county_geoid, tract_name, total_population,
      poverty_universe, poverty_count, poverty_rate,
      households, novehicle_count, novehicle_rate,
      uninsured_pct, age65_pct, disability_pct
    ) |>
    dplyr::arrange(GEOID)

  if (anyDuplicated(analytic$GEOID)) {
    stop("Analysis-ready dataset has duplicated GEOIDs.", call. = FALSE)
  }

  safe_dir_create(cfg$processed_dir)
  out_path <- file.path(cfg$processed_dir, sprintf("%s_tract_analysis.csv", cfg$state_slug))
  readr::write_csv(analytic, out_path)
  message("Wrote analysis-ready dataset: ", out_path, " (", nrow(analytic), " tracts)")

  attr(out_path, "acs_year") <- acs_year
  out_path
}
