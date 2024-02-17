# There used to be some code which did this. See the test cases in the
# addin_test_inputs directory and its associated outputs in addin_test_outputs.
# Not sure what happened to that code. Here is a new version. The commented out
# lines show how we created the test cases.

# You need to adjust your working directory to run this code interactively.
# Isn't there a better way to do that?

f_1_test <- tutorial.helpers::format_tutorial("fixtures/addin_test_inputs/format_input_1.Rmd")

# writeLines(f_1_test, "fixtures/addin_test_outputs/format_output_1.Rmd")

f_1_truth <- paste(readLines("fixtures/addin_test_outputs/format_output_1.Rmd"),
                 collapse = "\n")

test_that("Format 1 works", {
  expect_equal(f_1_test,
               f_1_truth)
})

## Second test cases, dealing with a simple non-Code exercises. among other things.

f_2_test <- tutorial.helpers::format_tutorial("fixtures/addin_test_inputs/format_input_2.Rmd")

# writeLines(f_2_test, "fixtures/addin_test_outputs/format_output_2.Rmd")

f_2_truth <- paste(readLines("fixtures/addin_test_outputs/format_output_2.Rmd"),
                   collapse = "\n")

test_that("Format 2 works", {
  expect_equal(f_2_test,
               f_2_truth)
})

# The RStudio and Code tutorial from r4ds.tutorials was giving me a bunch of
# trouble, so I added it as a test case.

f_3_test <- tutorial.helpers::format_tutorial("fixtures/addin_test_inputs/format_input_3.Rmd")

# writeLines(f_3_test, "fixtures/addin_test_outputs/format_output_3.Rmd")

f_3_truth <- paste(readLines("fixtures/addin_test_outputs/format_output_3.Rmd"),
                   collapse = "\n")

test_that("Format 3 works", {
  expect_equal(f_3_test,
               f_3_truth)
})

# Isolated test of image load proceeding a non-code exercise.

f_4_test <- tutorial.helpers::format_tutorial("fixtures/addin_test_inputs/format_input_4.Rmd")

# writeLines(f_4_test, "fixtures/addin_test_outputs/format_output_4.Rmd")

f_4_truth <- paste(readLines("fixtures/addin_test_outputs/format_output_4.Rmd"),
                   collapse = "\n")

test_that("Format 4 works", {
  expect_equal(f_4_test,
               f_4_truth)
})

# Deal better with hints

f_5_test <- tutorial.helpers::format_tutorial("fixtures/addin_test_inputs/format_input_5.Rmd")

# writeLines(f_5_test, "fixtures/addin_test_outputs/format_output_5.Rmd")

f_5_truth <- paste(readLines("fixtures/addin_test_outputs/format_output_5.Rmd"),
                   collapse = "\n")

test_that("Format 5 works", {
  expect_equal(f_5_test,
               f_5_truth)
})

