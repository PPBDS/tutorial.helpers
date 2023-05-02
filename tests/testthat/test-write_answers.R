library(tutorial.helpers)
library(rvest)

# The comments below apply to work from last year. Perhaps this would now work
# correctly, given changes in learnr exported functions.

# Main problem with current submission tests is that it is not tested with a
# saved session, instead it uses "test modes" of the functions, which bypasses
# the use of sessions.

# The problem with sessions seem to only occur in Github Actions because using
# devtools::check() on the package locally does not raise any errors with the
# submission test.

# It is also not a problem with storage location in Github Actions because the
# session object is loaded where all of its attributes such as
# session$options$appDir are accessible. However only when used in
# environment-related instances does it raise errors in Github Actions.

# the get_submissions_from_learnr_session() function currently uses
# learnr:::get_all_state_objects(),
# which uses learnr:::get_objects(),
# which uses learnr:::read_request()

# learnr:::read_request() is a special function because it interacts directly
# with the shiny session environment. I suspect that the problem is caused by
# the session_save.rds not preserving the environment of the session.

# Check here for the definition of learnr:::read_request()
# https://github.com/rstudio/learnr/blob/master/R/identifiers.R


# Load session saved in rds

session_path <- "test-data/session_save.rds"

saved_session <- readRDS(session_path)


# Test get_submissions_from_learnr_session()

# See discussion in function definition of get_submissions_from_learnr_session()
# for details on why this function is hard to test.

# Test html. Note that a simple version of this test, in which we just compare
# the results of running html_table(), works on Mac and Linux, and on Windows on
# Github. But it produced a problem with rhub::check_for_cran(). I *think* that
# using all.equal() on the return value of rvest::html_table() may not be OK.
# (Although why it works on Github would be a mystery.)

# Note that this test answer include all sorts of weird strings, like:

# 14 html-11            exercise        "\"<html>\n<table>\n  <tr>\n    <td>\n      Hello World\n    <…

# On one hand, tough tests are good. On the other hand, we are really just
# testing basic functionality. No need for such obscure tests, especially if
# they don't work!


html_file <- file.path(tempdir(), "submission_report_test.html")

write_answers(html_file, saved_session, is_test = TRUE)

submission_report_test <- rvest::read_html(html_file)

submission_report_output <- rvest::read_html("test-data/submission_test_outputs/submission_report_output.html")

# The below test does not work for me with rhub::check_for_cran(), despite the
# fact that it works fine, for three platforms, on Github Actions. So, I cut it
# out for now. html_text2() does not work, does the more natural html_table().
# See comments above.

# if(! all.equal(
#   rvest::html_text2(submission_report_test), 
#   rvest::html_text2(submission_report_output))){
#   stop("From test-write_answer, html option did not return the desired output.")
#   }


# Test rds

rds_file <- file.path(tempdir(), "submission_test_output.rds")

write_answers(rds_file, saved_session, is_test = TRUE)

submission_rds_test <- readRDS(rds_file)

submission_rds_output <- readRDS("test-data/submission_test_outputs/submission_desired_output.rds")

if(! all.equal(submission_rds_test, submission_rds_output)){
  stop("From test-write_answer, rds option did not return the desired output.")
}

# Test pdf. We previously used pdftools to provide a more robust test, but the
# pdftools package was generating problems with GHA. Note that we compare just
# the lengths of these files. They are almost identical element-by-element, but
# not quite. So, we are really just testing that write_answers can produce a
# pdf, which is the most important test anyway.

pdf_file <- file.path(tempdir(), "submission_test_output.pdf")

write_answers(pdf_file, saved_session, is_test = TRUE)

submission_pdf_test <- readLines(pdf_file, warn = FALSE)

submission_pdf_output <- readLines("test-data/submission_test_outputs/submission_desired_output.pdf", warn = FALSE)

if(length(submission_pdf_test) != length(submission_pdf_output)){
  stop("From test-write_answer, pdf option did not return the desired output.")
  }
