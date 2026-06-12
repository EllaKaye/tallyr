tally_base_url <- "https://api.tally.so"

# Build an authenticated request to the Tally API. Path components are
# passed on to req_url_path_append(), e.g. tally_request("forms", id,
# "submissions"). Aborts (via tally_api_key()) if no key is set.
tally_request <- function(..., account = NULL) {
  httr2::request(tally_base_url) |>
    httr2::req_url_path_append(...) |>
    httr2::req_auth_bearer_token(tally_api_key(account)) |>
    httr2::req_user_agent("tallyr (https://github.com/EllaKaye/tallyr)") |>
    # Tally allows 100 requests per minute
    httr2::req_throttle(capacity = 100, fill_time_s = 60) |>
    httr2::req_error(body = tally_error_body)
}

tally_error_body <- function(resp) {
  body <- tryCatch(httr2::resp_body_json(resp), error = function(e) NULL)
  body$message %||% body$error %||% NULL
}

# Fetch all pages of a paginated endpoint and return a list of parsed
# bodies, one per page. Tally pages with `page`/`limit` query parameters
# and signals the last page with `hasMore: false`.
tally_paginate <- function(req) {
  req <- httr2::req_url_query(req, limit = 500)
  resps <- httr2::req_perform_iterative(
    req,
    next_req = httr2::iterate_with_offset(
      "page",
      resp_complete = function(resp) {
        !isTRUE(httr2::resp_body_json(resp)$hasMore)
      }
    ),
    max_reqs = Inf
  )
  lapply(resps, httr2::resp_body_json)
}
