test_that("Reading/Writing Excel section", {
  rmd_path <- testthat::test_path(
    "fixtures", "tutorial_examples", "code-chunk-name-test-tutorial-1.Rmd"
  )
  expect_equal(
    tutorial.helpers::determine_code_chunk_name(rmd_path),
    "reading-writing-excel"
  )
})

test_that("Testing name cut off", {
  rmd_path <- testthat::test_path(
    "fixtures", "tutorial_examples", "code-chunk-name-test-tutorial-2.Rmd"
  )
  expect_equal(
    tutorial.helpers::determine_code_chunk_name(rmd_path),
    "really-long-name-to-cut-off-an"
  )
})

# Regression test: a file with no section headers used to return NULL.

test_that("a file with no sections returns the default", {
  f <- tempfile(fileext = ".Rmd")
  on.exit(unlink(f))
  writeLines("No sections here.", f)
  expect_equal(determine_code_chunk_name(f), "NONE_SET")
})
