# ==============================================================================
# Lab 2 assembler.
#
# Sourced by ../../build.R with `config` in scope (or run directly — it
# bootstraps config + helpers). Lab 2 needs no canonical data. Produces, under
# dist/<year>/lab02/:
#   lab02_handout.pdf   the handout (reference; distribute on its own)
#   project_files/      the files students add to their existing project, laid
#                       out at project-relative paths (e.g. report/…)
#   project_files.zip   the same, zipped WITH the project_files/ wrapper, so a
#                       double-click unpacks a clearly-named folder students then
#                       drag files out of into their project
# ==============================================================================

# Runs either via the top-level driver (`Rscript build.R lab02`) or directly
# (`Rscript labs/lab02/build.R`). Run from the repository root.
if (!exists("config")) {
  source("config.R")
  for (f in list.files("R", full.names = TRUE, pattern = "\\.R$")) source(f)
}

lab_dir <- file.path("labs", "lab02")
source(file.path(lab_dir, "manifest.R"), local = TRUE)

out_dir <- file.path(config$dist_dir, "lab02")
prepare_output_root(out_dir, config$overwrite)

# Stage the project-additions at their project-relative paths.
staging <- file.path(out_dir, "project_files")
for (dest in names(manifest$project_files)) {
  src <- file.path(lab_dir, manifest$project_files[[dest]])
  copy_file(src, file.path(staging, dest))
}

zip_path <- zip_package(staging)   # -> dist/<year>/lab02/project_files.zip
emit_handout(file.path(lab_dir, manifest$handout_qmd), out_dir, manifest$handout_stem)

message("Built increment: ", staging)
message("Zipped: ", zip_path)
