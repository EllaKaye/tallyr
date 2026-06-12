test_that("parse_forms() builds a tidy tibble from API form objects", {
  forms <- read_fixture("forms.json")$items
  result <- parse_forms(forms)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 2)
  expect_named(
    result,
    c(
      "id", "name", "status", "number_of_submissions", "is_closed",
      "workspace_id", "created_at", "updated_at"
    )
  )
  expect_equal(result$id, c("form123", "form456"))
  expect_equal(result$status, c("PUBLISHED", "DRAFT"))
  expect_equal(result$number_of_submissions, c(2L, 0L))
  expect_equal(result$is_closed, c(FALSE, TRUE))
  expect_s3_class(result$created_at, "POSIXct")
})

test_that("tally_forms() fetches and parses forms end-to-end", {
  local_fake_api_key()
  httr2::local_mocked_responses(list(
    httr2::response_json(body = read_fixture("forms.json"))
  ))
  result <- tally_forms()
  expect_equal(nrow(result), 2)
  expect_equal(result$name, c("Conference feedback", "Workshop signup"))
})
