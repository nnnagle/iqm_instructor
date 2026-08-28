# ==============================================================================
# Lab 2 manifest — "Acquire, describe, and audit the data"
#
# Lab 2 ships NO data and NO project. Students pull ACS themselves (tidycensus)
# and download the HRSA CSV into the project they already have from Lab 1. This
# lab distributes a handout (separate PDF) plus a small set of files that are
# ADDED to the existing project at fixed project-relative paths.
# ==============================================================================

manifest <- list(

  id           = "lab02",
  title        = "GEOG 415 Lab 2 — Acquire, describe, and audit the data",

  # Handout is reference material, delivered as its own PDF.
  handout_qmd  = "handout/lab02.qmd",
  handout_stem = "lab02_handout",

  # Files added to the student's existing project, keyed by their destination
  # path RELATIVE TO THE PROJECT ROOT (value = source under this lab folder).
  project_files = c(
    "report/data_document.qmd" = "templates/data_document.qmd"
  )
)
