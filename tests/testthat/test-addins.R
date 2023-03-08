library(learnr)
library(all.primer.tutorials)
library(tidyverse)

# This test is created to test the formatting addin.
#
# It cycles through all the test cases added in www/addin_test_inputs
# and checks if the formatted output matches with the outputs in
# www/addin_test_outputs

format_tutorial_paths <- Sys.glob(file.path("test-data/addin_test_inputs", "format*"))

for (i in seq_along(format_tutorial_paths)){

  test_doc <- all.primer.tutorials::format_tutorial(paste0(
    file.path("test-data/addin_test_inputs", "format_input_"), i, ".Rmd"))

  output_doc <- readr::read_file(paste0(
    file.path("test-data/addin_test_outputs", "format_output_"), i, ".Rmd"))

  if (stringr::str_trim(test_doc) != stringr::str_trim(output_doc)){

    stop("From test-addins.R. Format Chunk Label addin failed on test ", i, "\n")

  }
}



