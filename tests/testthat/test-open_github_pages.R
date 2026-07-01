# Tests for open_github_pages(). We exercise all the input validation and
# URL-extraction logic. We deliberately stop short of asserting on the final
# system() calls that actually open browser tabs, since those have side effects
# and depend on the OS/browser. Those calls are reached only with valid input;
# the branches below all error or warn before any browser is opened.

test_that("open_github_pages validates its arguments", {
  expect_error(open_github_pages(), "'urls' must be provided")
  expect_error(open_github_pages(NULL), "'urls' must be provided")

  expect_error(open_github_pages("https://example.com", delay_seconds = -1),
               "'delay_seconds' must be a single non-negative numeric value")
  expect_error(
    open_github_pages("https://example.com", delay_seconds = c(1, 2)),
    "'delay_seconds' must be a single non-negative numeric value")

  expect_error(open_github_pages("https://example.com", verbose = "yes"),
               "'verbose' must be a single logical value")

  expect_error(open_github_pages("https://example.com", browser = "netscape"),
               "'browser' must be one of")
})

test_that("open_github_pages rejects bad data.frame input", {
  df <- data.frame(url = "https://example.com", stringsAsFactors = FALSE)

  # url_var required for data.frame input
  expect_error(open_github_pages(df),
               "'url_var' must be provided when 'urls' is a tibble/data.frame")

  # empty data.frame
  empty_df <- data.frame(url = character(0), stringsAsFactors = FALSE)
  expect_error(open_github_pages(empty_df, url_var = "url"),
               "'submission_data' is empty")

  # missing url column
  expect_error(open_github_pages(df, url_var = "nope"),
               "Column 'nope' not found")
})

test_that("open_github_pages errors on unusable url collections", {
  # not a character vector or data.frame
  expect_error(
    open_github_pages(list("https://example.com")),
    "'urls' must be either a character vector or a tibble/data.frame")

  # empty character vector
  expect_error(open_github_pages(character(0)),
               "'urls' vector is empty")

  # all URLs are NA or blank -> nothing left after cleaning
  expect_error(open_github_pages(c(NA, "", "   ")),
               "No valid URLs found after cleaning")
})
