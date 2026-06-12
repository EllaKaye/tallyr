# Check who you are authenticated as on Tally

Calls the Tally API's `/users/me` endpoint to confirm that your API key
works, and reports the account it belongs to.

## Usage

``` r
tally_whoami(account = NULL)
```

## Arguments

- account:

  The name of the Tally account whose key to use, e.g. `"work"` for a
  key stored in `TALLY_API_KEY_WORK`. The default `NULL` uses the
  account selected with
  [`tally_use_account()`](https://ellakaye.github.io/tallyr/reference/tally_accounts.md),
  or failing that the default account (`TALLY_API_KEY`).

## Value

Invisibly, a list with the user's details as returned by the API
(including `id`, `fullName`, `email`, `organizationId` and
`subscriptionPlan`).

## See also

[`tally_api_key()`](https://ellakaye.github.io/tallyr/reference/tally_api_key.md)
for setting up authentication,
[`tally_sitrep()`](https://ellakaye.github.io/tallyr/reference/tally_sitrep.md)
for a fuller diagnostic report.

## Examples

``` r
if (FALSE) { # \dontrun{
tally_whoami()
tally_whoami(account = "work")
} # }
```
