# ==============================================================================
# Assemble a student-facing package folder and zip it.
#
# Every lab build produces two outputs under dist/<year>/:
#   <name>/       a ready-to-open folder
#   <name>.zip    the same folder, zipped
# Distribute whichever fits: hand out the folder, or the zip for an LMS.
# ==============================================================================

# Create the standard student project skeleton inside `root`.
create_student_skeleton <- function(root, subdirs) {
  safe_dir_create(root)
  for (d in subdirs) safe_dir_create(file.path(root, d))
  invisible(root)
}


# Write a minimal RStudio .Rproj file.
write_rproj <- function(path) {
  rproj_text <- c(
    "Version: 1.0",
    "",
    "RestoreWorkspace: No",
    "SaveWorkspace: No",
    "AlwaysSaveHistory: No",
    "",
    "EnableCodeIndexing: Yes",
    "UseSpacesForTab: Yes",
    "NumSpacesForTab: 2",
    "Encoding: UTF-8",
    "",
    "RnwWeave: Sweave",
    "LaTeX: pdfLaTeX"
  )
  write_lines_utf8(rproj_text, path)
}


# Zip a built folder. `root` is the folder to zip; the archive is written
# alongside it as <root>.zip and contains the folder as its top-level entry.
zip_package <- function(root) {
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  parent <- dirname(root)
  base   <- basename(root)
  zip_path <- file.path(parent, paste0(base, ".zip"))

  if (file.exists(zip_path)) unlink(zip_path)

  old <- setwd(parent)
  on.exit(setwd(old), add = TRUE)

  utils::zip(
    zipfile = paste0(base, ".zip"),
    files   = base,
    flags   = "-r9Xq"
  )

  file.path(parent, paste0(base, ".zip"))
}


# Locate a Quarto executable. Rscript run from a plain shell often lacks the
# `quarto` that RStudio bundles on its own PATH, so also honor a QUARTO_PATH
# override and probe RStudio's bundled locations. Returns "" if none found.
find_quarto <- function() {
  p <- Sys.which("quarto")
  if (nzchar(p)) return(unname(p))

  env <- Sys.getenv("QUARTO_PATH", unset = "")
  if (nzchar(env) && file.exists(env)) return(env)

  candidates <- c(
    "/Applications/RStudio.app/Contents/Resources/app/quarto/bin/quarto",   # macOS
    "/usr/lib/rstudio/resources/app/quarto/bin/quarto",                     # Linux desktop
    "/usr/lib/rstudio-server/bin/quarto/bin/quarto",                        # Linux server
    "C:/Program Files/RStudio/resources/app/bin/quarto/bin/quarto.exe"      # Windows
  )
  hit <- candidates[file.exists(candidates)]
  if (length(hit) > 0) return(hit[[1]])
  ""
}


# Render a handout .qmd to PDF into `dest_dir`, named <out_stem>.pdf. If Quarto
# is unavailable or the render fails, copy the .qmd source in instead (as
# <out_stem>.qmd) so a build is never missing its handout. out_stem defaults to
# the source file's stem.
emit_handout <- function(qmd_src, dest_dir, out_stem = NULL) {
  safe_dir_create(dest_dir)
  if (is.null(out_stem)) out_stem <- tools::file_path_sans_ext(basename(qmd_src))

  quarto <- find_quarto()
  if (nzchar(quarto)) {
    message("Rendering handout with Quarto (", quarto, ") ...")
    status <- system2(quarto, c("render", shQuote(qmd_src), "--to", "pdf",
                                "--output", paste0(out_stem, ".pdf"),
                                "--output-dir", shQuote(normalizePath(dest_dir))))
    if (status == 0L) return(invisible(dest_dir))
    warning("Quarto render failed; copying the .qmd source instead.")
  } else {
    message("Quarto not found on PATH or in RStudio; copying handout source (.qmd).\n",
            "  Install the Quarto CLI (https://quarto.org) or set QUARTO_PATH to render PDFs.")
  }
  copy_file(qmd_src, file.path(dest_dir, paste0(out_stem, ".qmd")))
  invisible(dest_dir)
}


# Guard: refuse to clobber an existing package unless overwrite is set.
prepare_output_root <- function(root, overwrite) {
  if (dir.exists(root)) {
    if (!isTRUE(overwrite)) {
      stop(
        "Student package already exists: ", root, "\n",
        "Set config$overwrite <- TRUE only if you intend to replace it.",
        call. = FALSE
      )
    }
    unlink(root, recursive = TRUE, force = TRUE)
  }
  safe_dir_create(root)
  invisible(root)
}
