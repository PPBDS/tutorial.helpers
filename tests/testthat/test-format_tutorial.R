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

f_2_test <- tutorial.helpers::format_tutorial("fixtures/addin_test_inputs/format_input_2.Rmd")

# writeLines(f_2_test, "fixtures/addin_test_outputs/format_output_2.Rmd")

f_2_truth <- paste(readLines("fixtures/addin_test_outputs/format_output_2.Rmd"),
                   collapse = "\n")

test_that("Format 2 works", {
  expect_equal(f_2_test,
               f_2_truth)
})
