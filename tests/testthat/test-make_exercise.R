# make_exercise.R is still rough because it behaves poorly if you execute it in
# a document which is not set up like a tutorial, especially one which lacks a
# Section header. 

library(testthat)

create_test_file <- function(path, add_headers = TRUE) {
  if (add_headers) {
    writeLines(
      c("## My section", "###", "", "### Exercise 1", "", "### Exercise 2", ""),
      con = path
    )
  } else {
    file.create(path)
  }
}

# ---- MAIN TEST (APPEND MODE) ----

test_that("make_exercise() generates correct output for all types", {
  # Create temp file and add section headers for proper numbering
  tmp <- tempfile(fileext = ".Rmd")
  create_test_file(tmp, add_headers = TRUE)
  
  tutorial.helpers::make_exercise(type = "no", file_path = tmp)
  tutorial.helpers::make_exercise(type = "yes", file_path = tmp)
  tutorial.helpers::make_exercise(type = "co", file_path = tmp)
  
  output <- paste(readLines(tmp), collapse = "\n")
  
  truth <- paste(
    readLines(testthat::test_path("fixtures", "tutorial_examples", "make_exercise_expected.Rmd")),
    collapse = "\n"
  )
  
  # Test: do they match?
  expect_equal(output, truth)
})

# ---- ERROR HANDLING TEST ----

test_that("make_exercise() errors with bad input", {
  tmp <- tempfile(fileext = ".Rmd")
  create_test_file(tmp)
  expect_error(tutorial.helpers::make_exercise(type = "bad-input", file_path = tmp))
})

# ---- INTERACTIVE CURSOR TEST (THE TRICK) ----

test_that("make_exercise() ignores exercises after the cursor", {
  
  # This test simulates the "Trick": We are in the middle of a document.
  # Ex 1 is above us. Ex 10 is below us.
  # The function should suggest "Exercise 2", NOT "Exercise 11".
  
  fake_contents <- c(
    "## Data Wrangling",
    "",
    "### Exercise 1",
    "",
    "", # <--- Cursor will be simulated here (Row 5)
    "### Exercise 10", 
    ""
  )
  
  # Mock the Context Object that rstudioapi normally returns
  fake_ctx <- list(
    contents = fake_contents,
    path = "dummy_path.Rmd",
    selection = list(list(range = list(start = c(row = 5))))
  )
  
  # Variable to capture the text that make_exercise tries to insert
  captured_insertion <- NULL
  
  # Mock rstudioapi functions
  local_mocked_bindings(
    getActiveDocumentContext = function() fake_ctx,
    insertText = function(location, text) { captured_insertion <<- text },
    .package = "rstudioapi"
  )
  
  # Run function in interactive mode (file_path = NULL)
  # We specify type = "code" so we can verify the copy button generation
  tutorial.helpers::make_exercise(type = "code", file_path = NULL)
  
  # 1. Check Numbering Logic (The "Trick")
  # It correctly identified that we are after Ex 1, ignoring Ex 10.
  expect_match(captured_insertion, "### Exercise 2")
  
  # 2. Check Section Logic
  # The pattern is {slug}-{number}, so "data-wrangling-2"
  expect_match(captured_insertion, "data-wrangling-2")
  
  # 3. Check Structure
  # Since we requested type="code", the transfer button should exist
  expect_match(captured_insertion, "transfer_code")
})
