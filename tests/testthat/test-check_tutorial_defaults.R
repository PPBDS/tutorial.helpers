# Key insight is that we can test tutorial files without installing them as
# tutorials. But maybe we should also have an installed tutorial . . .

test_that("check_tutorial() works on legal tutorials", {
  expect_null(
    check_tutorial_defaults(test_path("fixtures", "tutorial_examples", "good-tutorial.Rmd"))
  )
  expect_null(
    check_tutorial_defaults(
      c(test_path("fixtures", "tutorial_examples", "good-tutorial.Rmd"),
        test_path("fixtures", "tutorial_examples", "good-tutorial-2.Rmd"))
    )
  )
})


test_that("check_tutorial() fails on illegal tutorials", {
  expect_error(
    check_tutorial_defaults(test_path("fixtures", "tutorial_examples", "no-exist-tutorial.Rmd"))
  )
  expect_error(
    check_tutorial_defaults(test_path("fixtures", "tutorial_examples", "no-info-tutorial.Rmd"))
    )
  expect_error(
    check_tutorial_defaults(test_path("fixtures", "tutorial_examples", "no-tutorialhelpers-tutorial.Rmd"))
    )
})
