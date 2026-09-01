# ==============================================================================
# Lab 3 manifest — "Explore, compare, and choose indicators" (Module 2A)
#
# Lab 3 ships an increment into the existing GEOG415_Project: an analysis-ready
# tract dataset (so nobody is blocked by a rough Lab 2) plus two deliverable
# skeletons. Handout is a separate PDF.
# ==============================================================================

manifest <- list(

  id           = "lab03",
  title        = "GEOG 415 Lab 3 — Explore, compare, and choose indicators",

  handout_qmd  = "handout/lab03.qmd",
  handout_stem = "lab03_handout",

  # Provided analysis-ready dataset. Built instructor-side by data/analytic.R;
  # copied into the increment at this project-relative path. Shipped in data_raw/
  # because to the student it is a given source they did not derive.
  analytic_dest = "data_raw/tn_tract_analysis.csv",

  # Cleaned HRSA health-center points (data/hrsa.R). Students compute their own
  # accessibility measures from these.
  hrsa_dest = "data_raw/tn_health_centers.gpkg",

  # Deliverable skeletons, keyed by destination path relative to the project.
  project_files = c(
    "report/eda_brief.qmd"             = "templates/eda_brief.qmd",
    "metadata/indicator_decisions.md"  = "templates/indicator_decisions.md"
  )
)
