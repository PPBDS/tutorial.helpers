# tibble_list_test <- gather_submissions("~/Downloads/responses", title = "probability", email = c("ryanbansal04@gmail.com", "surya.fraser@gmail.com", "darakhshan.fatima110@gmail.com"))
# saveRDS(tibble_list_test, test_path("fixtures", "check_test_dir", "tibble_list_test.rds"))

tibble_list_test <- readRDS(test_path("fixtures", "check_test_dir", "tibble_list_test.rds"))

# Test 1: Basic functionality - single key variable that exists
test_that("check_key_vars returns tibbles with required single key variable", {
  result <- check_key_vars(tibble_list_test, key_vars = "email")
  
  # Should return all 3 tibbles since they all have "email"
  expect_length(result, 3)
  expect_setequal(names(result), names(tibble_list_test))
  
  # Check that all returned tibbles have the email variable
  for (tibble_data in result) {
    expect_true("email" %in% tibble_data$id)
  }
})

# Test 2: Multiple key variables that all exist
test_that("check_key_vars returns tibbles with all required multiple key variables", {
  result <- check_key_vars(tibble_list_test, key_vars = c("email", "name"))
  
  # Should return all 3 tibbles since they all have both "email" and "name"
  expect_length(result, 3)
  expect_setequal(names(result), names(tibble_list_test))
  
  # Check that all returned tibbles have both variables
  for (tibble_data in result) {
    expect_true(all(c("email", "name") %in% tibble_data$id))
  }
})

# Test 3: Key variable that doesn't exist in any tibble
test_that("check_key_vars returns empty list when key variable doesn't exist", {
  result <- check_key_vars(tibble_list_test, key_vars = "phone")
  
  expect_length(result, 0)
  expect_equal(result, list())
})