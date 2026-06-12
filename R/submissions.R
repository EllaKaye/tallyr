#' Import a form's submissions
#'
#' Fetches all submissions to a Tally form (handling pagination
#' automatically) and returns them as a wide tibble: one row per
#' submission, one column per question.
#'
#' @param form_id The form's ID, as found in [tally_forms()] output or in
#'   the form's URL on tally.so.
#' @param filter Which submissions to include: `"all"` (the default),
#'   only `"completed"`, or only `"partial"`.
#' @param start_date,end_date Optionally restrict to submissions made on
#'   or after/before these dates. A Date, a date-time, or an ISO 8601
#'   string.
#' @returns A tibble with one row per submission. The first columns are
#'   `submission_id`, `submitted_at` and `is_completed`; the remaining
#'   columns are the form's questions, in form order, named by their
#'   titles (made unique if titles repeat). Answers are the API's
#'   formatted string representation, `NA` where a question wasn't
#'   answered.
#' @seealso [tally_forms()] to find form IDs.
#' @export
#' @examples
#' \dontrun{
#' tally_submissions("3xLJ5V")
#' tally_submissions("3xLJ5V", filter = "completed", start_date = "2026-01-01")
#' }
tally_submissions <- function(
  form_id,
  filter = c("all", "completed", "partial"),
  start_date = NULL,
  end_date = NULL
) {
  if (!is.character(form_id) || length(form_id) != 1 || !nzchar(form_id)) {
    cli::cli_abort("{.arg form_id} must be a single string.")
  }
  filter <- rlang::arg_match(filter)

  req <- tally_request("forms", form_id, "submissions") |>
    httr2::req_url_query(
      filter = filter,
      startDate = format_tally_date(start_date),
      endDate = format_tally_date(end_date)
    )
  pages <- tally_paginate(req)

  questions <- pages[[1]]$questions
  submissions <- purrr::list_flatten(purrr::map(pages, "submissions"))
  parse_submissions(submissions, questions)
}

parse_submissions <- function(submissions, questions) {
  meta_cols <- list(
    submission_id = pluck_chr(submissions, "id"),
    submitted_at = parse_tally_datetime(pluck_chr(submissions, "submittedAt")),
    is_completed = purrr::map_lgl(submissions, \(s) isTRUE(s$isCompleted))
  )

  question_ids <- pluck_chr(questions, "id")
  answer_cols <- purrr::map(question_ids, \(qid) {
    purrr::map_chr(submissions, \(sub) {
      response <- purrr::detect(
        sub$responses,
        \(r) identical(r$questionId, qid)
      )
      if (is.null(response)) NA_character_ else format_answer(response)
    })
  })
  names(answer_cols) <- pluck_chr(questions, "title")

  tibble::as_tibble(
    c(meta_cols, answer_cols),
    .name_repair = "unique_quiet"
  )
}

# The API provides formattedAnswer as a consistent string representation
# across question types; fall back to flattening the raw answer.
format_answer <- function(response) {
  formatted <- response$formattedAnswer
  if (!is.null(formatted)) {
    return(as.character(formatted))
  }
  answer <- response$answer
  if (is.null(answer)) {
    return(NA_character_)
  }
  paste(unlist(answer), collapse = ", ")
}
