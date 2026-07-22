test_file_1 <- test_path("fixtures", "tutorial_examples", "exercise-number-test-tutorial-1.Rmd")

test_file_2 <- test_path("fixtures", "tutorial_examples", "exercise-number-test-tutorial-2.Rmd")

test_that("determine exercise numbers", {
  expect_equal(tutorial.helpers::determine_exercise_number(test_file_1),
               1)
  
  expect_equal(tutorial.helpers::determine_exercise_number(test_file_2),
               4)
})




# Regression tests: the number extraction used to concatenate every digit in
# the heading ("### Exercise 2 (part 3)" gave 24), unanchored matching let
# prose alter the numbering, and a file with no headers returned NULL.

test_that("only the number directly after 'Exercise' is used", {
  f <- tempfile(fileext = ".Rmd")
  on.exit(unlink(f))

  writeLines(c("## Section", "### Exercise 2 (part 3)"), f)
  expect_equal(determine_exercise_number(f), 3L)

  writeLines(c("## Section", "### Exercise"), f)
  expect_equal(determine_exercise_number(f), 1L)

  writeLines(c("## Section", 'str_detect(x, "### Exercise 5")'), f)
  expect_equal(determine_exercise_number(f), 1L)

  writeLines("Just some prose.", f)
  expect_equal(determine_exercise_number(f), 1L)
})
