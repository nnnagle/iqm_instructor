# ==============================================================================
# HRSA health-center points builder (for Lab 3).
#
# Downloads the HRSA Health Center Service Delivery and Look-Alike Sites CSV,
# filters to the configured state, and writes a cleaned point layer (GeoPackage)
# that Lab 3 ships. Students compute their own accessibility measures from these
# points; shipping a clean file means the lab does not depend on each student
# having downloaded HRSA correctly.
#
# Column names are HRSA's (verbose); verify them against the file header /
# metadata if a future vintage changes them.
#
# Writes data/processed/<year>/<slug>_health_centers.gpkg and returns its path.
# ==============================================================================

# HRSA column names (verify against the CSV header if HRSA changes the schema).
HRSA_CSV_URL <- "https://data.hrsa.gov/DataDownload/DD_Files/Health_Center_Service_Delivery_and_LookAlike_Sites.csv"
HRSA_STATE   <- "Site State Abbreviation"
HRSA_LON     <- "Geocoding Artifact Address Primary X Coordinate"
HRSA_LAT     <- "Geocoding Artifact Address Primary Y Coordinate"
HRSA_NAME    <- "Site Name"

hrsa_build <- function(cfg) {
  message("Building HRSA health-center points ...")
  safe_dir_create(cfg$build_dir)

  raw_csv <- file.path(cfg$build_dir, "hrsa_health_centers_raw.csv")
  utils::download.file(HRSA_CSV_URL, raw_csv, mode = "wb", method = "libcurl", quiet = FALSE)

  hrsa <- readr::read_csv(raw_csv, show_col_types = FALSE)

  needed <- c(HRSA_STATE, HRSA_LON, HRSA_LAT)
  missing_cols <- setdiff(needed, names(hrsa))
  if (length(missing_cols) > 0) {
    stop("HRSA file missing expected columns: ", paste(missing_cols, collapse = ", "),
         "\nInspect the header and update the HRSA_* names in data/hrsa.R.", call. = FALSE)
  }

  hc <- hrsa |>
    dplyr::filter(.data[[HRSA_STATE]] == cfg$state_abbr) |>
    dplyr::filter(!is.na(.data[[HRSA_LON]]), !is.na(.data[[HRSA_LAT]]))

  site_name <- if (HRSA_NAME %in% names(hc)) as.character(hc[[HRSA_NAME]]) else NA_character_

  hc <- data.frame(
    site_name = site_name,
    lon = as.numeric(hc[[HRSA_LON]]),
    lat = as.numeric(hc[[HRSA_LAT]]),
    stringsAsFactors = FALSE
  )
  hc <- hc[!is.na(hc$lon) & !is.na(hc$lat), , drop = FALSE]

  hc_sf <- sf::st_as_sf(hc, coords = c("lon", "lat"), crs = 4326)

  safe_dir_create(cfg$processed_dir)
  out_path <- file.path(cfg$processed_dir, sprintf("%s_health_centers.gpkg", cfg$state_slug))
  sf::st_write(hc_sf, out_path, layer = sprintf("%s_health_centers", cfg$state_slug),
               delete_dsn = TRUE, quiet = TRUE)

  message("Wrote HRSA points: ", out_path, " (", nrow(hc_sf), " sites)")
  out_path
}
