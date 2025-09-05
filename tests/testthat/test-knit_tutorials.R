# Test suite for knit_tutorials function

test_that("knit_tutorials exists and has correct signature", {
  expect_true(exists("knit_tutorials"))
  expect_true(is.function(knit_tutorials))
  
  # Check function arguments
  args <- formals(knit_tutorials)
  expect_true("tutorial_paths" %in% names(args))
  expect_equal(length(args), 1)
})

test_that("knit_tutorials validates file existence", {
  # Test with non-existent file
  expect_error(
    knit_tutorials("definitely_does_not_exist.Rmd"),
    "all\\(file\\.exists\\(tutorial_paths\\)\\) is not TRUE"
  )
  
  # Test with mix of existing and non-existing files
  temp_file <- tempfile(fileext = ".Rmd")
  writeLines("# Test", temp_file)
  on.exit(unlink(temp_file))
  
  expect_error(
    knit_tutorials(c(temp_file, "nonexistent.Rmd")),
    "all\\(file\\.exists\\(tutorial_paths\\)\\) is not TRUE"
  )
})

test_that("knit_tutorials handles empty input correctly", {
  # Empty character vector should work
  expect_message(
    result <- knit_tutorials(character(0)),
    "Successfully rendered 0 tutorial\\(s\\)"
  )
  expect_null(result)
})

test_that("knit_tutorials renders simple R Markdown file", {
  # Create a minimal but valid R Markdown file
  temp_tutorial <- tempfile(fileext = ".Rmd")
  on.exit(unlink(temp_tutorial))
  
  simple_content <- c(
    "---",
    "title: 'Test Tutorial'",
    "output: html_document",
    "---",
    "",
    "# Simple Test",
    "",
    "This is a basic test document.",
    "",
    "```{r}",
    "2 + 2",
    "```"
  )
  
  writeLines(simple_content, temp_tutorial)
  
  # Should render successfully
  expect_message(
    expect_message(
      result <- knit_tutorials(temp_tutorial),
      "Rendering:"
    ),
    "Successfully rendered:"
  )
  
  expect_null(result)
})

test_that("knit_tutorials renders multiple files", {
  # Create two simple R Markdown files
  temp_tutorial1 <- tempfile(fileext = ".Rmd")
  temp_tutorial2 <- tempfile(fileext = ".Rmd")
  on.exit(unlink(c(temp_tutorial1, temp_tutorial2)))
  
  content1 <- c(
    "---",
    "title: 'Tutorial 1'",
    "output: html_document",
    "---",
    "",
    "# Tutorial One",
    "First tutorial content."
  )
  
  content2 <- c(
    "---",
    "title: 'Tutorial 2'",
    "output: html_document",
    "---",
    "",
    "# Tutorial Two",
    "Second tutorial content."
  )
  
  writeLines(content1, temp_tutorial1)
  writeLines(content2, temp_tutorial2)
  
  # Should render both successfully
  expect_message(
    result <- knit_tutorials(c(temp_tutorial1, temp_tutorial2)),
    "Successfully rendered 2 tutorial\\(s\\)"
  )
  
  expect_null(result)
})

test_that("knit_tutorials fails gracefully on invalid R Markdown", {
  # Create an R Markdown file with invalid R code
  temp_tutorial <- tempfile(fileext = ".Rmd")
  on.exit(unlink(temp_tutorial))
  
  invalid_content <- c(
    "---",
    "title: 'Invalid Tutorial'",
    "output: html_document",
    "---",
    "",
    "# Invalid Code Test",
    "",
    "```{r}",
    "this_function_does_not_exist()",
    "```"
  )
  
  writeLines(invalid_content, temp_tutorial)
  
  # Should fail with clear error message
  expect_error(
    knit_tutorials(temp_tutorial),
    "Failed to render.*could not find function"
  )
})

test_that("knit_tutorials works with learnr tutorial format", {
  skip_if_not_installed("learnr")
  
  # Create a basic learnr tutorial
  temp_tutorial <- tempfile(fileext = ".Rmd")
  on.exit(unlink(temp_tutorial))
  
  learnr_content <- c(
    "---",
    "title: 'Test Tutorial'",
    "output: learnr::tutorial",
    "runtime: shiny_prerendered",
    "---",
    "",
    "```{r setup, include=FALSE}",
    "library(learnr)",
    "```",
    "",
    "## Introduction",
    "",
    "This is a test tutorial.",
    "",
    "```{r exercise-1, exercise=TRUE}",
    "1 + 1",
    "```"
  )
  
  writeLines(learnr_content, temp_tutorial)
  
  # Should render successfully
  expect_message(
    result <- knit_tutorials(temp_tutorial),
    "Successfully rendered"
  )
  
  expect_null(result)
})

test_that("knit_tutorials respects output directory", {
  # Create a simple tutorial
  temp_tutorial <- tempfile(fileext = ".Rmd")
  on.exit(unlink(temp_tutorial))
  
  simple_content <- c(
    "---",
    "title: 'Directory Test'",
    "output: html_document",
    "---",
    "",
    "# Test",
    "Testing output directory."
  )
  
  writeLines(simple_content, temp_tutorial)
  
  # Render and check that output goes to tempdir
  initial_temp_files <- list.files(tempdir(), pattern = "\\.html$")
  
  knit_tutorials(temp_tutorial)
  
  final_temp_files <- list.files(tempdir(), pattern = "\\.html$")
  
  # Should have created a new HTML file in tempdir
  expect_true(length(final_temp_files) > length(initial_temp_files))
})

test_that("knit_tutorials input validation", {
  # Test with NULL input
  expect_error(knit_tutorials(NULL))
  
  # Test with non-character input
  expect_error(knit_tutorials(123))
  expect_error(knit_tutorials(list("file.Rmd")))
  
  # Test with NA values
  expect_error(knit_tutorials(c("valid.Rmd", NA)))
})