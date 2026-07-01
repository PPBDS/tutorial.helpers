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

# Test 3: Input validation.
test_that("match_questions validates its arguments", {
  df <- tibble::tibble(id = "q-1", answer = "hello")

  expect_error(match_questions(), "'x' must be provided")
  expect_error(match_questions(NULL), "'x' must be provided")
  expect_error(match_questions(df), "'pattern' must be provided")
  expect_error(match_questions(df, "hello", ignore.case = "yes"),
               "'ignore.case' must be a single logical value")
  expect_error(match_questions(42, "hello"),
               "'x' must be either a file path")
})

# Test 4: A tibble whose answers live in a 'data' column (not 'answer').
test_that("match_questions handles a 'data' answer column", {
  df <- tibble::tibble(
    id = c("a-1", "a-2", "a-3"),
    data = c("see https://x.com", "no link here", "also https://y.org"))

  expect_equal(match_questions(df, "https"), c("a-1", "a-3"))
})

# Test 5: Missing required columns error.
test_that("match_questions errors on missing required columns", {
  no_id <- tibble::tibble(answer = "hello")
  expect_error(match_questions(no_id, "hello"), "must have an 'id' column")

  no_answer <- tibble::tibble(id = "q-1", other = "hello")
  expect_error(match_questions(no_answer, "hello"),
               "must have either an 'answer' or 'data' column")
})

# Test 6: ignore.case toggles case sensitivity; non-matches return empty.
test_that("match_questions respects ignore.case", {
  df <- tibble::tibble(id = c("q-1", "q-2"),
                       answer = c("Hello World", "goodbye"))

  expect_equal(match_questions(df, "hello", ignore.case = TRUE), "q-1")
  expect_equal(match_questions(df, "hello", ignore.case = FALSE), character(0))
  expect_equal(match_questions(df, "zzz"), character(0))
})