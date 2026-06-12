#' Situation report for your Tally setup
#'
#' Reports everything relevant to tallyr working: which accounts have keys
#' available and which is active, whether the active account's API key was
#' found (and where), whether it looks like a Tally key, whether you are
#' online, and whether the key actually authenticates against the Tally
#' API. Ends with recommendations for fixing anything that's wrong. Never
#' errors, whatever the state of your setup.
#'
#' @inheritParams tally_api_key
#' @returns Invisibly, a list with components `api_key` (the key status),
#'   `accounts` (available account names), `online` (logical) and `user`
#'   (the authenticated user, or `NULL` if the connectivity test failed or
#'   wasn't run).
#' @seealso [tally_api_key()], [tally_use_account()], [tally_whoami()]
#' @export
#' @examples
#' \dontrun{
#' tally_sitrep()
#' }
tally_sitrep <- function(account = NULL) {
  cli::cli_h1("tallyr situation report")

  accounts <- tally_accounts()
  status <- tally_api_key_status(account)

  cli::cli_h3("Accounts")
  if (length(accounts) > 0) {
    cli::cli_alert_info("Account{?s} with a key available: {.val {accounts}}")
  } else {
    cli::cli_alert_warning("No account keys found in environment variables")
  }
  active_via <- if (!is.null(account)) {
    "from the {.arg account} argument"
  } else if (!is.null(getOption("tallyr.account"))) {
    "set by {.fun tally_use_account}"
  } else {
    "the default"
  }
  cli::cli_alert_info(paste0(
    "Active account: {.val {status$account}} (", active_via, ")"
  ))

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
    cli::cli_alert_danger(
      "No API key found for account {.val {status$account}}"
    )
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
    user <- tryCatch(tally_user(account), error = function(e) e)
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
  others <- setdiff(accounts, status$account)
  if (!status$found) {
    cli::cli_ul(c(
      "Create an API key at {.url https://tally.so/settings/api-keys}",
      "Set {.envvar {account_env_var(status$account)}} in your
       {.file .Renviron} (e.g. with {.run usethis::edit_r_environ()})",
      if (length(others) > 0) {
        "Or switch to an account with a key:
         {.code tally_use_account(\"{others[1]}\")}"
      }
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

  invisible(list(
    api_key = status,
    accounts = accounts,
    online = online,
    user = user
  ))
}

# Wrapped so tests can mock it
tally_has_internet <- function() {
  curl::has_internet()
}
