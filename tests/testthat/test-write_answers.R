# This test checks the output of write_answers() for a learnr tutorial.
#
# ==== Test Creation and Maintenance Notes ====
#
# - To create a new test case, insert browser() inside your downloadHandler content function
#   in the tutorial server code. Run your tutorial, answer some questions, click "Download".
#   At the prompt, run:
#      answers <- tutorial.helpers:::get_submissions_from_learnr_session(session)
#      readr::write_rds(answers, "tests/testthat/fixtures/submissions_list.rds")
#   This creates a minimal, reproducible test fixture.
#
# - Earlier versions used saveRDS(session, ...), but this is no longer recommended, as session
#   objects are large and difficult to serialize robustly across platforms.
#
# ==== CRAN and File Size ====
#
# - At one point, the session-based test fixture was too large for CRAN (<5 MB limit), so files
#   like session_save.rds must be .Rbuildignore’d.
# - Using a minimal answers list sidesteps this and is also more robust in CI and dev environments.
#
# ==== learnr Internal Details ====
#
# - get_submissions_from_learnr_session() relies on learnr:::get_all_state_objects(), which
#   calls get_objects() and read_request(). These work by extracting state from the Shiny session.
#   For details, see: https://github.com/rstudio/learnr/blob/master/R/identifiers.R
#
# ==== Test Details and Platform Quirks ====
#
# - This test avoids "test modes" or special session hacks, relying only on saved submission data.
# - In the past, differences in how html_table() or html_text2() worked on Windows, Mac, or
#   in Github Actions sometimes caused test flakiness. This test compares html_text2().
# - If you need to update the canonical output, copy the HTML file created by write_answers()
#   to fixtures/submission_test_outputs/submission_report_output.html.
#
# ==== Test Fixture Requirements ====
#
# - Try to include some multi-line and single-line answers to cover edge cases (e.g., answers with \n).
# - You may want to update the fixture if you add pagination or change output structure.
#

library(tutorial.helpers)
library(rvest)

answers_path <- "fixtures/submissions_list.rds"
answers <- readRDS(answers_path)

# Write answers to a temp HTML file for comparison
html_file <- file.path(tempdir(), "submission_report_test.html")
write_answers(html_file, answers)

# Compare output to the canonical result file
submission_report_test <- rvest::read_html(html_file)
submission_report_output <- rvest::read_html("fixtures/submission_test_outputs/submission_report_output.html")

if (! all.equal(
  rvest::html_text2(submission_report_test),
  rvest::html_text2(submission_report_output))) {
  stop("Test failed: HTML output does not match the expected result.")
}

