#' Work with multiple Tally accounts
#'
#' If you have several Tally accounts, store each account's API key in its
#' own environment variable in your `.Renviron`: `TALLY_API_KEY` for the
#' default account, and `TALLY_API_KEY_<NAME>` for named accounts (e.g.
#' `TALLY_API_KEY_WORK` for an account called `"work"`). Account names are
#' case-insensitive.
#'
#' `tally_accounts()` lists the accounts that have a key available.
#' `tally_use_account()` switches the active account for the rest of the
#' session; all tallyr functions then use that account unless given an
#' explicit `account` argument.
#'
#' @param account The account to switch to, e.g. `"work"`. Use `NULL` or
#'   `"default"` to switch back to the default account.
#' @returns `tally_accounts()` returns a character vector of account
#'   names, `"default"` first if `TALLY_API_KEY` is set.
#'   `tally_use_account()` invisibly returns the name of the previously
#'   active account, so you can restore it later.
#' @seealso [tally_api_key()] for how keys are resolved, [tally_sitrep()]
#'   to see your accounts at a glance.
#' @export
#' @examples
#' \dontrun{
#' tally_accounts()
#'
#' tally_use_account("work")
#' tally_forms() # uses the "work" account
#'
#' # one-off call on another account, without switching:
#' tally_forms(account = "rladies")
#'
#' # switch back, restoring whatever was active before:
#' previous <- tally_use_account("rladies")
#' tally_use_account(previous)
#' }
tally_accounts <- function() {
  vars <- names(Sys.getenv())
  vars <- vars[startsWith(vars, "TALLY_API_KEY")]
  vars <- vars[nzchar(Sys.getenv(vars))]

  named <- sort(tolower(sub("^TALLY_API_KEY_", "", setdiff(vars, "TALLY_API_KEY"))))
  if ("TALLY_API_KEY" %in% vars) {
    c("default", named)
  } else {
    named
  }
}

#' @rdname tally_accounts
#' @export
tally_use_account <- function(account) {
  previous <- tolower(getOption("tallyr.account") %||% "default")

  if (is.null(account) || identical(tolower(account), "default")) {
    options(tallyr.account = NULL)
    cli::cli_alert_success("Using the default Tally account")
    return(invisible(previous))
  }

  if (!is.character(account) || length(account) != 1 || !nzchar(account)) {
    cli::cli_abort("{.arg account} must be a single string, or NULL.")
  }
  account <- tolower(account)

  status <- tally_api_key_status(account)
  if (!status$found) {
    cli::cli_abort(c(
      "No API key found for Tally account {.val {account}}.",
      "i" = "Expected the {.envvar {account_env_var(account)}} environment
             variable to be set.",
      account_hint()
    ))
  }

  options(tallyr.account = account)
  cli::cli_alert_success("Using Tally account {.val {account}}")
  invisible(previous)
}
