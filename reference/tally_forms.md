# List your Tally forms

Fetches all forms the authenticated user has access to, handling
pagination automatically.

## Usage

``` r
tally_forms(workspace_ids = NULL, account = NULL)
```

## Arguments

- workspace_ids:

  Optional character vector of workspace IDs to restrict the results to.

- account:

  The name of the Tally account whose key to use, e.g. `"work"` for a
  key stored in `TALLY_API_KEY_WORK`. The default `NULL` uses the
  account selected with
  [`tally_use_account()`](https://ellakaye.github.io/tallyr/reference/tally_accounts.md),
  or failing that the default account (`TALLY_API_KEY`).

## Value

A tibble with one row per form and columns `id`, `name`, `status`
(`"BLANK"`, `"DRAFT"`, `"PUBLISHED"` or `"DELETED"`),
`number_of_submissions`, `is_closed`, `workspace_id`, `created_at` and
`updated_at`.

## See also

[`tally_submissions()`](https://ellakaye.github.io/tallyr/reference/tally_submissions.md)
to import a form's data.

## Examples

``` r
if (FALSE) { # \dontrun{
tally_forms()
} # }
```
