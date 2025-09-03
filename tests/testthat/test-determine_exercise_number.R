test_file_1 <- test_path("fixtures", "tutorial_examples", "exercise-number-test-tutorial-1.Rmd")

test_file_2 <- test_path("fixtures", "tutorial_examples", "exercise-number-test-tutorial-2.Rmd")

test_that("determine exercise numbers", {
  expect_equal(tutorial.helpers::determine_exercise_number(test_file_1),
               1)
  
  expect_equal(tutorial.helpers::determine_exercise_number(test_file_2),
               4)
})



