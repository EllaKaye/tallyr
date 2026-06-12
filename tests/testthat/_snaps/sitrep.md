# tally_sitrep() reports a missing key with recommendations

    Code
      result <- tally_sitrep()
    Message
      
      -- tallyr situation report -----------------------------------------------------
      
      -- API key 
      x No API key found
      
      -- Connectivity 
      v Internet: online
      i Skipping API connection test
      
      -- Recommendations 
      * Create an API key at <https://tally.so/settings/api-keys>
      * Set `TALLY_API_KEY` in your '.Renviron' (e.g. with
      `usethis::edit_r_environ()`), or use `options(tallyr.api_key = )` for the
      current session

# tally_sitrep() reports a working setup

    Code
      result <- tally_sitrep()
    Message
      
      -- tallyr situation report -----------------------------------------------------
      
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

# tally_whoami() reports the authenticated user

    Code
      user <- tally_whoami()
    Message
      v Authenticated with Tally as Ada Lovelace (ada@example.com)

