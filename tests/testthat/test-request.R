test_that("tally_request() builds an authenticated request", {
  local_fake_api_key()
  req <- tally_request("forms", "form123", "submissions")
  expect_equal(req$url, "https://api.tally.so/forms/form123/submissions")
  expect_true("Authorization" %in% names(req$headers))
})

test_that("tally_request() errors without an API key", {
  local_no_api_key()
  expect_error(tally_request("forms"), "No Tally API key found")
})

test_that("tally_paginate() follows hasMore across pages", {
  local_fake_api_key()
  httr2::local_mocked_responses(list(
    httr2::response_json(body = list(hasMore = TRUE, items = list("a"))),
    httr2::response_json(body = list(hasMore = FALSE, items = list("b")))
  ))
  pages <- tally_paginate(tally_request("forms"))
  expect_length(pages, 2)
  expect_equal(purrr::map(pages, "items"), list(list("a"), list("b")))
})
