test_that("gather_submissions returns a list", {
  result <- gather_submissions(
    path = test_path("fixtures", "process_submissions_dir"),
    title = "."
  )
  # Checks that it returns a list 
  expect_type(result, "list")
})

test_that("gather_submissions returns tibbles in the list", {
  result <- gather_submissions(
    path = test_path("fixtures", "process_submissions_dir"),
    title = "."
  )
  
  # Check that all elements in the list are tibbles
  expect_true(all(sapply(result, function(x) inherits(x, "tbl_df"))))
})

test_that("gather_submissions works with single pattern", {
  result <- gather_submissions(
    path = test_path("fixtures", "process_submissions_dir"),
    title = "getting"
  )
  
  # Check that all file names contain the pattern
  expect_true(all(grepl("getting", names(result))))
})

# I am suspicious of the above test cases for gather_submissions. The below test cases 
# should be much better, because they use real answer files and cover trickier cases. 
# Once they look good, we can probably delete the above test cases, and their input files.

library(tibble)

test_that("gather_submissions works with single pattern", {
  result <- gather_submissions(path = "fixtures/answers_html/",
                               title = "stops")
  
  # Check attributes of the returned list of tibbles
  expect_true(is.list(result))
  expect_true(length(result) == 25)
  expect_true(all(sapply(result, tibble::is_tibble)))
  expect_true(min(sapply(result, nrow)) == 28)
  expect_true(max(sapply(result, nrow)) == 80)
})