# Retrieve your Tally API key

Tally uses personal API keys (no OAuth): create one at Tally Settings \>
API keys (<https://tally.so/settings/api-keys>) and store it where
tallyr can find it.

## Usage

``` r
tally_api_key(account = NULL)
```

## Arguments

- account:

  The name of the Tally account whose key to use, e.g. `"work"` for a
  key stored in `TALLY_API_KEY_WORK`. The default `NULL` uses the
  account selected with
  [`tally_use_account()`](https://ellakaye.github.io/tallyr/reference/tally_accounts.md),
  or failing that the default account (`TALLY_API_KEY`).

## Value

The API key as a string. Errors with setup instructions if no key is
found.

## Details

For the default account, the key is looked up first in the
`tallyr.api_key` R option, then in the `TALLY_API_KEY` environment
variable. For regular use, set `TALLY_API_KEY` in your `.Renviron` (e.g.
via `usethis::edit_r_environ()`). For a single session, you can instead
use `options(tallyr.api_key = "tly-...")`.

If you work with several Tally accounts, store each account's key in a
`TALLY_API_KEY_<NAME>` environment variable (e.g. `TALLY_API_KEY_WORK`
for account `"work"`). A named account's key comes only from its
environment variable; the `tallyr.api_key` option is not consulted. See
[`tally_use_account()`](https://ellakaye.github.io/tallyr/reference/tally_accounts.md)
for switching accounts.

## See also

[`tally_use_account()`](https://ellakaye.github.io/tallyr/reference/tally_accounts.md)
and
[`tally_accounts()`](https://ellakaye.github.io/tallyr/reference/tally_accounts.md)
for working with multiple accounts,
[`tally_sitrep()`](https://ellakaye.github.io/tallyr/reference/tally_sitrep.md)
to diagnose your setup.

## Examples

``` r
if (FALSE) { # \dontrun{
tally_api_key()
tally_api_key(account = "work")
} # }
```
