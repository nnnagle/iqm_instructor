# ==============================================================================
# Lab 3 assembler.
#
# Sourced by ../../build.R with `config` and `analytic` (path to the
# analysis-ready dataset) in scope. Produces, under dist/<year>/lab03/:
#   lab03_handout.pdf   the handout (separate)
#   project_files/      analysis-ready data + deliverable skeletons at
#                       project-relative paths
#   project_files.zip   the same, wrapped, for the drag-into-project workflow
# ==============================================================================

# Lab 3 needs the analysis-ready dataset, which the driver builds first.
if (!exists("config") || !exists("analytic") || is.null(analytic)) {
  stop("Run Lab 3 via the driver:\n  Rscript build.R lab03\n",
       "(it builds the analysis-ready dataset this lab ships).", call. = FALSE)
}

lab_dir <- file.path("labs", "lab03")
source(file.path(lab_dir, "manifest.R"), local = TRUE)

out_dir <- file.path(config$dist_dir, "lab03")
prepare_output_root(out_dir, config$overwrite)

staging <- file.path(out_dir, "project_files")

# Provided analysis-ready dataset.
copy_file(analytic, file.path(staging, manifest$analytic_dest))

# Deliverable skeletons.
for (dest in names(manifest$project_files)) {
  src <- file.path(lab_dir, manifest$project_files[[dest]])
  copy_file(src, file.path(staging, dest))
}

zip_path <- zip_package(staging)   # -> dist/<year>/lab03/project_files.zip
emit_handout(file.path(lab_dir, manifest$handout_qmd), out_dir, manifest$handout_stem)

message("Built increment: ", staging)
message("Zipped: ", zip_path)
