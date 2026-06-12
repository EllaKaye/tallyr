test_that("tally_api_key_status() finds key in env var", {
  local_fake_api_key()
  status <- tally_api_key_status()
  expect_equal(status$value, "tly-test-key")
  expect_equal(status$source, "Environment variable: TALLY_API_KEY")
  expect_true(status$found)
  expect_true(status$valid)
})

test_that("tally_api_key_status() prefers the R option over the env var", {
  withr::local_envvar(TALLY_API_KEY = "tly-from-env")
  withr::local_options(tallyr.api_key = "tly-from-option")
  status <- tally_api_key_status()
  expect_equal(status$value, "tly-from-option")
  expect_equal(status$source, "R option: tallyr.api_key")
})

test_that("tally_api_key_status() reports a missing key without erroring", {
  local_no_api_key()
  status <- tally_api_key_status()
  expect_equal(status$value, NA_character_)
  expect_equal(status$source, "Not found")
  expect_false(status$found)
  expect_false(status$valid)
  expect_false(has_tally_api_key())
})

test_that("tally_api_key_status() flags keys without the tly- prefix", {
  withr::local_envvar(TALLY_API_KEY = "not-a-tally-key")
  withr::local_options(tallyr.api_key = NULL)
  status <- tally_api_key_status()
  expect_true(status$found)
  expect_false(status$valid)
})

test_that("tally_api_key() returns the key when set", {
  local_fake_api_key()
  expect_equal(tally_api_key(), "tly-test-key")
})

test_that("tally_api_key() errors informatively when no key is found", {
  local_no_api_key()
  expect_snapshot(tally_api_key(), error = TRUE)
})
