# Key insight is that we can test tutorial files without installing them as
# tutorials. Ought to expand this to check the error messages, perhaps.

check_tutorial_defaults("test-data/tutorial_examples/good-tutorial.Rmd")

expect_error(
  check_tutorial_defaults("test-data/tutorial_examples/no-info-tutorial.Rmd")
  )

expect_error(
  check_tutorial_defaults("test-data/tutorial_examples/no-tutorialhelpers-tutorial.Rmd")
  )
