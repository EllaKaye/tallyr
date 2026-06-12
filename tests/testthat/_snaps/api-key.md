# tally_api_key() errors informatively when no key is found

    Code
      tally_api_key()
    Condition
      Error in `tally_api_key()`:
      ! No Tally API key found.
      i Create one at <https://tally.so/settings/api-keys> (Tally Settings > API keys).
      i Then set the `TALLY_API_KEY` environment variable in your '.Renviron' (e.g. with `usethis::edit_r_environ()`), or use `options(tallyr.api_key = )` for the current session.

