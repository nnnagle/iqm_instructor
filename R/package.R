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


# Render a handout .qmd to PDF into `dest_dir`, named <out_stem>.pdf. If Quarto
# is unavailable or the render fails, copy the .qmd source in instead (as
# <out_stem>.qmd) so a build is never missing its handout. out_stem defaults to
# the source file's stem.
emit_handout <- function(qmd_src, dest_dir, out_stem = NULL) {
  safe_dir_create(dest_dir)
  if (is.null(out_stem)) out_stem <- tools::file_path_sans_ext(basename(qmd_src))

  if (nzchar(Sys.which("quarto"))) {
    message("Rendering handout with Quarto ...")
    status <- system2("quarto", c("render", shQuote(qmd_src), "--to", "pdf",
                                  "--output", paste0(out_stem, ".pdf"),
                                  "--output-dir", shQuote(normalizePath(dest_dir))))
    if (status == 0L) return(invisible(dest_dir))
    warning("Quarto render failed; copying the .qmd source instead.")
  } else {
    message("Quarto not found; copying handout source (.qmd).")
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
