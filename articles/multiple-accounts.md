# Managing multiple Tally accounts

It’s common to have more than one Tally account – a personal one, one
for work, one for a community you help organise. Each account has its
own API keys, and tallyr is designed so that you can keep all of them
set up at once and move between them easily.

As elsewhere in tallyr’s documentation, the code in this vignette isn’t
run at build time; the output shown is from an example setup.

``` r

library(tallyr)
```

## Storing a key per account

Store each account’s key in its own environment variable in your
`.Renviron` (e.g. via `usethis::edit_r_environ()`): `TALLY_API_KEY` for
the default account, and `TALLY_API_KEY_<NAME>` for named accounts. The
`<NAME>` part becomes the account name you use in R, and it’s
case-insensitive:

    TALLY_API_KEY=tly-xxxx
    TALLY_API_KEY_WORK=tly-yyyy
    TALLY_API_KEY_RAINBOWR=tly-zzzz

Restart R after editing `.Renviron`, then check what tallyr can see with
[`tally_accounts()`](https://ellakaye.github.io/tallyr/reference/tally_accounts.md):

``` r

tally_accounts()
#> [1] "default" "rainbowr" "work"
```

The default account comes first if `TALLY_API_KEY` is set, followed by
the named accounts in alphabetical order. You don’t need a default
account at all: if you prefer, give every account a name and skip the
bare `TALLY_API_KEY`.

## Switching accounts for a session

[`tally_use_account()`](https://ellakaye.github.io/tallyr/reference/tally_accounts.md)
switches the active account for the rest of the session. Every tallyr
function then uses that account:

``` r

tally_use_account("work")
#> ✔ Using Tally account "work"

tally_forms() # uses the "work" account
tally_whoami() # reports the "work" user
```

Switch back to the default account with `NULL` or `"default"`:

``` r

tally_use_account("default")
#> ✔ Using the default Tally account
```

[`tally_use_account()`](https://ellakaye.github.io/tallyr/reference/tally_accounts.md)
invisibly returns the name of the account that was active before the
switch, so you can restore it afterwards – handy in scripts and
functions that shouldn’t disturb the session’s state:

``` r

previous <- tally_use_account("rainbowr")
#> ✔ Using Tally account "rainbowr"

# ... work with the "rainbowr" account ...

tally_use_account(previous)
#> ✔ Using the default Tally account
```

If you ask for an account that has no key set,
[`tally_use_account()`](https://ellakaye.github.io/tallyr/reference/tally_accounts.md)
errors immediately, telling you which environment variable it expected
and which accounts *are* available – you won’t find out three calls
later with a confusing authentication failure.

## One-off calls on another account

You don’t have to switch accounts to make a single call as someone else.
Every tallyr function that touches the API takes an `account` argument:

``` r

tally_forms(account = "rainbowr")
tally_submissions("3xLJ5V", account = "work")
tally_whoami(account = "work")
```

The `account` argument affects only that call; the session’s active
account is unchanged.

## How the account is resolved

When a tallyr function needs an API key, it decides which account to use
in this order:

1.  An explicit `account` argument, if you supplied one.
2.  The session’s active account, if you’ve switched with
    [`tally_use_account()`](https://ellakaye.github.io/tallyr/reference/tally_accounts.md).
3.  Otherwise, the default account.

For the default account, the key is looked up first in the
`tallyr.api_key` R option, then in the `TALLY_API_KEY` environment
variable. The option exists so you can set a key for a single session
with `options(tallyr.api_key = "tly-...")`, without touching your
`.Renviron`.

A named account’s key comes *only* from its `TALLY_API_KEY_<NAME>`
environment variable; the `tallyr.api_key` option is never consulted for
named accounts.

## Checking a specific account

[`tally_whoami()`](https://ellakaye.github.io/tallyr/reference/tally_whoami.md)
and
[`tally_sitrep()`](https://ellakaye.github.io/tallyr/reference/tally_sitrep.md)
both take the same `account` argument, so you can confirm which Tally
user a key belongs to without switching:

``` r

tally_whoami(account = "work")
#> ✔ Authenticated with Tally as Ada Lovelace (ada@lovelace.industries)

tally_sitrep(account = "work")
```

If a key isn’t behaving as expected,
[`tally_sitrep()`](https://ellakaye.github.io/tallyr/reference/tally_sitrep.md)
reports where the active key was found, whether it looks like a Tally
key, and whether it authenticates – see
[`vignette("troubleshooting")`](https://ellakaye.github.io/tallyr/articles/troubleshooting.md).
