#' Retrieve your Tally API key
#'
#' Tally uses personal API keys (no OAuth): create one at
#' Tally Settings > API keys (<https://tally.so/settings/api-keys>) and store
#' it where tallyr can find it. The key is looked up first in the
#' `tallyr.api_key` R option, then in the `TALLY_API_KEY` environment
#' variable.
#'
#' For regular use, set `TALLY_API_KEY` in your `.Renviron` (e.g. via
#' `usethis::edit_r_environ()`). For a single session, you can instead use
#' `options(tallyr.api_key = "tly-...")`.
#'
#' @returns The API key as a string. Errors with setup instructions if no
#'   key is found.
#' @seealso [tally_sitrep()] to diagnose your setup.
#' @export
#' @examples
#' \dontrun{
#' tally_api_key()
#' }
tally_api_key <- function() {
  status <- tally_api_key_status()
  if (!status$found) {
    cli::cli_abort(c(
      "No Tally API key found.",
      "i" = "Create one at {.url https://tally.so/settings/api-keys}
             (Tally Settings > API keys).",
      "i" = "Then set the {.envvar TALLY_API_KEY} environment variable in your
             {.file .Renviron} (e.g. with {.run usethis::edit_r_environ()}),
             or use {.code options(tallyr.api_key = )} for the current
             session."
    ))
  }
  status$value
}

# Checking function in the sitrep style: inspects only, never errors or
# prints, and returns structure rather than a boolean so that callers
# (including tally_sitrep()) have context.
tally_api_key_status <- function() {
  opt <- getOption("tallyr.api_key")
  if (!is.null(opt) && nzchar(opt)) {
    value <- as.character(opt)
    source <- "R option: tallyr.api_key"
  } else {
    env <- Sys.getenv("TALLY_API_KEY")
    if (nzchar(env)) {
      value <- env
      source <- "Environment variable: TALLY_API_KEY"
    } else {
      value <- NA_character_
      source <- "Not found"
    }
  }

  found <- !is.na(value)
  list(
    value = value,
    source = source,
    found = found,
    # Tally API keys look like "tly-xxxx"; a mismatch is suspicious but not
    # fatal (only the API itself can really judge), so tally_api_key()
    # aborts on `found`, while tally_sitrep() warns on `valid`.
    valid = found && grepl("^tly-", value)
  )
}

has_tally_api_key <- function() {
  tally_api_key_status()$found
}
