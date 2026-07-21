# For now, we will do all our tutorial testing in this one script. Skipped on
# CRAN because rendering the full learnr tutorial is slow; test-knit_tutorials.R
# covers the same code path.

test_that("all installed tutorials knit and have the default components", {
  skip_on_cran()

  tutorial_paths <- tutorial.helpers::return_tutorial_paths(package = "tutorial.helpers")

  # First, we make sure that all the tutorials can be knitted.

  expect_no_error(tutorial.helpers::knit_tutorials(tutorial_paths))

  # Second, ensure that all the tutorials have the default components.

  expect_no_error(tutorial.helpers::check_tutorial_defaults(tutorial_paths))
})
