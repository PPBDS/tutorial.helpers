library(tutorial.helpers)
library(rvest)

# This script tests the components of the downloading functions for
# submission_server()

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


# Change the functions so that they no longer return a path, which is an absurd
# hack.

# Test build_html()

html_file <- file.path(tempdir(), "submission_report_test.html")

build_html(html_file, saved_session, is_test = TRUE)

submission_report_test <- rvest::read_html(html_file)

submission_report_output <- rvest::read_html("test-data/submission_test_outputs/submission_report_output.html")

if (!identical(rvest::html_table(submission_report_test), rvest::html_table(submission_report_output))){
  stop("From test-submission.R. function build_html() did not return the desired output")
}




# Test build_rds()

rds_file <- file.path(tempdir(), "submission_test_output.rds")

build_rds(rds_file, saved_session, is_test = TRUE)

submission_rds_test <- readRDS(rds_file)

submission_rds_output <- readRDS("test-data/submission_test_outputs/submission_desired_output.rds")

if (!identical(submission_rds_test, submission_rds_output)){
  stop("From test-submission.R. function build_rds() did not return the desired output")
}



