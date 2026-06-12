test_that("tally_sitrep() reports a missing key with recommendations", {
  local_no_api_key()
  local_mocked_bindings(tally_has_internet = function() TRUE)
  expect_snapshot(result <- tally_sitrep())
  expect_false(result$api_key$found)
  expect_null(result$user)
})

test_that("tally_sitrep() reports a working setup", {
  local_fake_api_key()
  local_mocked_bindings(
    tally_has_internet = function() TRUE,
    tally_user = function(account = NULL) {
      list(fullName = "Ada Lovelace", email = "ada@example.com")
    }
  )
  expect_snapshot(result <- tally_sitrep())
  expect_equal(result$user$fullName, "Ada Lovelace")
})

test_that("tally_sitrep() reports an API failure without erroring", {
  local_fake_api_key()
  local_mocked_bindings(
    tally_has_internet = function() TRUE,
    tally_user = function(account = NULL) stop("HTTP 401 Unauthorized.")
  )
  expect_snapshot(result <- tally_sitrep())
  expect_null(result$user)
})

test_that("tally_sitrep() suggests switching when others have keys", {
  local_clean_tally_state()
  withr::local_envvar(TALLY_API_KEY_WORK = "tly-work")
  local_mocked_bindings(tally_has_internet = function() TRUE)
  expect_snapshot(result <- tally_sitrep())
  expect_equal(result$accounts, "work")
  expect_false(result$api_key$found)
})

test_that("tally_whoami() reports the authenticated user", {
  local_fake_api_key()
  local_mocked_bindings(
    tally_user = function(account = NULL) {
      list(fullName = "Ada Lovelace", email = "ada@example.com")
    }
  )
  expect_snapshot(user <- tally_whoami())
  expect_equal(user$email, "ada@example.com")
})
