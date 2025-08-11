test_that("gather_submissions returns a list", {
  result <- gather_submissions(
    path = test_path("fixtures", "process_submissions_dir"),
    title = "."
  )
  expect_type(result, "list")
})

test_that("gather_submissions returns tibbles in the list", {
  result <- gather_submissions(
    path = test_path("fixtures", "process_submissions_dir"),
    title = "."
  )
  expect_true(all(sapply(result, function(x) inherits(x, "tbl_df"))))
})

test_that("gather_submissions works with single pattern", {
  result <- gather_submissions(
    path = test_path("fixtures", "process_submissions_dir"),
    title = "getting"
  )
  expect_true(all(grepl("getting", names(result))))
})

# Better tests using real answer files
library(tibble)

test_that("gather_submissions works with single pattern on real answers", {
  result <- gather_submissions(
    path = test_path("fixtures", "answers_html"),
    title = "stops"
  )

  expect_true(is.list(result))
  expect_true(length(result) == 25)
  expect_true(all(sapply(result, tibble::is_tibble)))
  expect_true(min(sapply(result, nrow)) == 28)
  expect_true(max(sapply(result, nrow)) == 80)
})

