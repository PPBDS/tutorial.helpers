# tutorial.helpers 0.2.5

* Remove test case for write_answers() to meet 5 mb maximum package size.

# tutorial.helpers 0.2.4

* Add test case for write_answers().

* Fix (really!) error on CRAN Debian systems (caused by attempts to write to the user library) by setting the intermediates_dir argument to tempdir() in the call to render() within knit_tutorials().

# tutorial.helpers 0.2.3

* Fix error on Debian systems caused by attempts to write to the user library. Thanks to Kurt Hornik for pointing out the problem.

* Create "Rstudio Addins" vignette.

* Create "Testing Your Package of Tutorials" vignette.

* Create "Tutorials for Books" vignette.

* Fix error in downloading files by exporting write_answers(). Thanks to Xavier de Pedro Puente for the report.

# tutorial.helpers 0.2.2

* Replace /dontrun{} with if(interactive()){}.

* Fix return value in submission_server().

# tutorial.helpers 0.2.1

* Changes for CRAN submission.

# tutorial.helpers 0.2.0

* Add examples and return values for all exported functions.

# tutorial.helpers 0.1.2

* Move prep_rstudio_settings() to r4ds.tutorials.

* Publish Getting Started tutorial to Shiny Apps and adjust _pkgdown.yml to make use of it.

# tutorial.helpers 0.1.1

* Add prep_rstudio_settings().

* Add Getting Started tutorial.

* Change copy_button to only use base R.

# tutorial.helpers 0.1.0

* Basic working version. Big code clean up since spinning out of **all.primer.tutorials** package.

* Revise most test cases.

* Centralize answers creation with `write_answers()`.

* Added a `NEWS.md` file to track changes to the package.
