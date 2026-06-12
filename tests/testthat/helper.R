# Ensure no Tally state is visible, however the developer's machine is set
# up: clears TALLY_API_KEY and all TALLY_API_KEY_* env vars, plus the
# tallyr options, for the duration of the calling test.
local_clean_tally_state <- function(env = parent.frame()) {
  vars <- names(Sys.getenv())
  vars <- union(vars[startsWith(vars, "TALLY_API_KEY")], "TALLY_API_KEY")
  unset <- rep(list(NA), length(vars))
  names(unset) <- vars
  withr::local_envvar(unset, .local_envir = env)
  withr::local_options(
    tallyr.api_key = NULL,
    tallyr.account = NULL,
    .local_envir = env
  )
}

local_no_api_key <- function(env = parent.frame()) {
  local_clean_tally_state(env)
}

local_fake_api_key <- function(env = parent.frame()) {
  local_clean_tally_state(env)
  withr::local_envvar(TALLY_API_KEY = "tly-test-key", .local_envir = env)
}

read_fixture <- function(name) {
  jsonlite::read_json(testthat::test_path("fixtures", name))
}
