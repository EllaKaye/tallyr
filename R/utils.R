# Parse the API's ISO 8601 timestamps (e.g. "2026-06-01T10:00:00.000Z");
# strptime ignores the trailing "Z", and Tally times are UTC.
parse_tally_datetime <- function(x) {
  as.POSIXct(x, format = "%Y-%m-%dT%H:%M:%OS", tz = "UTC")
}

# Coerce start_date/end_date arguments to the ISO 8601 strings the API
# expects. NULL passes through (req_url_query() drops it).
format_tally_date <- function(x, arg = rlang::caller_arg(x)) {
  if (is.null(x)) {
    return(NULL)
  }
  if (inherits(x, "Date")) {
    return(format(x, "%Y-%m-%d"))
  }
  if (inherits(x, "POSIXt")) {
    return(format(x, "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"))
  }
  if (is.character(x) && length(x) == 1) {
    return(x)
  }
  cli::cli_abort(
    "{.arg {arg}} must be a Date, a date-time, or an ISO 8601 string,
     not {.obj_type_friendly {x}}."
  )
}

# map_chr() that tolerates NULL/missing elements
pluck_chr <- function(x, field) {
  purrr::map_chr(x, \(el) {
    value <- el[[field]]
    if (is.null(value)) NA_character_ else as.character(value)
  })
}
