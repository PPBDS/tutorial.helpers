test_that("Reading/Writing Excel section", {
  expect_equal(tutorial.helpers::determine_code_chunk_name("fixtures/tutorial_examples/code-chunk-name-test-tutorial-1.Rmd"),
               "reading-writing-excel")
})


test_that("Testing name cut off", {
  expect_equal(tutorial.helpers::determine_code_chunk_name("fixtures/tutorial_examples/code-chunk-name-test-tutorial-2.Rmd"),
               "really-long-name-to-cut-off-an")
})
