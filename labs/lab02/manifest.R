# ==============================================================================
# Lab 2 manifest — "Acquire, describe, and audit the data"
#
# Lab 2 ships NO data. Students pull ACS themselves (tidycensus) and download
# the HRSA facility CSV, into the project they already have from Lab 1. This lab
# distributes only the handout plus a couple of templates, as an increment that
# unzips into the existing project.
# ==============================================================================

manifest <- list(

  id           = "lab02",
  title        = "GEOG 415 Lab 2 — Acquire, describe, and audit the data",
  package_name = "GEOG415_Lab2",

  # Increment: unzip these into the existing GEOG415_Lab1 project folder.
  delivery = "increment",

  # Files copied verbatim into the increment (student adds them to the project).
  root_templates = c(
    "data_document.qmd",   # the deliverable skeleton students fill in
    "Renviron.example"     # example env file for the Census API key
  ),

  # Handout source rendered into the increment at build time.
  handout_qmd = "handout/lab02.qmd"
)
