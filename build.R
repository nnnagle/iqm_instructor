#!/usr/bin/env Rscript

# ==============================================================================
# GEOG 415 instructor build driver.
#
# Usage:
#   Rscript build.R            # build all labs (currently: lab01)
#   Rscript build.R lab01      # build a single lab
#
# What it does:
#   1. Loads config.R and every helper in R/.
#   2. Ensures the canonical pinned data exist (builds them if missing).
#   3. Runs each requested lab's build.R, which assembles the student package
#      folder + zip under dist/<year>/.
#
# See README.md for the yearly-refresh checklist and API-key setup.
# ==============================================================================

source("config.R")
for (f in list.files("R", full.names = TRUE, pattern = "\\.R$")) source(f)

required_pkgs <- c("sf", "dplyr", "readr", "jsonlite")
missing_pkgs <- required_pkgs[!vapply(required_pkgs, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing_pkgs) > 0) {
  stop("Install required packages first:\n  install.packages(c(",
       paste(sprintf('"%s"', missing_pkgs), collapse = ", "), "))",
       call. = FALSE)
}

message("GEOG 415 instructor build")
message("Academic year: ", config$academic_year)
message("State: ", config$state_name, " (FIPS ", config$state_fips, ")")


# ------------------------------------------------------------------------------
# Canonical data. Built once and shared by all labs. Delete data/processed/<year>
# to force a rebuild; otherwise existing files are reused.
# ------------------------------------------------------------------------------

build_canonical_data <- function(cfg) {
  source("data/acs.R", local = TRUE)
  source("data/tiger.R", local = TRUE)

  acs_path  <- file.path(cfg$processed_dir, sprintf("%s_acs_tract.csv", cfg$state_slug))
  gpkg_path <- file.path(cfg$processed_dir, sprintf("%s_tracts.gpkg", cfg$state_slug))

  # The RESOLVED vintages (after any auto-detection) are recorded next to the
  # processed data. This keeps them available when a later build reuses cached
  # files instead of re-downloading, so the student README/provenance never
  # falls back to NA.
  vintages_path <- file.path(cfg$processed_dir, "vintages.dcf")
  read_vintages <- function() {
    if (!file.exists(vintages_path)) return(NULL)
    v <- read.dcf(vintages_path)
    list(acs_year = as.integer(v[1, "acs_year"]),
         tiger_year = as.integer(v[1, "tiger_year"]))
  }
  write_vintages <- function(acs_year, tiger_year) {
    safe_dir_create(cfg$processed_dir)
    write.dcf(data.frame(acs_year = acs_year, tiger_year = tiger_year),
              vintages_path)
  }

  cached <- read_vintages()
  if (!is.null(cached)) {
    if (is.na(cfg$acs_year))   cfg$acs_year   <- cached$acs_year
    if (is.na(cfg$tiger_year)) cfg$tiger_year <- cached$tiger_year
  }

  if (!file.exists(acs_path)) {
    acs_path <- acs_build(cfg)
    cfg$acs_year <- attr(acs_path, "acs_year")   # pin resolved year for tiger
  } else {
    message("Reusing canonical ACS: ", acs_path)
  }

  resolved_tiger <- if (is.na(cfg$tiger_year)) cfg$acs_year else cfg$tiger_year
  if (!file.exists(gpkg_path)) {
    gpkg_path <- tiger_build(cfg, tiger_year = resolved_tiger)
    resolved_tiger <- attr(gpkg_path, "tiger_year")
  } else {
    message("Reusing canonical geography: ", gpkg_path)
  }
  cfg$tiger_year <- resolved_tiger

  write_vintages(cfg$acs_year, cfg$tiger_year)
  list(cfg = cfg, acs = acs_path, tracts = gpkg_path)
}

canonical <- build_canonical_data(config)
config <- canonical$cfg


# ------------------------------------------------------------------------------
# Build requested labs.
# ------------------------------------------------------------------------------

args <- commandArgs(trailingOnly = TRUE)
implemented_labs <- c("lab01")
labs <- if (length(args) > 0) args else implemented_labs

for (lab in labs) {
  lab_build <- file.path("labs", lab, "build.R")
  if (!file.exists(lab_build)) {
    stop("No build.R for ", lab, " at ", lab_build, call. = FALSE)
  }
  message("\n---- building ", lab, " ----")
  # Each lab build sees: config, helpers, and `canonical` (paths to data).
  source(lab_build, local = TRUE)
}

message("\nBUILD COMPLETE. Student packages under: ", config$dist_dir)
