library(testthat)
library(tibble)
library(dplyr)
library(withr)

# Mock data for testing
create_mock_submissions <- function() {
  list(
    list(
      id = "question-1",
      type = "question_submission",
      data = list(answer = "Option A"),
      timestamp = "2024-01-15 10:30:00"
    ),
    list(
      id = "exercise-1", 
      type = "exercise_submission",
      data = list(code = "print('Hello World')"),
      timestamp = "2024-01-15 10:35:00"
    ),
    list(
      id = "question-2",
      type = "question_submission", 
      data = list(answer = c("Option B", "Option C")),
      timestamp = "2024-01-15 10:40:00"
    )
  )
}

# Test fixtures setup and cleanup
local_test_fixtures <- function(env = parent.frame()) {
  # Create fixtures
  if (!dir.exists("fixtures/submission_test_outputs")) {
    dir.create("fixtures/submission_test_outputs", recursive = TRUE)
  }
  
  mock_data <- create_mock_submissions()
  saveRDS(mock_data, "fixtures/submission_test_outputs/learnr_submissions_output.rds")
  
  # Schedule cleanup
  withr::defer({
    test_files <- c("test_answers.html", "test_answers.csv", "test_answers.rds")
    file.remove(test_files[file.exists(test_files)])
    
    if (dir.exists("fixtures")) {
      unlink("fixtures", recursive = TRUE)
    }
  }, envir = env)
}

test_that("write_answers creates correct tibble structure", {
  local_test_fixtures()
  
  result <- write_answers("test_answers.rds", session = NULL, is_test = TRUE)
  
  # Check basic structure
  expect_s3_class(result, "tbl_df")
  expect_true(all(c("tutorial_id", "student_name", "id", "submission_type", "answer", "answered") %in% names(result)))
  
  # Check data content
  expect_equal(result$tutorial_id[1], "data-webscraping")
  expect_equal(result$student_name[1], "test_user")
  expect_equal(nrow(result), 5) #(3 answered + 2 unanswered)
})

test_that("write_answers handles different answer types correctly", {
  local_test_fixtures()
  
  result <- write_answers("test_answers.rds", session = NULL, is_test = TRUE)
  
  # Check single answer
  question_1 <- result[result$id == "question-1", ]
  expect_equal(question_1$answer, "Option A")
  
  # Check multiple answers (should be collapsed)
  question_2 <- result[result$id == "question-2", ]
  expect_equal(question_2$answer, "Option B, Option C")
  
  # Check code extraction
  exercise_1 <- result[result$id == "exercise-1", ]
  expect_equal(exercise_1$code, "print('Hello World')")
})

test_that("write_answers includes unanswered questions when requested", {
  local_test_fixtures()
  
  # Test with unanswered questions included (default)
  result_with_unanswered <- write_answers("test_answers.rds", session = NULL, is_test = TRUE, include_unanswered = TRUE)
  
  # Test without unanswered questions  
  result_without_unanswered <- write_answers("test_answers.rds", session = NULL, is_test = TRUE, include_unanswered = FALSE)
  
  # Should have more rows when including unanswered
  expect_gt(nrow(result_with_unanswered), nrow(result_without_unanswered))
  
  # Check that unanswered questions have answered = FALSE
  unanswered <- result_with_unanswered[!result_with_unanswered$answered, ]
  expect_true(nrow(unanswered) > 0)
  expect_true(all(is.na(unanswered$answer)))
})

test_that("write_answers creates HTML file correctly", {
  local_test_fixtures()
  
  write_answers("test_answers.html", session = NULL, is_test = TRUE)
  
  expect_true(file.exists("test_answers.html"))
  
  # Read and check HTML content
  html_content <- readLines("test_answers.html")
  expect_true(any(grepl("Tutorial Answers Report", html_content)))
  expect_true(any(grepl("data-webscraping", html_content)))
  expect_true(any(grepl("question-1", html_content)))
})

test_that("write_answers creates CSV file correctly", {
  local_test_fixtures()
  
  write_answers("test_answers.csv", session = NULL, is_test = TRUE)
  
  expect_true(file.exists("test_answers.csv"))
  
  # Read and check CSV content
  csv_data <- readr::read_csv("test_answers.csv", show_col_types = FALSE)
  expect_s3_class(csv_data, "tbl_df") 
  expect_true("tutorial_id" %in% names(csv_data))
  expect_equal(csv_data$tutorial_id[1], "data-webscraping")
})

test_that("write_answers validates input parameters", {
  # Test invalid file parameter
  expect_error(write_answers(c("file1.html", "file2.html"), NULL, is_test = TRUE),
               "'file' must be a single character string")
  
  # Test invalid file extension
  expect_error(write_answers("test.txt", NULL, is_test = TRUE),
               "File extension must be one of: html, csv, rds")
  
  # Test invalid is_test parameter
  expect_error(write_answers("test.html", NULL, is_test = c(TRUE, FALSE)),
               "'is_test' must be a single logical value")
  
  # Test invalid include_unanswered parameter  
  expect_error(write_answers("test.html", NULL, is_test = TRUE, include_unanswered = "yes"),
               "'include_unanswered' must be a single logical value")
})

test_that("extract_answer helper function works correctly", {
  # Test normal answer
  submission1 <- list(data = list(answer = "Test Answer"))
  expect_equal(extract_answer(submission1), "Test Answer")
  
  # Test multiple answers
  submission2 <- list(data = list(answer = c("A", "B", "C")))
  expect_equal(extract_answer(submission2), "A, B, C")
  
  # Test NULL answer
  submission3 <- list(data = list(answer = NULL))
  expect_true(is.na(extract_answer(submission3)))
  
  # Test missing data structure
  submission4 <- list(answer = "Direct Answer")
  expect_equal(extract_answer(submission4), "Direct Answer")
})

test_that("get_all_tutorial_questions returns expected questions for test", {
  questions <- get_all_tutorial_questions("data-webscraping", is_test = TRUE)
  expected_questions <- c("question-1", "exercise-1", "question-2", "exercise-2", "question-3")
  expect_equal(questions, expected_questions)
  
  # Test non-test mode (should return empty for now)
  questions_real <- get_all_tutorial_questions("some-tutorial", is_test = FALSE)
  expect_equal(length(questions_real), 0)
})

test_that("create_html_report generates valid HTML", {
  local_test_fixtures()
  
  result <- write_answers("test_answers.rds", session = NULL, is_test = TRUE)
  html_lines <- create_html_report(result)
  
  expect_true(any(grepl("<!DOCTYPE html>", html_lines)))
  expect_true(any(grepl("</html>", html_lines)))
  expect_true(any(grepl("Tutorial Answers Report", html_lines)))
  expect_true(any(grepl("data-webscraping", html_lines)))
})

# Test with missing fixture file
test_that("write_answers handles missing fixture file gracefully", {
  # Remove fixture file if it exists
  if (file.exists("fixtures/submission_test_outputs/learnr_submissions_output.rds")) {
    file.remove("fixtures/submission_test_outputs/learnr_submissions_output.rds")
  }
  
  expect_error(write_answers("test.html", NULL, is_test = TRUE),
               "Test fixture file not found")
})