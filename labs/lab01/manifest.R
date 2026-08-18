# ==============================================================================
# Lab 1 manifest — "R from zero: first script, first data, first map"
#
# Declares WHAT this lab distributes to students. The assembly logic lives in
# build.R; this file is the editable description of the package.
# ==============================================================================

manifest <- list(

  id           = "lab01",
  title        = "GEOG 415 Lab 1 — R from zero",
  project_name = "GEOG415_Lab1",

  # Lab 1 distributes a FULL project: students open this fresh in RStudio.
  # (Later labs distribute increments into the project students already have.)
  delivery = "project",

  # Standard student folder skeleton.
  student_dirs = c(
    "data_raw",
    "data_processed",
    "figures",
    "metadata",
    "R",
    "tables"
  ),

  # ACS columns Lab 1 ships. The canonical ACS carries the full candidate set;
  # Lab 1 deliberately starts with population + poverty only. GEOID is always
  # included as the key.
  acs_columns = c(
    "GEOID",
    "tract_name",
    "total_population",
    "total_population_moe",
    "poverty_universe",
    "poverty_universe_moe",
    "poverty_count",
    "poverty_count_moe"
  ),

  # Student-facing filenames for the two starter data files.
  acs_out_name   = "tn_acs_starter.csv",
  tracts_out_name = "tn_tracts.gpkg",

  # Files copied verbatim from templates/ into the project root.
  root_templates = c(
    "00_setup.R"
    # README.md is generated from templates/README.md with vintages filled in.
  ),

  # Handout source rendered into the package root at build time.
  handout_qmd = "handout/lab01.qmd"
)
