test_that("find_submissions returns a list", {
  result <- find_submissions(
    path = test_path("fixtures", "process_submissions_dir"),
    title = "."
  )
  # Checks that it returns a list 
  expect_type(result, "list")
})

test_that("find_submissions returns tibbles in the list", {
  result <- find_submissions(
    path = test_path("fixtures", "process_submissions_dir"),
    title = "."
  )
  
  # Check that all elements in the list are tibbles
  expect_true(all(sapply(result, function(x) inherits(x, "tbl_df"))))
})

test_that("find_submissions works with single pattern", {
  result <- find_submissions(
    path = test_path("fixtures", "process_submissions_dir"),
    title = "getting"
  )
  
  # Check that all file names contain the pattern
  expect_true(all(grepl("getting", names(result))))
})
