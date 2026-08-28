# ==============================================================================
# Lab 1 assembler.
#
# Sourced by ../../build.R with `config` and `canonical` (paths to the pinned
# canonical data) already in scope. Produces, under dist/<year>/lab01/, the
# GEOG415_Project/ starter project, its .zip, and the handout PDF.
# ==============================================================================

# Lab 1 needs the canonical pinned data, which the driver builds first, so it
# must be run through the driver rather than sourced directly.
if (!exists("config") || !exists("canonical") || is.null(canonical)) {
  stop("Run Lab 1 via the driver:\n  Rscript build.R lab01\n",
       "(it builds the canonical pinned data this lab needs).", call. = FALSE)
}

lab_dir <- file.path("labs", "lab01")
source(file.path(lab_dir, "manifest.R"), local = TRUE)

# dist/<year>/lab01/ holds everything this lab distributes: the project folder,
# its zip, and the handout PDF (separate — handouts are not project content).
out_dir <- file.path(config$dist_dir, "lab01")
prepare_output_root(out_dir, config$overwrite)

root <- file.path(out_dir, manifest$project_name)
create_student_skeleton(root, manifest$student_dirs)
write_rproj(file.path(root, paste0(manifest$project_name, ".Rproj")))


# ---- Data: ACS starter (Lab 1 slice of the canonical ACS) --------------------

acs <- readr::read_csv(canonical$acs, show_col_types = FALSE)
missing_cols <- setdiff(manifest$acs_columns, names(acs))
if (length(missing_cols) > 0) {
  stop("Canonical ACS is missing columns Lab 1 expects: ",
       paste(missing_cols, collapse = ", "), call. = FALSE)
}
acs_lab1 <- acs[, manifest$acs_columns, drop = FALSE]
acs_out  <- file.path(root, "data_raw", manifest$acs_out_name)
readr::write_csv(acs_lab1, acs_out)


# ---- Data: tract geography (copied whole) ------------------------------------

tracts_out <- file.path(root, "data_raw", manifest$tracts_out_name)
copy_file(canonical$tracts, tracts_out)


# ---- Cross-check ACS/geography GEOIDs before shipping ------------------------

tracts <- sf::st_read(canonical$tracts, quiet = TRUE)
geo_geoids <- as.character(tracts$GEOID)
acs_geoids <- as.character(acs_lab1$GEOID)
geo_no_acs <- setdiff(geo_geoids, acs_geoids)
acs_no_geo <- setdiff(acs_geoids, geo_geoids)
if (length(geo_no_acs) > 0 || length(acs_no_geo) > 0) {
  warning("ACS/geography GEOIDs are not a perfect match.\n",
          "Geography without ACS: ", length(geo_no_acs), "\n",
          "ACS without geography: ", length(acs_no_geo), "\n",
          "Inspect before distributing.")
}


# ---- Templates copied verbatim ----------------------------------------------

for (tmpl in manifest$root_templates) {
  copy_file(file.path(lab_dir, "templates", tmpl), file.path(root, tmpl))
}


# ---- Student README with vintages filled in ---------------------------------

acs_year   <- config$acs_year
tiger_year <- if (is.na(config$tiger_year)) config$acs_year else config$tiger_year

tract_source_desc <- if (identical(config$tract_boundary, "tiger")) {
  "TIGER/Line Census Tracts"
} else {
  "Cartographic Boundary Census Tracts (generalized)"
}

readme_tmpl <- readLines(file.path(lab_dir, "templates", "README.md"), encoding = "UTF-8")
readme <- readme_tmpl
readme <- gsub("{{ACS_YEAR}}",     acs_year,          readme, fixed = TRUE)
readme <- gsub("{{TIGER_YEAR}}",   tiger_year,        readme, fixed = TRUE)
readme <- gsub("{{TRACT_SOURCE}}", tract_source_desc, readme, fixed = TRUE)
readme <- gsub("{{STATE_NAME}}",   config$state_name, readme, fixed = TRUE)
readme <- gsub("{{STATE_FIPS}}",   config$state_fips, readme, fixed = TRUE)
write_lines_utf8(readme, file.path(root, "README.md"))


# ---- Zip the project, and render the handout separately ---------------------

zip_path <- zip_package(root)   # -> dist/<year>/lab01/GEOG415_Project.zip
emit_handout(file.path(lab_dir, manifest$handout_qmd), out_dir, manifest$handout_stem)
message("Built project: ", root)
message("Zipped: ", zip_path)

safe_dir_create(config$build_dir)
write_lines_utf8(
  c(
    "GEOG 415 Lab 1 package build record",
    "===================================",
    paste0("Build date: ", Sys.Date()),
    paste0("Academic year: ", config$academic_year),
    paste0("State: ", config$state_name, " (", config$state_fips, ")"),
    paste0("ACS 5-year vintage: ", acs_year),
    paste0("Tract geometry: ", tract_source_desc, " (", tiger_year, ")"),
    paste0("ACS rows shipped: ", nrow(acs_lab1)),
    paste0("Geography rows shipped: ", nrow(tracts)),
    paste0("Geography without ACS: ", length(geo_no_acs)),
    paste0("ACS without geography: ", length(acs_no_geo))
  ),
  file.path(config$build_dir, "lab01_build_record.txt")
)
