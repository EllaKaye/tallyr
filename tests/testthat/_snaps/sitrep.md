# tally_sitrep() reports a missing key with recommendations

    Code
      result <- tally_sitrep()
    Message
      
      -- tallyr situation report -----------------------------------------------------
      
      -- Accounts 
      ! No account keys found in environment variables
      i Active account: "default" (the default)
      
      -- API key 
      x No API key found for account "default"
      
      -- Connectivity 
      v Internet: online
      i Skipping API connection test
      
      -- Recommendations 
      * Create an API key at <https://tally.so/settings/api-keys>
      * Set `TALLY_API_KEY` in your '.Renviron' (e.g. with
      `usethis::edit_r_environ()`)

# tally_sitrep() reports a working setup

    Code
      result <- tally_sitrep()
    Message
      
      -- tallyr situation report -----------------------------------------------------
      
      -- Accounts 
      i Account with a key available: "default"
      i Active account: "default" (the default)
      
      -- API key 
      v API key found
      i Source: Environment variable: TALLY_API_KEY
      v Key format looks valid (starts with "tly-")
      
      -- Connectivity 
      v Internet: online
      v Authenticated as Ada Lovelace (ada@example.com)
      
      -- Recommendations 
      v tallyr setup looks good!

# tally_sitrep() reports an API failure without erroring

    Code
      result <- tally_sitrep()
    Message
      
      -- tallyr situation report -----------------------------------------------------
      
      -- Accounts 
      i Account with a key available: "default"
      i Active account: "default" (the default)
      
      -- API key 
      v API key found
      i Source: Environment variable: TALLY_API_KEY
      v Key format looks valid (starts with "tly-")
      
      -- Connectivity 
      v Internet: online
      x Tally API connection failed: HTTP 401 Unauthorized.
      
      -- Recommendations 
      * Check your key is current, or regenerate it at
      <https://tally.so/settings/api-keys>

# tally_sitrep() suggests switching when others have keys

    Code
      result <- tally_sitrep()
    Message
      
      -- tallyr situation report -----------------------------------------------------
      
      -- Accounts 
      i Account with a key available: "work"
      i Active account: "default" (the default)
      
      -- API key 
      x No API key found for account "default"
      
      -- Connectivity 
      v Internet: online
      i Skipping API connection test
      
      -- Recommendations 
      * Create an API key at <https://tally.so/settings/api-keys>
      * Set `TALLY_API_KEY` in your '.Renviron' (e.g. with
      `usethis::edit_r_environ()`)
      * Or switch to an account with a key: `tally_use_account("work")`

# tally_whoami() reports the authenticated user

    Code
      user <- tally_whoami()
    Message
      v Authenticated with Tally as Ada Lovelace (ada@example.com)

