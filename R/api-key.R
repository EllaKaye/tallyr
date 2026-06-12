#' Retrieve your Tally API key
#'
#' Tally uses personal API keys (no OAuth): create one at
#' Tally Settings > API keys (<https://tally.so/settings/api-keys>) and store
#' it where tallyr can find it.
#'
#' For the default account, the key is looked up first in the
#' `tallyr.api_key` R option, then in the `TALLY_API_KEY` environment
#' variable. For regular use, set `TALLY_API_KEY` in your `.Renviron`
#' (e.g. via `usethis::edit_r_environ()`). For a single session, you can
#' instead use `options(tallyr.api_key = "tly-...")`.
#'
#' If you work with several Tally accounts, store each account's key in a
#' `TALLY_API_KEY_<NAME>` environment variable (e.g. `TALLY_API_KEY_WORK`
#' for account `"work"`). A named account's key comes only from its
#' environment variable; the `tallyr.api_key` option is not consulted.
#' See [tally_use_account()] for switching accounts.
#'
#' @param account The name of the Tally account whose key to use, e.g.
#'   `"work"` for a key stored in `TALLY_API_KEY_WORK`. The default `NULL`
#'   uses the account selected with [tally_use_account()], or failing
#'   that the default account (`TALLY_API_KEY`).
#' @returns The API key as a string. Errors with setup instructions if no
#'   key is found.
#' @seealso [tally_use_account()] and [tally_accounts()] for working with
#'   multiple accounts, [tally_sitrep()] to diagnose your setup.
#' @export
#' @examples
#' \dontrun{
#' tally_api_key()
#' tally_api_key(account = "work")
#' }
tally_api_key <- function(account = NULL) {
  status <- tally_api_key_status(account)
  if (!status$found) {
    if (identical(status$account, "default")) {
      cli::cli_abort(c(
        "No Tally API key found.",
        "i" = "Create one at {.url https://tally.so/settings/api-keys}
               (Tally Settings > API keys).",
        "i" = "Then set the {.envvar TALLY_API_KEY} environment variable in
               your {.file .Renviron} (e.g. with
               {.run usethis::edit_r_environ()}), or use
               {.code options(tallyr.api_key = )} for the current session.",
        account_hint()
      ))
    } else {
      cli::cli_abort(c(
        "No Tally API key found for account {.val {status$account}}.",
        "i" = "Set the {.envvar {account_env_var(status$account)}} environment
               variable in your {.file .Renviron}
               (e.g. with {.run usethis::edit_r_environ()}).",
        account_hint()
      ))
    }
  }
  status$value
}

# Checking function in the sitrep style: inspects only, never errors or
# prints, and returns structure rather than a boolean so that callers
# (including tally_sitrep()) have context.
tally_api_key_status <- function(account = NULL) {
  account <- tolower(account %||% getOption("tallyr.account") %||% "default")

  if (identical(account, "default")) {
    opt <- getOption("tallyr.api_key")
    env <- Sys.getenv("TALLY_API_KEY")
    if (!is.null(opt) && nzchar(opt)) {
      value <- as.character(opt)
      source <- "R option: tallyr.api_key"
    } else if (nzchar(env)) {
      value <- env
      source <- "Environment variable: TALLY_API_KEY"
    } else {
      value <- NA_character_
      source <- "Not found"
    }
  } else {
    var <- account_env_var(account)
    env <- Sys.getenv(var)
    if (nzchar(env)) {
      value <- env
      source <- paste0("Environment variable: ", var)
    } else {
      value <- NA_character_
      source <- "Not found"
    }
  }

  found <- !is.na(value)
  list(
    value = value,
    source = source,
    account = account,
    found = found,
    # Tally API keys look like "tly-xxxx"; a mismatch is suspicious but not
    # fatal (only the API itself can really judge), so tally_api_key()
    # aborts on `found`, while tally_sitrep() warns on `valid`.
    valid = found && grepl("^tly-", value)
  )
}

has_tally_api_key <- function(account = NULL) {
  tally_api_key_status(account)$found
}

# "work" -> "TALLY_API_KEY_WORK"; the default account is the bare var
account_env_var <- function(account) {
  if (identical(account, "default")) {
    return("TALLY_API_KEY")
  }
  paste0("TALLY_API_KEY_", gsub("[^A-Za-z0-9]+", "_", toupper(account)))
}

# Extra bullet for missing-key errors, listing accounts that *are* set up.
# Interpolated here with format_inline(): cli_abort() in the caller would
# evaluate {} expressions in the caller's environment.
account_hint <- function() {
  available <- tally_accounts()
  if (length(available) == 0) {
    return(NULL)
  }
  c("i" = cli::format_inline(
    "Account{?s} with a key available: {.val {available}}.
     Switch with {.fun tally_use_account}."
  ))
}
