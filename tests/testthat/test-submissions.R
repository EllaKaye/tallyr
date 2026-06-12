test_that("parse_submissions() pivots responses to one column per question", {
  fixture <- read_fixture("submissions.json")
  result <- parse_submissions(fixture$submissions, fixture$questions)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 2)
  # duplicate question titles are repaired to be unique
  expect_named(
    result,
    c(
      "submission_id", "submitted_at", "is_completed",
      "What's your name?", "Favourite colour?...5", "Favourite colour?...6"
    )
  )
  expect_equal(result$submission_id, c("sub_abc", "sub_def"))
  expect_equal(result$is_completed, c(TRUE, FALSE))
  expect_s3_class(result$submitted_at, "POSIXct")

  # formattedAnswer used where present, raw answer as fallback,
  # NA where a question wasn't answered
  expect_equal(result[["What's your name?"]], c("Ada", "Grace"))
  expect_equal(result[["Favourite colour?...5"]], c("Teal, Purple", NA))
  expect_equal(result[["Favourite colour?...6"]], c("It's calming", NA))
})

test_that("parse_submissions() handles a form with no submissions", {
  fixture <- read_fixture("submissions.json")
  result <- parse_submissions(list(), fixture$questions)
  expect_equal(nrow(result), 0)
  expect_equal(ncol(result), 6)
})

test_that("tally_submissions() fetches and pivots end-to-end with pagination", {
  local_fake_api_key()
  fixture <- read_fixture("submissions.json")
  page1 <- fixture
  page1$hasMore <- TRUE
  page1$submissions <- fixture$submissions[1]
  page2 <- fixture
  page2$submissions <- fixture$submissions[2]
  httr2::local_mocked_responses(list(
    httr2::response_json(body = page1),
    httr2::response_json(body = page2)
  ))

  result <- tally_submissions("form123")
  expect_equal(nrow(result), 2)
  expect_equal(result$submission_id, c("sub_abc", "sub_def"))
})

test_that("tally_submissions() validates its arguments", {
  local_fake_api_key()
  expect_error(tally_submissions(42), "must be a single string")
  expect_error(tally_submissions("form123", filter = "nope"), "must be one of")
})
