# ==============================================================================
# Canonical tract geography builder.
#
# Downloads the state tract shapefile — either Census cartographic-boundary
# tracts (generalized, water-clipped; config$tract_boundary == "cb") or full
# TIGER/Line tracts ("tiger") — cleans it to a small set of fields keyed by
# GEOID, repairs invalid geometries, and writes a GeoPackage into
# data/processed/<year>/. The downloaded ZIP and unzipped source are kept in
# data/build/<year>/ for provenance.
#
# Both sources carry the fields we keep (GEOID, NAMELSAD, ALAND, AWATER), so the
# cleaning is identical; only the download URL differs.
#
# Returns the path to the cleaned GeoPackage.
# ==============================================================================

# Build the download URL and a base name for the given boundary source.
tract_source <- function(cfg, year) {
  boundary <- if (is.null(cfg$tract_boundary)) "cb" else cfg$tract_boundary

  if (identical(boundary, "cb")) {
    res  <- if (is.null(cfg$cb_resolution)) "500k" else cfg$cb_resolution
    base <- sprintf("cb_%d_%s_tract_%s", year, cfg$state_fips, res)
    url  <- sprintf("https://www2.census.gov/geo/tiger/GENZ%d/shp/%s.zip", year, base)
  } else if (identical(boundary, "tiger")) {
    base <- sprintf("tl_%d_%s_tract", year, cfg$state_fips)
    url  <- sprintf("https://www2.census.gov/geo/tiger/TIGER%d/TRACT/%s.zip", year, base)
  } else {
    stop("config$tract_boundary must be \"cb\" or \"tiger\"; got: ", boundary,
         call. = FALSE)
  }

  list(url = url, base = base, boundary = boundary)
}


tiger_build <- function(cfg, tiger_year = NULL) {
  if (is.null(tiger_year)) {
    tiger_year <- if (is.na(cfg$tiger_year)) cfg$acs_year else cfg$tiger_year
  }
  if (is.na(tiger_year)) {
    stop("tiger_build needs a resolved year; pass one or pin config$acs_year.",
         call. = FALSE)
  }

  src <- tract_source(cfg, tiger_year)
  message("Using tract geometry: ", src$boundary, " (vintage ", tiger_year, ")")

  safe_dir_create(cfg$build_dir)

  zip_path  <- file.path(cfg$build_dir, paste0(src$base, ".zip"))
  utils::download.file(src$url, zip_path, mode = "wb", method = "libcurl", quiet = FALSE)

  unzip_dir <- file.path(cfg$build_dir, src$base)
  if (dir.exists(unzip_dir)) unlink(unzip_dir, recursive = TRUE, force = TRUE)
  safe_dir_create(unzip_dir)
  utils::unzip(zip_path, exdir = unzip_dir)

  shp_files <- list.files(unzip_dir, pattern = "\\.shp$", full.names = TRUE, ignore.case = TRUE)
  if (length(shp_files) != 1L) {
    stop("Expected exactly one tract shapefile after unzip; found ",
         length(shp_files), ".", call. = FALSE)
  }

  tracts_raw <- sf::st_read(shp_files[[1]], quiet = TRUE)

  needed <- c("GEOID", "NAMELSAD", "ALAND", "AWATER")
  missing_cols <- setdiff(needed, names(tracts_raw))
  if (length(missing_cols) > 0) {
    stop("Tract file (", src$boundary, ") missing expected fields: ",
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
    stop("Tract geography contains duplicated GEOIDs.", call. = FALSE)
  }

  safe_dir_create(cfg$processed_dir)
  out_path <- file.path(cfg$processed_dir, sprintf("%s_tracts.gpkg", cfg$state_slug))
  sf::st_write(
    tracts_clean, out_path,
    layer = sprintf("%s_tracts", cfg$state_slug),
    delete_dsn = TRUE, quiet = TRUE
  )

  message("Wrote canonical geography: ", out_path, " (", nrow(tracts_clean), " tracts)")

  attr(out_path, "tiger_year")     <- tiger_year
  attr(out_path, "tiger_url")      <- src$url
  attr(out_path, "tract_boundary") <- src$boundary
  out_path
}
