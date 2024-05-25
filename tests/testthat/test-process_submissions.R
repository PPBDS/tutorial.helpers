test_dir <- "fixtures/process_submissions_dir/"

# Currently, I do not have tests which explore the verbose = 1 case.


# Tests which confirm that the returned tibble is correct.

test_that("process_submissions returns the expected summary tibble", {
  expected_output <- tibble::tibble(
    `information-name` = c("Areeb Atif", "Gitanjali Sheth"),
    answers = c(11L, 11L)
  )
  
  actual_output <- process_submissions(
    path = test_dir,
    pattern = "getting",
    key_vars = c("information-name")
  )
  
  expect_equal(actual_output, expected_output)
})

test_that("process_submissions returns the expected summary tibble with email key_var", {
  expected_output <- tibble::tibble(
    `information-email` = c("dave.kane@gmail.com", "areebatif2007@gmail.com", "gbhatia1@yahoo.com"),
    answers = c(6L, 11L, 11L)
  )
  
  actual_output <- process_submissions(
    path = test_dir,
    pattern = "get",
    key_vars = c("information-email")
  )
  
  expect_equal(actual_output, expected_output)
})

test_that("process_submissions returns the expected summary tibble with name and email key_vars", {
  expected_output <- tibble::tibble(
    `information-name` = c("David Kane", "Areeb Atif", "Gitanjali Sheth"),
    `information-email` = c("dave.kane@gmail.com", "areebatif2007@gmail.com", "gbhatia1@yahoo.com"),
    answers = c(6L, 11L, 11L)
  )
  
  actual_output <- process_submissions(
    path = test_dir,
    pattern = "get",
    key_vars = c("information-name", "information-email")
  )
  
  expect_equal(actual_output, expected_output)
})

test_that("process_submissions returns a tibble of the expected size with return_value 'All'", {
  actual_output <- process_submissions(
    path = test_dir,
    pattern = "getting",
    return_value = "All"
  )
  
  expect_s3_class(actual_output, "tbl_df")
  expect_equal(dim(actual_output), c(22L, 3L))
})

test_that("process_submissions returns a tibble of the expected size with return_value 'All' and pattern 'get'", {
  actual_output <- process_submissions(
    path = test_dir,
    pattern = "get",
    return_value = "All"
  )
  
  expect_s3_class(actual_output, "tbl_df")
  expect_equal(dim(actual_output), c(28L, 3L))
})

test_that("process_submissions with one key_var", {
  actual_output <- process_submissions(
    path = test_dir,
    pattern = "get",
    return_value = "All",
    key_vars = "information-name"
  )
  
  expect_s3_class(actual_output, "tbl_df")
  expect_equal(dim(actual_output), c(28L, 4L))
})

test_that("process_submissions with two key_vars", {
  actual_output <- process_submissions(
    path = test_dir,
    pattern = "get",
    return_value = "All",
    key_vars = c("information-name", "information-email")
  )
  
  expect_s3_class(actual_output, "tbl_df")
  expect_equal(dim(actual_output), c(28L, 5L))
})

# Tests for various messages

test_that("process_submissions prints the correct messages when verbose is 1", {
  captured_messages <- capture_messages(
    process_submissions(
      path = test_dir,
      pattern = "getting",
      return_value = "All",
      verbose = 1
    )
  )
  
  expect_equal(
    captured_messages,
    c(
      "There are 7 files in the directory.\n",
      "There are 6 HTML/XML files in the directory.\n",
      "There are 2 HTML/XML files matching the pattern 'getting'.\n",
      "There were 2 files with valid HTML tables.\n",
      "There were 2 files with no problems.\n"
    )
  )
})

test_that("process_submissions prints the correct messages for error files", {
  captured_messages <- capture_messages(
    process_submissions(
      path = test_dir,
      pattern = "err1|err2",
      return_value = "All",
      key_vars = "information-id",
      verbose = 1
    )
  )
  
  expect_equal(
    captured_messages,
    c(
      "There are 7 files in the directory.\n",
      "There are 6 HTML/XML files in the directory.\n",
      "There are 2 HTML/XML files matching the pattern 'err1|err2'.\n",
      "There were 1 files with valid HTML tables.\n",
      "There were 0 files with no problems.\n"
    )
  )
})

# Tests which confirm various errors.

test_that("process_submissions stops with an error when return_value is 'Summary' and no key_vars are provided", {
  expect_error(
    process_submissions(
      path = test_dir,
      pattern = "get",
      return_value = "Summary"
    ),
    "key_vars must be provided when return_value is 'Summary'."
  )
})

test_that("process_submissions stops with an error when the specified directory does not exist", {
  expect_error(
    process_submissions(
      path = "z",
      pattern = "get",
      return_value = "All"
    ),
    "The specified directory does not exist."
  )
})

test_that("process_submissions stops with an error when an invalid return_value is provided", {
  expect_error(
    process_submissions(
      path = test_dir,
      pattern = "get",
      return_value = "wrong"
    ),
    "Invalid return_value. Allowed values are 'Summary' or 'All'."
  )
})


