

test_that("First exercise in section", {
  expect_equal(tutorial.helpers::determine_exercise_number("fixtures/tutorial_examples/exercise-number-test-tutorial-1.Rmd"),
               1)
})


test_that("Next exercise in section (not first)", {
  expect_equal(tutorial.helpers::determine_exercise_number("fixtures/tutorial_examples/exercise-number-test-tutorial-2.Rmd"),
               4)
})


