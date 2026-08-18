# ==============================================================================
# Canonical TIGER/Line tract geography builder.
#
# Downloads the state tract shapefile, cleans it to a small set of fields keyed
# by GEOID, repairs invalid geometries, and writes a GeoPackage into
# data/processed/<year>/. The downloaded ZIP and unzipped source are kept in
# data/build/<year>/ for provenance.
#
# Returns the path to the cleaned GeoPackage.
# ==============================================================================

tiger_build <- function(cfg, tiger_year = NULL) {
  if (is.null(tiger_year)) {
    tiger_year <- if (is.na(cfg$tiger_year)) cfg$acs_year else cfg$tiger_year
  }
  if (is.na(tiger_year)) {
    stop("tiger_build needs a resolved year; pass one or pin config$acs_year.",
         call. = FALSE)
  }
  message("Using TIGER/Line vintage: ", tiger_year)

  safe_dir_create(cfg$build_dir)

  tiger_url <- sprintf(
    "https://www2.census.gov/geo/tiger/TIGER%d/TRACT/tl_%d_%s_tract.zip",
    tiger_year, tiger_year, cfg$state_fips
  )
  tiger_zip <- file.path(cfg$build_dir, sprintf("tl_%d_%s_tract.zip", tiger_year, cfg$state_fips))

  utils::download.file(tiger_url, tiger_zip, mode = "wb", method = "libcurl", quiet = FALSE)

  unzip_dir <- file.path(cfg$build_dir, sprintf("tl_%d_%s_tract", tiger_year, cfg$state_fips))
  if (dir.exists(unzip_dir)) unlink(unzip_dir, recursive = TRUE, force = TRUE)
  safe_dir_create(unzip_dir)
  utils::unzip(tiger_zip, exdir = unzip_dir)

  shp_files <- list.files(unzip_dir, pattern = "\\.shp$", full.names = TRUE, ignore.case = TRUE)
  if (length(shp_files) != 1L) {
    stop("Expected exactly one tract shapefile after unzip; found ",
         length(shp_files), ".", call. = FALSE)
  }

  tracts_raw <- sf::st_read(shp_files[[1]], quiet = TRUE)

  needed <- c("GEOID", "NAMELSAD", "ALAND", "AWATER")
  missing_cols <- setdiff(needed, names(tracts_raw))
  if (length(missing_cols) > 0) {
    stop("TIGER tract file missing expected fields: ",
         paste(missing_cols, collapse = ", "), call. = FALSE)
  }

  tracts_clean <- tracts_raw |>
    dplyr::transmute(
      GEOID         = as.character(GEOID),
      tract_name    = as.character(NAMELSAD),
      land_area_m2  = as.numeric(ALAND),
      water_area_m2 = as.numeric(AWATER),
      geometry      = geometry
    )

  if (any(!sf::st_is_valid(tracts_clean))) {
    message("Repairing invalid tract geometries with st_make_valid().")
    tracts_clean <- sf::st_make_valid(tracts_clean)
  }
  if (anyDuplicated(tracts_clean$GEOID)) {
    stop("TIGER tract geography contains duplicated GEOIDs.", call. = FALSE)
  }

  safe_dir_create(cfg$processed_dir)
  out_path <- file.path(cfg$processed_dir, sprintf("%s_tracts.gpkg", cfg$state_slug))
  sf::st_write(
    tracts_clean, out_path,
    layer = sprintf("%s_tracts", cfg$state_slug),
    delete_dsn = TRUE, quiet = TRUE
  )

  message("Wrote canonical geography: ", out_path, " (", nrow(tracts_clean), " tracts)")

  attr(out_path, "tiger_year") <- tiger_year
  attr(out_path, "tiger_url")  <- tiger_url
  out_path
}
