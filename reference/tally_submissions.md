# Import a form's submissions

Fetches all submissions to a Tally form (handling pagination
automatically) and returns them as a wide tibble: one row per
submission, one column per question.

## Usage

``` r
tally_submissions(
  form_id,
  filter = c("all", "completed", "partial"),
  start_date = NULL,
  end_date = NULL,
  account = NULL
)
```

## Arguments

- form_id:

  The form's ID, as found in
  [`tally_forms()`](https://ellakaye.github.io/tallyr/reference/tally_forms.md)
  output or in the form's URL on tally.so.

- filter:

  Which submissions to include: `"all"` (the default), only
  `"completed"`, or only `"partial"`.

- start_date, end_date:

  Optionally restrict to submissions made on or after/before these
  dates. A Date, a date-time, or an ISO 8601 string.

- account:

  The name of the Tally account whose key to use, e.g. `"work"` for a
  key stored in `TALLY_API_KEY_WORK`. The default `NULL` uses the
  account selected with
  [`tally_use_account()`](https://ellakaye.github.io/tallyr/reference/tally_accounts.md),
  or failing that the default account (`TALLY_API_KEY`).

## Value

A tibble with one row per submission. The first columns are
`submission_id`, `submitted_at` and `is_completed`; the remaining
columns are the form's questions, in form order, named by their titles
(made unique if titles repeat). Answers are the API's formatted string
representation, `NA` where a question wasn't answered.

## See also

[`tally_forms()`](https://ellakaye.github.io/tallyr/reference/tally_forms.md)
to find form IDs.

## Examples

``` r
if (FALSE) { # \dontrun{
tally_submissions("3xLJ5V")
tally_submissions("3xLJ5V", filter = "completed", start_date = "2026-01-01")
} # }
```
