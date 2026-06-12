# Work with multiple Tally accounts

If you have several Tally accounts, store each account's API key in its
own environment variable in your `.Renviron`: `TALLY_API_KEY` for the
default account, and `TALLY_API_KEY_<NAME>` for named accounts (e.g.
`TALLY_API_KEY_WORK` for an account called `"work"`). Account names are
case-insensitive.

## Usage

``` r
tally_accounts()

tally_use_account(account)
```

## Arguments

- account:

  The account to switch to, e.g. `"work"`. Use `NULL` or `"default"` to
  switch back to the default account.

## Value

`tally_accounts()` returns a character vector of account names,
`"default"` first if `TALLY_API_KEY` is set. `tally_use_account()`
invisibly returns the name of the previously active account, so you can
restore it later.

## Details

`tally_accounts()` lists the accounts that have a key available.
`tally_use_account()` switches the active account for the rest of the
session; all tallyr functions then use that account unless given an
explicit `account` argument.

## See also

[`tally_api_key()`](https://ellakaye.github.io/tallyr/reference/tally_api_key.md)
for how keys are resolved,
[`tally_sitrep()`](https://ellakaye.github.io/tallyr/reference/tally_sitrep.md)
to see your accounts at a glance.

## Examples

``` r
if (FALSE) { # \dontrun{
tally_accounts()

tally_use_account("work")
tally_forms() # uses the "work" account

# one-off call on another account, without switching:
tally_forms(account = "rladies")

# switch back, restoring whatever was active before:
previous <- tally_use_account("rladies")
tally_use_account(previous)
} # }
```
