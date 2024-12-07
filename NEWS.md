# tutorial.helpers 0.3.1

* Clean up "Instructions for Writing R Tutorials" vignette.

* Revise "Getting Started with Tutorials" tutorial.

# tutorial.helpers 0.3.0

* Add show_file().

* Add process_submissions().

* Remove the ability to save answers as either RDS or PDF files.

# tutorial.helpers 0.2.7

* Get test cases for `format_tutorial()` working again.

* Fix `format_tutorial()` to deal with changes in parsermd 0.1.3.

* Setting rmd_viewer_type to "pane" within `set_rstudio_settings()`, per suggestion from Jade Cao. 

* Add "ID" field to default information page.

* Change tutorial title to "Getting Started with Tutorials."

* Give `set_rstudio_settings()` a set.binary argument which is set to TRUE by default, causing the function to run `set_binary_only_in_r_profile()` at the end. This is handy for the "Getting Started with Tutorials"" tutorial. 

* Remove "Getting Started with Tutorials" from shinyapps.io.

# tutorial.helpers 0.2.6

* Add `determine_code_chunk_name()` and `determine_exercise_number()` functions so that `make_exercise()` is more manageable. Update logic for `determine_code_chunk_name()` to handle forward slashes and ending dashes better.

* Add test case for `write_answers()`. Add associated files to .Rbuildignore so as not to violate the CRAN size restriction of 5 mb.

* Add vignette about downloading answers. Reorder all five vignettes in Articles menu.

* Add Spanish translation of Getting Started tutorial. Thanks to @xavidp!

* Add several more settings changes to `set_rstudio_settings()`. The set of changes is now quite extensive, but this seems the best approach to ensuring that new students have the best possible learning environment.

* Rewrite `set_rstudio_settings()` to report any changes made in settings.

# tutorial.helpers 0.2.5

* Remove test case for `write_answers()` to meet 5 mb maximum package size.

# tutorial.helpers 0.2.4

* Add test case for `write_answers()`.

* Fix (really!) error on CRAN Debian systems (caused by attempts to write to the user library) by setting the intermediates_dir argument to `tempdir()` in the call to `render()` within `knit_tutorials()`.

# tutorial.helpers 0.2.3

* Fix error on Debian systems caused by attempts to write to the user library. Thanks to Kurt Hornik for pointing out the problem.

* Create "Rstudio Addins" vignette.

* Create "Testing Your Package of Tutorials" vignette.

* Create "Tutorials for Books" vignette.

* Fix error in downloading files by exporting `write_answers()`. Thanks to Xavier de Pedro Puente for the report.

# tutorial.helpers 0.2.2

* Replace /dontrun{} with if(interactive()){}.

* Fix return value in `submission_server()`.

# tutorial.helpers 0.2.1

* Changes for CRAN submission.

# tutorial.helpers 0.2.0

* Add examples and return values for all exported functions.

# tutorial.helpers 0.1.2

* Move `prep_rstudio_settings()` to r4ds.tutorials.

* Publish Getting Started tutorial to Shiny Apps and adjust \_pkgdown.yml to make use of it.

# tutorial.helpers 0.1.1

* Add `prep_rstudio_settings()`.

* Add Getting Started tutorial.

* Change copy_button to only use base R.

# tutorial.helpers 0.1.0

* Basic working version. Big code clean up since spinning out of **all.primer.tutorials** package.

* Revise most test cases.

* Centralize answers creation with `write_answers()`.

* Added a `NEWS.md` file to track changes to the package.
