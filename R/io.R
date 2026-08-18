# ==============================================================================
# Small filesystem helpers shared across builders.
# ==============================================================================

safe_dir_create <- function(path) {
  if (!dir.exists(path)) dir.create(path, recursive = TRUE)
  invisible(path)
}


# Write character vector as UTF-8, one element per line.
write_lines_utf8 <- function(x, path) {
  con <- file(path, open = "w", encoding = "UTF-8")
  on.exit(close(con), add = TRUE)
  writeLines(x, con = con, useBytes = TRUE)
  invisible(path)
}


# Copy a file, creating the destination directory if needed. Errors loudly
# rather than silently skipping a missing source.
copy_file <- function(from, to) {
  if (!file.exists(from)) {
    stop("Cannot copy missing file: ", from, call. = FALSE)
  }
  safe_dir_create(dirname(to))
  ok <- file.copy(from, to, overwrite = TRUE)
  if (!ok) stop("Failed to copy ", from, " -> ", to, call. = FALSE)
  invisible(to)
}
