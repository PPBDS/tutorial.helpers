# Test file path using testthat::test_path()
# This automatically finds the file relative to the test directory
test_file <- test_path("fixtures", "show_file_test.txt")
test_file_yaml <- test_path("fixtures", "show_file_yaml_test.qmd")
test_file_python <- test_path("fixtures", "show_file_python_test.qmd")

# Test cases
test_that("show_file function works correctly", {
  # Test case 1: Display all rows
  expect_equal(paste(capture.output(show_file(test_file)), collapse = "\n"),
               paste(c(
                 "This is line 1.",
                 "This is line 2.",
                 "This is line 3 with the word example.",
                 "```{r}",
                 "# This is a code chunk",
                 "",
                 "x <- 1:10",
                 "print(x)",
                 "```",
                 "This is line 4.",
                 "This is line 5 with another example.",
                 "```{r}",
                 "# Another code chunk",
                 "y <- 20:30",
                 "mean(y)",
                 "```",
                 "This is line 6.",
                 "This is line 7.",
                 "This is line 8.",
                 "This is line 9.",
                 "This is line 10.",
                 "",
                 "This is line 11 with no matching pattern."
               ), collapse = "\n"))
  
  # Test case 2: Display entire file with start = 0
  expect_equal(paste(capture.output(show_file(test_file, start = 0)), collapse = "\n"),
               paste(c(
                 "This is line 1.",
                 "This is line 2.",
                 "This is line 3 with the word example.",
                 "```{r}",
                 "# This is a code chunk",
                 "",
                 "x <- 1:10",
                 "print(x)",
                 "```",
                 "This is line 4.",
                 "This is line 5 with another example.",
                 "```{r}",
                 "# Another code chunk",
                 "y <- 20:30",
                 "mean(y)",
                 "```",
                 "This is line 6.",
                 "This is line 7.",
                 "This is line 8.",
                 "This is line 9.",
                 "This is line 10.",
                 "",
                 "This is line 11 with no matching pattern."
               ), collapse = "\n"))
  
  # Test case 3: Display rows 3 to 7
  expect_equal(paste(capture.output(show_file(test_file, start = 3, end = 7)), collapse = "\n"),
               paste(c(
                 "This is line 3 with the word example.",
                 "```{r}",
                 "# This is a code chunk",
                 "",
                 "x <- 1:10"
               ), collapse = "\n"))
  
  # Test case 4: Display rows matching the pattern "example"
  expect_equal(paste(capture.output(show_file(test_file, pattern = "example")), collapse = "\n"),
               paste(c(
                 "This is line 3 with the word example.",
                 "This is line 5 with another example."
               ), collapse = "\n"))
  
  # Test case 5: Print all code chunks
  expect_equal(paste(capture.output(show_file(test_file, chunk = "All")), collapse = "\n"),
               paste(c(
                 "# This is a code chunk",
                 "",
                 "x <- 1:10",
                 "print(x)",
                 "",
                 "# Another code chunk",
                 "y <- 20:30",
                 "mean(y)"
               ), collapse = "\n"))
  
  # Test case 6: Print the last code chunk
  expect_equal(paste(capture.output(show_file(test_file, chunk = "Last")), collapse = "\n"),
               paste(c(
                 "# Another code chunk",
                 "y <- 20:30",
                 "mean(y)"
               ), collapse = "\n"))
  
  # Test case 7: Invalid chunk value (numeric)
  expect_error(show_file(test_file, chunk = 1), 
               "chunk must be one of: None, All, Last, YAML")
  
  # Test case 8: Invalid chunk value (incorrect string)
  expect_error(show_file(test_file, chunk = "invalid"), 
               "chunk must be one of: None, All, Last, YAML")
  
  # Test case 9: Extract YAML header (assuming test_file_yaml has proper YAML)

  expect_equal(paste(capture.output(show_file(test_file_yaml, chunk = "YAML")), collapse = "\n"),
               paste(c(
                 'title: "Test Document"',
                 'author: "Test Author"',
                 'date: "2024-01-01"'
               ), collapse = "\n"))
  
  # Test case 10: No YAML header found
  expect_error(show_file(test_file, chunk = "YAML"), 
               "No YAML header found.")
  
  # Test case 11: File does not exist
  expect_error(show_file("nonexistent_file.txt"), "File does not exist.")
  
  # Test case 12: Start is greater than end
  expect_error(show_file(test_file, start = 5, end = 3), "start must be smaller or equal to end.")
  
  # Test case 13: End is out of range
  expect_error(show_file(test_file, end = 30), "start and end must be within the valid range of rows.")
  
  # Test case 14: Print the last 3 lines of the file
  expect_equal(paste(capture.output(show_file(test_file, start = -3)), collapse = "\n"),
               paste(c(
                 "This is line 10.",
                 "",
                 "This is line 11 with no matching pattern."
               ), collapse = "\n"))
  
  # Test case 15: No rows matching the pattern
  expect_equal(paste(capture.output(show_file(test_file, pattern = "nomatch")), collapse = "\n"), "")

  # Test case 16: Empty file prints "File is empty."
  empty_file <- tempfile()
  file.create(empty_file)
  on.exit(unlink(empty_file), add = TRUE)
  expect_equal(paste(capture.output(show_file(empty_file)), collapse = "\n"),
               "File is empty.")

  # Test case 17: A file containing only blank lines prints "File is empty."
  blank_file <- tempfile()
  writeLines(c("", "", ""), blank_file)
  on.exit(unlink(blank_file), add = TRUE)
  expect_equal(paste(capture.output(show_file(blank_file)), collapse = "\n"),
               "File is empty.")

  # Test case 18: chunk = "None" (the default) shows the whole file unchanged
  expect_equal(paste(capture.output(show_file(test_file, chunk = "None")), collapse = "\n"),
               paste(capture.output(show_file(test_file)), collapse = "\n"))

  # Test case 19: pattern combined with a row range
  expect_equal(paste(capture.output(show_file(test_file, start = 1, end = 5, pattern = "example")), collapse = "\n"),
               paste(c(
                 "This is line 3 with the word example."
               ), collapse = "\n"))

  # Test case 20: pattern combined with start = 0 (whole file) -- Bug #1
  expect_equal(paste(capture.output(show_file(test_file, start = 0, pattern = "example")), collapse = "\n"),
               paste(c(
                 "This is line 3 with the word example.",
                 "This is line 5 with another example."
               ), collapse = "\n"))

  # Test case 21: pattern combined with a negative start -- Bug #1
  expect_equal(paste(capture.output(show_file(test_file, start = -5, pattern = "matching")), collapse = "\n"),
               paste(c(
                 "This is line 11 with no matching pattern."
               ), collapse = "\n"))

  # Test case 22: negative start larger than the file returns all lines
  expect_equal(paste(capture.output(show_file(test_file, start = -100)), collapse = "\n"),
               paste(capture.output(show_file(test_file, start = 0)), collapse = "\n"))

  # Test case 23: chunk = "Last" on a qmd with named R chunks
  expect_equal(paste(capture.output(show_file(test_file_yaml, chunk = "Last")), collapse = "\n"),
               paste(c(
                 "x <- 1:10",
                 "mean(x)"
               ), collapse = "\n"))

  # Test case 24: chunk = "All" on a qmd with named R chunks
  expect_equal(paste(capture.output(show_file(test_file_yaml, chunk = "All")), collapse = "\n"),
               paste(c(
                 "library(tidyverse)",
                 "",
                 "x <- 1:10",
                 "mean(x)"
               ), collapse = "\n"))

  # Test case 25: chunk = "Last" works on Python chunks
  expect_equal(paste(capture.output(show_file(test_file_python, chunk = "Last")), collapse = "\n"),
               paste(c(
                 'df = pd.DataFrame({"x": [1, 2, 3]})',
                 "df.head()"
               ), collapse = "\n"))

  # Test case 26: chunk = "All" captures all Python chunks
  expect_equal(paste(capture.output(show_file(test_file_python, chunk = "All")), collapse = "\n"),
               paste(c(
                 "import pandas as pd",
                 "",
                 'df = pd.DataFrame({"x": [1, 2, 3]})',
                 "df.head()"
               ), collapse = "\n"))

  # Test case 27: single-line file with no YAML errors cleanly -- Bug #2
  one_line_file <- tempfile(fileext = ".txt")
  writeLines("only one line", one_line_file)
  on.exit(unlink(one_line_file), add = TRUE)
  expect_error(show_file(one_line_file, chunk = "YAML"), "No YAML header found.")
})
