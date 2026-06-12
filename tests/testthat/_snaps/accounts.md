# tally_use_account() errors for an account without a key

    Code
      tally_use_account("rladies")
    Condition
      Error in `tally_use_account()`:
      ! No API key found for Tally account "rladies".
      i Expected the `TALLY_API_KEY_RLADIES` environment variable to be set.
      i Accounts with a key available: "default" and "work". Switch with `tally_use_account()`.

# tally_api_key() errors helpfully for a named account

    Code
      tally_api_key(account = "rladies")
    Condition
      Error in `tally_api_key()`:
      ! No Tally API key found for account "rladies".
      i Set the `TALLY_API_KEY_RLADIES` environment variable in your '.Renviron' (e.g. with `usethis::edit_r_environ()`).
      i Account with a key available: "work". Switch with `tally_use_account()`.

