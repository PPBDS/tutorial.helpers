# ------------------------------------------------------------------------
# Test for write_answers() HTML output using a learnr answers list fixture
# ------------------------------------------------------------------------
#
# How to update or recreate this test
#
# Prep
# 1) Restart R to clear any lingering Shiny or learnr state.
# 2) Open the tutorial.helpers project. Your working directory should be the
#    package root. Confirm with:
#       getwd()
#    It should end with ".../tutorial.helpers".
#
# Make your code changes
# 3) Edit submission_functions.R or write_answers.R as needed.
# 4) You must reinstall the package so the tutorial runs the new code:
#       devtools::install()
#
# Save a fresh fixture from the live tutorial
# 5) Launch the getting-started tutorial and answer a few questions
#    including at least one multi-line answer.
# 6) Temporarily add these two lines inside the downloadHandler content
#    function in submission_server(), just before write_answers(file, session):
#       subs <- tutorial.helpers:::get_submissions_from_learnr_session(session)
#       saveRDS(subs, file = "tests/testthat/fixtures/session_save.rds")
#    Then click the Download button in the tutorial. This overwrites
#    tests/testthat/fixtures/session_save.rds with your latest answers.
#    Remove or comment those two lines immediately after creating the fixture.
#
# Create the canonical HTML from the fixture
# 7) In a clean R session at the package root:
#       a <- readRDS("tests/testthat/fixtures/session_save.rds")
#       tutorial.helpers::write_answers("tests/testthat/fixtures/session_output.html", a)
#    Open tests/testthat/fixtures/session_output.html in a browser and verify it.
#
# Run this test
# 8) Run either:
#       devtools::test()
#    or just this file:
#       testthat::test_file("tests/testthat/test-write_answers.R")
#
# Notes
# - We store a minimal answers list fixture, not a live Shiny session.
# - This test compares visible HTML text to avoid minor tag diff noise.
# - If output legitimately changes, regenerate session_output.html from the
#   updated fixture, verify by eye, then commit both files.
#
# ------------------------------------------------------------------------

testthat::test_that("write_answers() generates correct HTML output from answers fixture", {
  # Resolve fixture paths from the package root
  rds_path    <- testthat::test_path("fixtures", "session_input.rds")
  expect_true(file.exists(rds_path), info = paste("Missing fixture:", rds_path))

  expected_ht <- testthat::test_path("fixtures", "session_output.html")
  expect_true(file.exists(expected_ht), info = paste("Missing expected HTML:", expected_ht))

  # Load the saved answers list fixture
  answers <- base::readRDS(rds_path)

  # Generate HTML from the answers list to a temp location
  test_html <- file.path(tempdir(), "submission_report_test.html")
  write_answers(test_html, answers)  # function under test from this package

  # Load generated and expected HTML using namespaced rvest
  actual_html   <- rvest::read_html(test_html)
  expected_html <- rvest::read_html(expected_ht)

  # Compare normalized visible HTML content
  testthat::expect_identical(
    rvest::html_text2(actual_html),
    rvest::html_text2(expected_html),
    info = "HTML output does not match the expected result."
  )
})



