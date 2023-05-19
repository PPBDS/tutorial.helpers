## R CMD check results

0 errors | 0 warnings | 0 notes

* This release (really!) fixes errors on Debian by setting the intermediates_dir argument to tempdir() in the call to render().

* Please note the size of the package, which is 7 mb. The reason for the large size is my desire to have a test case for the function, write_answers(), which interacts with the Shiny tutorial session to write out the student's answers. I can not figure out how to save a Shiny session which is any smaller than almost 7 mb. It seemed better to keep this test case than to meet the 5 mb guidance for CRAN packages. If you disagree, I can remove the test case.
