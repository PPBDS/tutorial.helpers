# tibble_list_test <- gather_submissions("~/Downloads/responses", title = "probability", email = c("ryanbansal04@gmail.com", "surya.fraser@gmail.com", "darakhshan.fatima110@gmail.com"))
# saveRDS(tibble_list_test, test_path("fixtures", "check_test_dir", "tibble_list_test.rds"))

tibble_list_test <- readRDS(test_path("fixtures", "check_test_dir", "tibble_list_test.rds"))

# Test 1: Basic functionality - should return Ryan's tibble
test_that("check_membership returns correct tibble for single email", {
  result <- check_membership(tibble_list_test, 
                           key_var = "email", 
                           membership = "ryanbansal04@gmail.com", 
                           verbose = FALSE)
  
  # Should return exactly 1 tibble (Ryan's)
  expect_length(result, 1)
  expect_true("probability_answers - Ryan.html" %in% names(result))
  
  # Check that the returned tibble has the correct email
  email_row <- which(result[[1]]$id == "email")
  expect_equal(result[[1]]$answer[email_row], "ryanbansal04@gmail.com")
})

# Test 2: Multiple emails - should return all 3 tibbles
test_that("check_membership returns all tibbles when all emails are included", {
  result <- check_membership(tibble_list_test, 
                           key_var = "email", 
                           membership = c("ryanbansal04@gmail.com", "surya.fraser@gmail.com", "darakhshan.fatima110@gmail.com"), 
                           verbose = FALSE)
  
  expect_length(result, 3)
  expect_setequal(names(result), names(tibble_list_test))
})

# Test 3: Non-existent key variable - should return empty list
test_that("check_membership returns empty list for non-existent key variable", {
  result <- check_membership(tibble_list_test, 
                           key_var = "nonexistent_var", 
                           membership = "umaira.nazar09@gmail.com", 
                           verbose = FALSE)
  
  expect_length(result, 0)
})