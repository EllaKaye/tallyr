# Ensure no API key is visible, however the developer's machine is set up
local_no_api_key <- function(env = parent.frame()) {
  withr::local_envvar(TALLY_API_KEY = NA, .local_envir = env)
  withr::local_options(tallyr.api_key = NULL, .local_envir = env)
}

local_fake_api_key <- function(env = parent.frame()) {
  withr::local_envvar(TALLY_API_KEY = "tly-test-key", .local_envir = env)
  withr::local_options(tallyr.api_key = NULL, .local_envir = env)
}

read_fixture <- function(name) {
  jsonlite::read_json(testthat::test_path("fixtures", name))
}
