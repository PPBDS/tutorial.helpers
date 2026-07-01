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

# Test 4: verbose = TRUE reports the email summary while returning the same
# result as verbose = FALSE.
test_that("check_membership verbose output reports the email summary", {
  membership <- c("ryanbansal04@gmail.com", "not.a.real.student@gmail.com")

  expect_message(
    result <- check_membership(tibble_list_test, key_var = "email",
                               membership = membership, verbose = TRUE),
    "Email summary:")

  # The kept set still resolves to exactly Ryan's submission.
  expect_length(result, 1)
  expect_true("probability_answers - Ryan.html" %in% names(result))

  # Specific summary lines are emitted.
  expect_message(
    check_membership(tibble_list_test, key_var = "email",
                     membership = membership, verbose = TRUE),
    "Membership emails not found")
  expect_message(
    check_membership(tibble_list_test, key_var = "email",
                     membership = membership, verbose = TRUE),
    "Final result: 1 tibble")
})

# Test 5: verbose = TRUE on a key variable that no tibble has reports the
# early-exit message and returns an empty list.
test_that("check_membership verbose reports when no tibble has the key var", {
  expect_message(
    result <- check_membership(tibble_list_test, key_var = "nonexistent_var",
                               membership = "ryanbansal04@gmail.com",
                               verbose = TRUE),
    "No tibbles contain the required key variable")
  expect_length(result, 0)
})