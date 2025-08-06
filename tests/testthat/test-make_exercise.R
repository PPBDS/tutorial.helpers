# make_exercise.R is still rough because it behaves poorly if you execute it in
# a document which is not set up like a tutorial, especially one which lacks a
# Section header.  of a tutorial file with a section header.

# Alas, when I try these now, I get an error about
#
# Error: RStudio not running
#
# must be a way around this . . .

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

# ---- MAIN TEST ----

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

# (Optional: test behavior if section header missing, etc.)

