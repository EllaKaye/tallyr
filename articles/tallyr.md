# Get started with tallyr

tallyr is an R interface to the [Tally](https://tally.so) form builder
[API](https://developers.tally.so). It covers a simple but common
workflow: authenticate with an API key, list your forms, and import form
submissions as tidy tibbles, ready for analysis.

Because every function here talks to the Tally API, the code in this
vignette isn’t run when the vignette is built; the output shown is from
an example account.

``` r

library(tallyr)
```

## Authentication

Tally uses personal API keys. Create one at [Tally Settings \> API
keys](https://tally.so/settings/api-keys), then store it in the
`TALLY_API_KEY` environment variable in your `.Renviron`, e.g. via
`usethis::edit_r_environ()`:

    TALLY_API_KEY=tly-xxxx

Restart R after editing `.Renviron` so the new variable is picked up.

To confirm you’re authenticated, run
[`tally_whoami()`](https://ellakaye.github.io/tallyr/reference/tally_whoami.md):

``` r

tally_whoami()
#> ✔ Authenticated with Tally as Ada Lovelace (ada@example.com)
```

If something isn’t working,
[`tally_sitrep()`](https://ellakaye.github.io/tallyr/reference/tally_sitrep.md)
gives a full situation report on your setup, with recommendations for
fixing anything that’s wrong – see
[`vignette("troubleshooting")`](https://ellakaye.github.io/tallyr/articles/troubleshooting.md).

If you have more than one Tally account, you can store a key for each
and switch between them – see
[`vignette("multiple-accounts")`](https://ellakaye.github.io/tallyr/articles/multiple-accounts.md).

## Listing your forms

[`tally_forms()`](https://ellakaye.github.io/tallyr/reference/tally_forms.md)
returns a tibble of all the forms you have access to, one row per form:

``` r

tally_forms()
#> # A tibble: 2 × 8
#>   id     name                status    number_of_submissions is_closed
#>   <chr>  <chr>               <chr>                     <int> <lgl>
#> 1 3xLJ5V Conference feedback PUBLISHED                    42 FALSE
#> 2 7bQm2W Workshop signup     DRAFT                         0 FALSE
#> # ℹ 3 more variables: workspace_id <chr>, created_at <dttm>,
#> #   updated_at <dttm>
```

Alongside each form’s `name` and `status` (`"BLANK"`, `"DRAFT"`,
`"PUBLISHED"` or `"DELETED"`), the tibble includes the `id` you’ll need
to import its submissions. The same ID appears in the form’s URL on
tally.so, so you can also read it off there directly.

To restrict the results to particular workspaces, pass their IDs:

``` r

tally_forms(workspace_ids = "w4ZZ9R")
```

## Importing submissions

[`tally_submissions()`](https://ellakaye.github.io/tallyr/reference/tally_submissions.md)
imports a form’s submissions as a wide tibble: one row per submission,
one column per question, with question titles as the column names:

``` r

feedback <- tally_submissions("3xLJ5V")
feedback
#> # A tibble: 42 × 5
#>   submission_id submitted_at        is_completed `What's your name?`
#>   <chr>         <dttm>              <lgl>        <chr>
#> 1 nWxyzA        2026-06-01 10:00:00 TRUE         Ada
#> 2 nWxyzB        2026-06-02 11:30:00 TRUE         Grace
#> # ℹ 40 more rows
#> # ℹ 1 more variable: `How was the conference?` <chr>
```

The first three columns are always `submission_id`, `submitted_at` and
`is_completed`; the rest are the form’s questions, in form order. For
details of how answers are represented and how to tidy them further, see
[`vignette("submission-data")`](https://ellakaye.github.io/tallyr/articles/submission-data.md).

### Filtering

By default you get all submissions, including partial ones (where the
respondent started but didn’t submit the form). Use `filter` to restrict
to one or the other:

``` r

tally_submissions("3xLJ5V", filter = "completed")
tally_submissions("3xLJ5V", filter = "partial")
```

You can also restrict by date with `start_date` and `end_date`, which
accept a Date, a date-time, or an ISO 8601 string:

``` r

tally_submissions("3xLJ5V", start_date = "2026-01-01")
tally_submissions(
  "3xLJ5V",
  filter = "completed",
  start_date = "2026-01-01",
  end_date = "2026-06-30"
)
```

## Pagination and rate limits

The Tally API returns results in pages, and limits clients to 100
requests per minute. You don’t need to manage either:
[`tally_forms()`](https://ellakaye.github.io/tallyr/reference/tally_forms.md)
and
[`tally_submissions()`](https://ellakaye.github.io/tallyr/reference/tally_submissions.md)
fetch all pages automatically, and every request is throttled to stay
within the rate limit.

## Where next

- [`vignette("submission-data")`](https://ellakaye.github.io/tallyr/articles/submission-data.md)
  looks closer at the tibble
  [`tally_submissions()`](https://ellakaye.github.io/tallyr/reference/tally_submissions.md)
  returns and common patterns for tidying it.
- [`vignette("multiple-accounts")`](https://ellakaye.github.io/tallyr/articles/multiple-accounts.md)
  covers working with several Tally accounts in one session.
- [`vignette("troubleshooting")`](https://ellakaye.github.io/tallyr/articles/troubleshooting.md)
  walks through diagnosing setup problems with
  [`tally_sitrep()`](https://ellakaye.github.io/tallyr/reference/tally_sitrep.md).
