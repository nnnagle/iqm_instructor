# ==============================================================================
# Census Data API helpers.
#
# The Census Data API now requires a free API key for data queries. Obtain one
# from https://api.census.gov/data/key_signup.html and set it before building:
#
#   Sys.setenv(CENSUS_API_KEY = "...")   # or add to ~/.Renviron
#
# Never commit the key or ship it in a student package.
# ==============================================================================

census_api_key <- function() {
  key <- Sys.getenv("CENSUS_API_KEY", unset = "")
  if (identical(key, "")) NULL else key
}


# Append &key= to a query URL when a key is available. Census tolerates keyless
# small queries but rate-limits and may reject larger ones, so we always attach
# the key when set.
with_api_key <- function(url) {
  key <- census_api_key()
  if (is.null(key)) return(url)
  sep <- if (grepl("\\?", url)) "&" else "?"
  paste0(url, sep, "key=", key)
}


# Fetch a Census API URL and return it as a data frame. The API returns a JSON
# array-of-arrays whose first row is the header. We validate that shape: a
# nonexistent vintage can return an HTML error page, which must NOT be mistaken
# for data.
read_census_json <- function(url) {
  x <- tryCatch(
    jsonlite::fromJSON(with_api_key(url)),
    error = function(e) NULL
  )

  if (is.null(x) || is.null(dim(x)) || nrow(x) < 2L) {
    stop("Unexpected or empty Census API response from:\n", url, call. = FALSE)
  }

  out <- as.data.frame(x[-1, , drop = FALSE], stringsAsFactors = FALSE)
  names(out) <- x[1, ]
  out
}


# Find the newest ACS 5-year vintage that actually parses as ACS JSON for this
# state. We confirm by parsing a tiny query, not merely by receiving bytes:
# Census can serve an HTML error page for a year that does not exist, and byte
# presence alone would falsely select it.
find_latest_acs5_year <- function(state_fips) {
  candidates <- seq(as.integer(format(Sys.Date(), "%Y")), 2010L, by = -1L)

  for (yr in candidates) {
    test_url <- sprintf(
      "https://api.census.gov/data/%d/acs/acs5?get=NAME&for=state:%s",
      yr, state_fips
    )
    message("Checking ACS 5-year vintage ", yr, " ...")

    ok <- tryCatch({
      df <- read_census_json(test_url)
      nrow(df) >= 1L && "NAME" %in% names(df)
    }, error = function(e) FALSE)

    if (isTRUE(ok)) return(yr)
  }

  stop("Could not locate an available ACS 5-year API vintage.", call. = FALSE)
}
