library(testthat)

f_1_test <- tutorial.helpers::format_tutorial(
  test_path("fixtures", "addin_test_inputs", "format_input_1.Rmd")
)

# writeLines(
#   f_1_test,
#   test_path("fixtures", "addin_test_outputs", "format_output_1.Rmd")
# )

f_1_truth <- paste(
  readLines(test_path("fixtures", "addin_test_outputs", "format_output_1.Rmd")),
  collapse = "\n"
)

test_that("Format 1 works", {
  expect_equal(f_1_test, f_1_truth)
})


# Regression tests: section names with special characters used to produce
# labels with doubled hyphens in the rewritten chunk headers, and pre-labeled
# -test/-hint chunks before the first exercise used to be corrupted.

test_that("special characters in section names collapse to single hyphens", {
  lines <- c("## Data & plots",
             "### Exercise 1",
             "```{r, exercise = TRUE}",
             "```")
  f <- tempfile(fileext = ".Rmd")
  on.exit(unlink(f))
  writeLines(lines, f)

  out <- strsplit(format_tutorial(f), "\n")[[1]]
  expect_true(any(grepl("^```\\{r data-plots-1", out)))
  expect_false(any(grepl("--", out[grepl("^```\\{r", out)])))
})

test_that("pre-labeled -test/-hint chunks before the first exercise are untouched", {
  lines <- c("```{r my-test, include = FALSE}",
             "```",
             "```{r old-hint-1, eval = FALSE}",
             "```",
             "## Section",
             "### Exercise 1")
  f <- tempfile(fileext = ".Rmd")
  on.exit(unlink(f))
  writeLines(lines, f)

  out <- strsplit(format_tutorial(f), "\n")[[1]]
  expect_true("```{r my-test, include = FALSE}" %in% out)
  expect_true("```{r old-hint-1, eval = FALSE}" %in% out)
})
