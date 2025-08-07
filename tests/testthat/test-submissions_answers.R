test_dir <- test_path("fixtures", "answers_html")

# Test 1: Real data - existing variables work correctly
test_that("Existing variables return correct values", {
  result <- submissions_answers(
    test_dir, 
    title = "stop", 
    key_var = "email", 
    membership = c("bluebird.jack.xu@gmail.com", "abdul.hannan20008@gmail.com"), 
    vars = c("name", "email")
  )
  
  expect_equal(nrow(result), 2)
  expect_equal(ncol(result), 2)
  expect_false(any(is.na(result)))
  expect_true("name" %in% colnames(result))
  expect_true("email" %in% colnames(result))
  expect_false("answers" %in% colnames(result))
  
  # Test specific values from your real data
  expect_true("Abdul Hannan" %in% result$name)
  expect_true("Jack Xu" %in% result$name)
  expect_true("abdul.hannan20008@gmail.com" %in% result$email)
  expect_true("bluebird.jack.xu@gmail.com" %in% result$email)
})

# Test 2: Missing variables return NA
test_that("Missing variables return NA", {
  result <- submissions_answers(
    test_dir, 
    title = "stop", 
    key_var = "email", 
    membership = c("bluebird.jack.xu@gmail.com", "abdul.hannan20008@gmail.com"), 
    vars = c("name", "email2")  # email2 doesn't exist
  )
  
  expect_equal(nrow(result), 2)
  expect_equal(ncol(result), 2)
  expect_false(any(is.na(result$name)))
  expect_true(all(is.na(result$email2)))
  expect_false("answers" %in% colnames(result))
})

# Test 3: Mixed existing and missing variables
test_that("Mixed variables work correctly", {
  result <- submissions_answers(
    test_dir, 
    title = "stop", 
    key_var = "email", 
    membership = c("bluebird.jack.xu@gmail.com", "abdul.hannan20008@gmail.com"), 
    vars = c("name", "email2", "email")  # email2 missing, others exist
  )
  
  expect_equal(nrow(result), 2)
  expect_equal(ncol(result), 3)
  expect_false(any(is.na(result$name)))
  expect_true(all(is.na(result$email2)))
  expect_false(any(is.na(result$email)))
  expect_false("answers" %in% colnames(result))
  
  # Test specific values are preserved
  expect_true("Abdul Hannan" %in% result$name)
  expect_true("Jack Xu" %in% result$name)
  expect_true("abdul.hannan20008@gmail.com" %in% result$email)
  expect_true("bluebird.jack.xu@gmail.com" %in% result$email)
})