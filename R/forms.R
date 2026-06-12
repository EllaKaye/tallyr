#' List your Tally forms
#'
#' Fetches all forms the authenticated user has access to, handling
#' pagination automatically.
#'
#' @param workspace_ids Optional character vector of workspace IDs to
#'   restrict the results to.
#' @inheritParams tally_api_key
#' @returns A tibble with one row per form and columns `id`, `name`,
#'   `status` (`"BLANK"`, `"DRAFT"`, `"PUBLISHED"` or `"DELETED"`),
#'   `number_of_submissions`, `is_closed`, `workspace_id`, `created_at`
#'   and `updated_at`.
#' @seealso [tally_submissions()] to import a form's data.
#' @export
#' @examples
#' \dontrun{
#' tally_forms()
#' }
tally_forms <- function(workspace_ids = NULL, account = NULL) {
  req <- tally_request("forms", account = account)
  if (!is.null(workspace_ids)) {
    req <- httr2::req_url_query(
      req,
      workspaceIds = workspace_ids,
      .multi = "explode"
    )
  }
  pages <- tally_paginate(req)
  forms <- purrr::list_flatten(purrr::map(pages, "items"))
  parse_forms(forms)
}

parse_forms <- function(forms) {
  tibble::tibble(
    id = pluck_chr(forms, "id"),
    name = pluck_chr(forms, "name"),
    status = pluck_chr(forms, "status"),
    number_of_submissions = purrr::map_int(
      forms,
      \(f) f$numberOfSubmissions %||% NA_integer_
    ),
    is_closed = purrr::map_lgl(forms, \(f) isTRUE(f$isClosed)),
    workspace_id = pluck_chr(forms, "workspaceId"),
    created_at = parse_tally_datetime(pluck_chr(forms, "createdAt")),
    updated_at = parse_tally_datetime(pluck_chr(forms, "updatedAt"))
  )
}
