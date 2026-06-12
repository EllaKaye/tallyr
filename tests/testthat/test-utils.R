test_that("parse_tally_datetime() parses the API's ISO 8601 timestamps", {
  parsed <- parse_tally_datetime("2026-06-01T10:30:15.250Z")
  expect_s3_class(parsed, "POSIXct")
  expect_equal(
    format(parsed, "%Y-%m-%d %H:%M:%S", tz = "UTC"),
    "2026-06-01 10:30:15"
  )
  expect_true(is.na(parse_tally_datetime(NA_character_)))
})

test_that("format_tally_date() handles Dates, date-times and strings", {
  expect_null(format_tally_date(NULL))
  expect_equal(format_tally_date(as.Date("2026-01-15")), "2026-01-15")
  expect_equal(
    format_tally_date(as.POSIXct("2026-01-15 10:00:00", tz = "UTC")),
    "2026-01-15T10:00:00Z"
  )
  expect_equal(format_tally_date("2026-01-15"), "2026-01-15")
  expect_error(format_tally_date(42), "must be a Date")
})
