# Situation report for your Tally setup

Reports everything relevant to tallyr working: which accounts have keys
available and which is active, whether the active account's API key was
found (and where), whether it looks like a Tally key, whether you are
online, and whether the key actually authenticates against the Tally
API. Ends with recommendations for fixing anything that's wrong. Never
errors, whatever the state of your setup.

## Usage

``` r
tally_sitrep(account = NULL)
```

## Arguments

- account:

  The name of the Tally account whose key to use, e.g. `"work"` for a
  key stored in `TALLY_API_KEY_WORK`. The default `NULL` uses the
  account selected with
  [`tally_use_account()`](https://ellakaye.github.io/tallyr/reference/tally_accounts.md),
  or failing that the default account (`TALLY_API_KEY`).

## Value

Invisibly, a list with components `api_key` (the key status), `accounts`
(available account names), `online` (logical) and `user` (the
authenticated user, or `NULL` if the connectivity test failed or wasn't
run).

## See also

[`tally_api_key()`](https://ellakaye.github.io/tallyr/reference/tally_api_key.md),
[`tally_use_account()`](https://ellakaye.github.io/tallyr/reference/tally_accounts.md),
[`tally_whoami()`](https://ellakaye.github.io/tallyr/reference/tally_whoami.md)

## Examples

``` r
if (FALSE) { # \dontrun{
tally_sitrep()
} # }
```
