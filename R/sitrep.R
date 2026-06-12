#' Situation report for your Tally setup
#'
#' Reports everything relevant to tallyr working: whether an API key was
#' found (and where), whether it looks like a Tally key, whether you are
#' online, and whether the key actually authenticates against the Tally
#' API. Ends with recommendations for fixing anything that's wrong. Never
#' errors, whatever the state of your setup.
#'
#' @returns Invisibly, a list with components `api_key` (the key status),
#'   `online` (logical) and `user` (the authenticated user, or `NULL` if
#'   the connectivity test failed or wasn't run).
#' @seealso [tally_api_key()], [tally_whoami()]
#' @export
#' @examples
#' \dontrun{
#' tally_sitrep()
#' }
tally_sitrep <- function() {
  cli::cli_h1("tallyr situation report")

  status <- tally_api_key_status()
  cli::cli_h3("API key")
  if (status$found) {
    cli::cli_alert_success("API key found")
    cli::cli_alert_info("Source: {status$source}")
    if (status$valid) {
      cli::cli_alert_success("Key format looks valid (starts with {.val tly-})")
    } else {
      cli::cli_alert_warning(
        "Key does not start with {.val tly-}, so may not be a Tally API key"
      )
    }
  } else {
    cli::cli_alert_danger("No API key found")
  }

  cli::cli_h3("Connectivity")
  online <- tally_has_internet()
  if (online) {
    cli::cli_alert_success("Internet: online")
  } else {
    cli::cli_alert_danger("Internet: offline")
  }

  user <- NULL
  api_error <- NULL
  if (status$found && online) {
    user <- tryCatch(tally_user(), error = function(e) e)
    if (inherits(user, "error")) {
      api_error <- cli::ansi_strip(conditionMessage(user))
      user <- NULL
      cli::cli_alert_danger("Tally API connection failed: {api_error}")
    } else {
      cli::cli_alert_success("Authenticated as {user_label(user)}")
    }
  } else {
    cli::cli_alert_info("Skipping API connection test")
  }

  cli::cli_h3("Recommendations")
  if (!status$found) {
    cli::cli_ul(c(
      "Create an API key at {.url https://tally.so/settings/api-keys}",
      "Set {.envvar TALLY_API_KEY} in your {.file .Renviron}
       (e.g. with {.run usethis::edit_r_environ()}), or use
       {.code options(tallyr.api_key = )} for the current session"
    ))
  } else if (!is.null(api_error)) {
    cli::cli_ul(
      "Check your key is current, or regenerate it at
       {.url https://tally.so/settings/api-keys}"
    )
  } else if (!status$valid) {
    cli::cli_ul(
      "Check the value set in {status$source} is the key generated at
       {.url https://tally.so/settings/api-keys}"
    )
  } else if (!online) {
    cli::cli_ul("Reconnect to the internet to use the Tally API")
  } else {
    cli::cli_alert_success("tallyr setup looks good!")
  }

  invisible(list(api_key = status, online = online, user = user))
}

# Wrapped so tests can mock it
tally_has_internet <- function() {
  curl::has_internet()
}
