# ------------------------------------------------------------------------
# Test for write_answers() HTML output using a learnr submissions fixture
# ------------------------------------------------------------------------
#
# == How to Update or Create This Test Case ==
#
# 1. Run the getting-started tutorial interactively.
# 2. Answer a few questions, including at least one multi-line answer.
# 3. In your downloadHandler content function (temporarily), add:
#      answers <- tutorial.helpers:::get_submissions_from_learnr_session(session)
#      saveRDS(answers, file = "tests/testthat/fixtures/submissions_list.rds")
# 4. Download your answers as usual. The fixture file will be created.
# 5. In a clean R session, run:
#      answers <- readRDS("tests/testthat/fixtures/submissions_list.rds")
#      write_answers("tests/testthat/fixtures/session_output.html", answers)
# 6. Check session_output.html for correctness.
# 7. When satisfied, copy it to fixtures/submission_test_outputs/submission_report_output.html.
#
# == Test Details ==
#
# - This test uses only minimal submission data (not full Shiny sessions).
# - Avoids "test modes" or special hacks.
# - Compares HTML output by normalized text to avoid platform flakiness.
#
# == CRAN/File Size Note ==
# - Using answer lists (not sessions) avoids large files and CRAN issues.
#
# ------------------------------------------------------------------------

library(tutorial.helpers)
library(rvest)

# Load test fixture (answers list)
answers <- readRDS("test/testthat/fixtures/session_save.rds")

# Generate HTML output to a temp file
test_html <- file.path(tempdir(), "submission_report_test.html")
write_answers(test_html, answers)

# Load the generated and canonical (expected) output
actual_html   <- rvest::read_html(test_html)
expected_html <- rvest::read_html("test/testthat/fixtures/submission_test_outputs/submission_report_output.html")

# Compare normalized text output for stability across OS/CI
if (!identical(rvest::html_text2(actual_html), rvest::html_text2(expected_html))) {
  stop("Test failed: HTML output does not match the expected result.")
}

