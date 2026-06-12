#' Check who you are authenticated as on Tally
#'
#' Calls the Tally API's `/users/me` endpoint to confirm that your API key
#' works, and reports the account it belongs to.
#'
#' @returns Invisibly, a list with the user's details as returned by the
#'   API (including `id`, `fullName`, `email`, `organizationId` and
#'   `subscriptionPlan`).
#' @seealso [tally_api_key()] for setting up authentication,
#'   [tally_sitrep()] for a fuller diagnostic report.
#' @export
#' @examples
#' \dontrun{
#' tally_whoami()
#' }
tally_whoami <- function() {
  user <- tally_user()
  cli::cli_alert_success("Authenticated with Tally as {user_label(user)}")
  invisible(user)
}

# Quiet fetch shared by tally_whoami() and tally_sitrep()
tally_user <- function() {
  tally_request("users", "me") |>
    httr2::req_perform() |>
    httr2::resp_body_json()
}

user_label <- function(user) {
  name <- user$fullName %||% user$email %||% user$id
  email <- user$email
  if (!is.null(email) && !identical(email, name)) {
    paste0(name, " (", email, ")")
  } else {
    name
  }
}
