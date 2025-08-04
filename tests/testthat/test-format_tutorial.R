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


