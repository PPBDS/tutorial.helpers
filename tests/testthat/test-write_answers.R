# ------------------------------------------------------------------------
# Test for write_answers() HTML output using a learnr answers list fixture
# ------------------------------------------------------------------------
#
# == How to Update This Test ==
#
# 1. Run the getting-started tutorial and answer a few questions (include multi-line).
# 2. In your downloadHandler content function (temporarily), add:
#      answers <- tutorial.helpers:::get_submissions_from_learnr_session(session)
#      saveRDS(answers, file = "tests/testthat/fixtures/session_save.rds")
# 3. Download your answers; the fixture file will be created.
# 4. In a clean R session:
#      answers <- readRDS("tests/testthat/fixtures/session_save.rds")
#      write_answers("tests/testthat/fixtures/session_output.html", answers)
# 5. Check session_output.html. If correct, copy it to:
#      tests/testthat/fixtures/submission_test_outputs/submission_report_output.html
#
# == Test Details ==
#
# - Uses a minimal answers list fixture (not a Shiny session object).
# - Avoids "test mode" hacks or fragile session saves.
# - Compares normalized HTML output for cross-platform stability.
#
# ------------------------------------------------------------------------

library(testthat)
library(tutorial.helpers)
library(rvest)

test_that("write_answers() generates correct HTML output from answers fixture", {
  # Load answers list (from session_save.rds)
  answers <- readRDS("C:/Users/922485/tutorial.helpers/tests/testthat/fixtures/session_save.rds")
  
  # Generate HTML from the answers list
  test_html <- file.path(tempdir(), "submission_report_test.html")
  write_answers(test_html, answers)
  
  # Load generated and expected HTML
  actual_html   <- rvest::read_html(test_html)
  expected_html <- rvest::read_html("C:/Users/922485/tutorial.helpers/tests/testthat/fixtures/session_output.html")
  
  # Compare normalized HTML content
  expect_identical(
    rvest::html_text2(actual_html),
    rvest::html_text2(expected_html),
    info = "HTML output does not match the expected result."
  )
})

