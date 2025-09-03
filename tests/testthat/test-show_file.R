# Test file path using testthat::test_path()
# This automatically finds the file relative to the test directory
test_file <- test_path("fixtures", "show_file_test.txt")
test_file_yaml <- test_path("fixtures", "show_file_yaml_test.qmd")

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
})
