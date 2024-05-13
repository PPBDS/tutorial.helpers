# 

test_that("process_submissions returns correct summary when at least one of the files has an id", {
  # Set up the test fixture
  test_dir <- "fixtures/process_submissions_dir/"
  test_pattern <- "get"
  
  # Define the expected output
  expected_output <- tibble::tibble(
    name = c("David Kane", "Areeb Atif", "Gitanjali Sheth"),
    email = c("dave.kane@gmail.com", "areebatif2007@gmail.com", "gbhatia1@yahoo.com"),
    id = c("7598", NA, NA),
    time = c("3", "14", "15"),
    answers = c(6, 11, 11)
  )
  
  # Call the function with the test fixture and capture the output
  actual_output <- process_submissions(test_dir, pattern = test_pattern)
  
  # Compare the actual output with the expected output
  expect_equal(actual_output, expected_output)
})

test_that("process_submissions returns correct summary when no entries have an id", {
  # Set up the test fixture
  test_dir <- "fixtures/process_submissions_dir/"
  test_pattern <- "getting"
  
  # Define the expected output
  expected_output <- tibble::tibble(
    name = c("Areeb Atif", "Gitanjali Sheth"),
    email = c("areebatif2007@gmail.com", "gbhatia1@yahoo.com"),
    time = c("14", "15"),
    answers = c(11,11)
  )
  
  # Call the function with the test fixture and capture the output
  actual_output <- process_submissions(test_dir, pattern = test_pattern)
  
  # Compare the actual output with the expected output
  expect_equal(actual_output, expected_output)
})



test_that("process_submissions returns full submission data", {
  # Set up the test fixture
  test_dir <- "fixtures/process_submissions_dir/"
  test_pattern <- "getting"
  
  # Call the function with the test fixture and capture the output
  actual_output <- process_submissions(test_dir, pattern = test_pattern, return_value = "All")
  
  # Check if the output is a tibble
  expect_s3_class(actual_output, "tbl_df")
  
  # Check if the output has the expected columns
  expected_columns <- c("id", "submission_type", "answer")
  expect_named(actual_output, expected_columns)
  
  # Check if the output has the expected number of rows
  expected_rows <- 22  # Adjust this based on the actual number of rows in the test files
  expect_equal(nrow(actual_output), expected_rows)
})



