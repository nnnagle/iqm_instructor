# ==============================================================================
# Lab 2 assembler.
#
# Sourced by ../../build.R with `config` in scope. Lab 2 needs no canonical
# data. Produces an increment under dist/<year>/GEOG415_Lab2/ (handout +
# templates) plus a matching .zip that students unzip into their existing
# GEOG415_Lab1 project.
# ==============================================================================

# Runs either via the top-level driver (`Rscript build.R lab02`) or directly
# (`Rscript labs/lab02/build.R`). Run from the repository root. Lab 2 needs no
# canonical data, so it can bootstrap config + helpers on its own.
if (!exists("config")) {
  source("config.R")
  for (f in list.files("R", full.names = TRUE, pattern = "\\.R$")) source(f)
}

lab_dir <- file.path("labs", "lab02")
source(file.path(lab_dir, "manifest.R"), local = TRUE)

root <- file.path(config$dist_dir, manifest$package_name)
prepare_output_root(root, config$overwrite)

# Templates copied verbatim.
for (tmpl in manifest$root_templates) {
  copy_file(file.path(lab_dir, "templates", tmpl), file.path(root, tmpl))
}

# Handout rendered (or copied if Quarto is unavailable).
emit_handout(file.path(lab_dir, manifest$handout_qmd), root)

zip_path <- zip_package(root)
message("Built: ", root)
message("Zipped: ", zip_path)
