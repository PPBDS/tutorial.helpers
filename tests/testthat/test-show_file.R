# Test file path
test_file <- "fixtures/show_file_test.txt"

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
  
  # Test case 2: Display rows 3 to 7
  expect_equal(paste(capture.output(show_file(test_file, start = 3, end = 7)), collapse = "\n"),
               paste(c(
                 "This is line 3 with the word example.",
                 "```{r}",
                 "# This is a code chunk",
                 "",
                 "x <- 1:10"
               ), collapse = "\n"))
  
  # Test case 3: Display rows matching the pattern "example"
  expect_equal(paste(capture.output(show_file(test_file, pattern = "example")), collapse = "\n"),
               paste(c(
                 "This is line 3 with the word example.",
                 "This is line 5 with another example."
               ), collapse = "\n"))
  
  # Test case 4: Print all code chunks
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
  
  # Test case 5: File does not exist
  expect_error(show_file("nonexistent_file.txt"), "File does not exist.")
  
  # Test case 6: Start is greater than end
  expect_error(show_file(test_file, start = 5, end = 3), "start must be smaller or equal to end.")
  
  # Test case 7: Start is out of range
  expect_error(show_file(test_file, start = 0), "start and end must be within the valid range of rows.")
  
  # Test case 8: End is out of range
  expect_error(show_file(test_file, end = 30), "start and end must be within the valid range of rows.")
  
  # Test case 9: Print the last 3 lines of the file
  expect_equal(paste(capture.output(show_file(test_file, start = -3)), collapse = "\n"),
               paste(c(
                 "This is line 10.",
                 "",
                 "This is line 11 with no matching pattern."
               ), collapse = "\n"))
  
  # Test case 10: No rows matching the pattern
  expect_equal(paste(capture.output(show_file(test_file, pattern = "nomatch")), collapse = "\n"), "")
  
  # Test case 11: Print the last code chunk
  expect_equal(paste(capture.output(show_file(test_file, chunk = "Last")), collapse = "\n"),
               paste(c(
                 "# Another code chunk",
                 "y <- 20:30",
                 "mean(y)"
               ), collapse = "\n"))
})

