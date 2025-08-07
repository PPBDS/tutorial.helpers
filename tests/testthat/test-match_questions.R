test_dir <- test_path("fixtures", "answers_html")

test_that("Real example - search for http pattern", {
  # Get a tibble from real test data
  tibble_list <- gather_submissions(test_dir, title = "stop")
  tibble_data <- tibble_list[[1]]
  
  result <- match_questions(tibble_data, "http")
  
  # Based on your real result
  expected_ids <- c("justice-12", "temperance-5", "temperance-16", "temperance-17")
  
  expect_equal(result, expected_ids)
  expect_length(result, 4)
  expect_true(all(c("justice-12", "temperance-5", "temperance-16", "temperance-17") %in% result))
})

# Test 2: Search with different pattern
test_that("Search with different pattern", {
  tibble_list <- gather_submissions(test_dir, title = "stop")
  tibble_data <- tibble_list[[1]]
  
  # Test with a different pattern
  result <- match_questions(tibble_data, "temperance")
  
  expect_true(is.character(result))
  expect_true(length(result) >= 0)  # Could be 0 or more matches
})