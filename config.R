# ==============================================================================
# GEOG 415 — instructor build configuration
#
# This is the SINGLE source of truth for a build. Edit values here, not the
# builder scripts. To refresh the course for a new academic year:
#
#   1. Bump ACADEMIC_YEAR.
#   2. Run the build once on AUTO vintages (ACS_YEAR / TIGER_YEAR = NA) to see
#      what the newest available data are, and inspect the result.
#   3. PIN ACS_YEAR and TIGER_YEAR to the tested vintages so the data cannot
#      silently change mid-semester.
#   4. Rebuild and distribute.
# ==============================================================================

config <- list(

  # ---- Term -----------------------------------------------------------------
  # Namespaces build/ and dist/ outputs so a new year never clobbers the
  # package students are currently using.
  academic_year = 2026L,

  # ---- Geography ------------------------------------------------------------
  # The whole project is deliberately one state, not the nation.
  state_fips = "47",
  state_abbr = "TN",
  state_slug = "tn",
  state_name = "Tennessee",

  # ---- Data vintages --------------------------------------------------------
  # NA = auto-detect the latest available vintage. Leave on AUTO only while
  # testing; PIN to integers before a live semester (see header).
  acs_year   = NA_integer_,
  tiger_year = NA_integer_,   # defaults to acs_year when NA

  # ---- Tract geometry source ------------------------------------------------
  # "cb"    = Census cartographic-boundary tracts (generalized, water-clipped):
  #           smaller and cleaner for choropleths — the Lab 1 default.
  # "tiger" = full TIGER/Line tracts: precise boundaries, larger files.
  tract_boundary = "cb",
  cb_resolution  = "500k",    # "500k", "5m", or "20m"; used only when "cb"

  # ---- Candidate ACS variables ----------------------------------------------
  # The canonical ACS pull carries the full candidate set for the semester.
  # Each lab's manifest selects the slice that lab distributes; Lab 1, for
  # example, ships only the poverty variables. Estimates (E) and margins of
  # error (M) are kept together so uncertainty stays visible from the start.
  acs_variables = c(
    tract_name           = "NAME",
    total_population      = "B01003_001E",
    total_population_moe  = "B01003_001M",
    poverty_universe      = "B17001_001E",
    poverty_universe_moe  = "B17001_001M",
    poverty_count         = "B17001_002E",
    poverty_count_moe     = "B17001_002M"
    # Later labs add need/access indicators here, e.g. uninsured, no-vehicle,
    # age/disability. Add the codes above and they flow into the canonical
    # dataset automatically.
  ),

  # ---- Behavior -------------------------------------------------------------
  # If FALSE, the build refuses to overwrite an existing student package.
  overwrite = FALSE
)


# ------------------------------------------------------------------------------
# Derived paths. Do not edit; these follow from academic_year.
# ------------------------------------------------------------------------------

config$build_dir     <- file.path("data", "build", config$academic_year)      # raw, gitignored
config$processed_dir <- file.path("data", "processed", config$academic_year)  # cleaned, committable
config$dist_dir      <- file.path("dist", config$academic_year)               # student output, gitignored
