# ==============================================================================
# Canonical ACS 5-year tract dataset builder.
#
# Downloads the candidate ACS variables (config$acs_variables) for every tract
# in the configured state, cleans them into a tidy CSV with a GEOID key, and
# saves both the cleaned result (data/processed/<year>/) and the exact raw API
# response (data/build/<year>/, for provenance).
#
# Returns the path to the cleaned CSV. Individual labs select the slice they
# distribute; this builder carries the full candidate set.
# ==============================================================================

acs_build <- function(cfg) {
  acs_year <- cfg$acs_year
  if (is.na(acs_year)) {
    acs_year <- find_latest_acs5_year(cfg$state_fips)
  }
  message("Using ACS 5-year vintage: ", acs_year)

  api_vars <- unname(cfg$acs_variables)

  acs_url <- paste0(
    "https://api.census.gov/data/", acs_year, "/acs/acs5",
    "?get=", paste(api_vars, collapse = ","),
    "&for=tract:*",
    "&in=state:", cfg$state_fips
  )

  acs_raw <- read_census_json(acs_url)

  # Provenance: keep the exact response, instructor-side only.
  safe_dir_create(cfg$build_dir)
  readr::write_csv(
    acs_raw,
    file.path(cfg$build_dir, sprintf("acs_%d_%s_tract_raw.csv", acs_year, cfg$state_slug))
  )

  # Rename API codes to friendly names.
  lookup <- setNames(names(cfg$acs_variables), unname(cfg$acs_variables))
  names(acs_raw) <- ifelse(
    names(acs_raw) %in% names(lookup),
    lookup[names(acs_raw)],
    names(acs_raw)
  )

  # Everything except the identifier columns is numeric.
  id_cols      <- c("tract_name", "state", "county", "tract")
  numeric_cols <- setdiff(names(cfg$acs_variables), "tract_name")

  acs_clean <- acs_raw |>
    dplyr::mutate(
      GEOID = paste0(state, county, tract),
      dplyr::across(dplyr::all_of(numeric_cols), as.numeric)
    ) |>
    dplyr::select(GEOID, dplyr::all_of(names(cfg$acs_variables))) |>
    dplyr::arrange(GEOID)

  if (anyDuplicated(acs_clean$GEOID)) {
    stop("ACS clean data contain duplicated GEOIDs.", call. = FALSE)
  }
  if (any(nchar(acs_clean$GEOID) != 11L)) {
    stop("Unexpected tract GEOID length in ACS output.", call. = FALSE)
  }

  safe_dir_create(cfg$processed_dir)
  out_path <- file.path(cfg$processed_dir, sprintf("%s_acs_tract.csv", cfg$state_slug))
  readr::write_csv(acs_clean, out_path)

  message("Wrote canonical ACS: ", out_path, " (", nrow(acs_clean), " tracts)")

  attr(out_path, "acs_year") <- acs_year
  attr(out_path, "acs_url")  <- acs_url
  out_path
}
