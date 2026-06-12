test_that("tally_accounts() lists accounts with keys, default first", {
  local_clean_tally_state()
  withr::local_envvar(
    TALLY_API_KEY = "tly-default",
    TALLY_API_KEY_WORK = "tly-work",
    TALLY_API_KEY_RLADIES = "tly-rladies"
  )
  expect_equal(tally_accounts(), c("default", "rladies", "work"))
})

test_that("tally_accounts() works without a default key, or any keys", {
  local_clean_tally_state()
  withr::local_envvar(TALLY_API_KEY_WORK = "tly-work")
  expect_equal(tally_accounts(), "work")

  local_clean_tally_state()
  expect_equal(tally_accounts(), character())
})

test_that("tally_use_account() switches and returns the previous account", {
  local_clean_tally_state()
  withr::local_envvar(TALLY_API_KEY_WORK = "tly-work")
  withr::local_options(tallyr.account = NULL)

  expect_message(previous <- tally_use_account("work"), "work")
  expect_equal(previous, "default")
  expect_equal(getOption("tallyr.account"), "work")
  expect_equal(tally_api_key(), "tly-work")

  expect_message(previous <- tally_use_account(NULL), "default")
  expect_equal(previous, "work")
  expect_null(getOption("tallyr.account"))
})

test_that("tally_use_account() account names are case-insensitive", {
  local_clean_tally_state()
  withr::local_envvar(TALLY_API_KEY_WORK = "tly-work")
  withr::local_options(tallyr.account = NULL)
  expect_message(tally_use_account("Work"), "work")
  expect_equal(tally_api_key(), "tly-work")
})

test_that("tally_use_account() errors for an account without a key", {
  local_clean_tally_state()
  withr::local_envvar(
    TALLY_API_KEY = "tly-default",
    TALLY_API_KEY_WORK = "tly-work"
  )
  expect_snapshot(tally_use_account("rladies"), error = TRUE)
})

test_that("account resolution: argument beats option beats default", {
  local_clean_tally_state()
  withr::local_envvar(
    TALLY_API_KEY = "tly-default",
    TALLY_API_KEY_WORK = "tly-work",
    TALLY_API_KEY_RLADIES = "tly-rladies"
  )

  expect_equal(tally_api_key(), "tly-default")

  withr::local_options(tallyr.account = "work")
  expect_equal(tally_api_key(), "tly-work")
  expect_equal(tally_api_key(account = "rladies"), "tly-rladies")
})

test_that("a named account ignores the tallyr.api_key option", {
  local_clean_tally_state()
  withr::local_envvar(TALLY_API_KEY_WORK = "tly-work")
  withr::local_options(tallyr.api_key = "tly-from-option")

  expect_equal(tally_api_key(), "tly-from-option")
  expect_equal(tally_api_key(account = "work"), "tly-work")
})

test_that("tally_api_key() errors helpfully for a named account", {
  local_clean_tally_state()
  withr::local_envvar(TALLY_API_KEY_WORK = "tly-work")
  expect_snapshot(tally_api_key(account = "rladies"), error = TRUE)
})
