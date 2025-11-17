# Changelog

## tutorial.helpers (development version)

- Add “Generative AI” section to “Introduction to R” tutorial.

- Add “Introduction to Python” tutorial.

- Change make_exercise() default to “no-answer”.

## tutorial.helpers 0.6.0

CRAN release: 2025-09-11

- Replace process_submissions() with submissions_summary().

- Remove RStudio material, including addins.

- Rename tutorial to “Getting Started.”

- Change check_tutorial_defaults() to make it more flexible.

- Add “Introduction to R” tutorial.

- Change set_binary_only_r() to set_rprofile_settings().

## tutorial.helpers 0.5.0

CRAN release: 2025-05-11

- make_exercise() no longer includes ‘-ex’ in code chunk labels for
  exercises.

- Fix format_tutorial() bugs.

## tutorial.helpers 0.4.2

CRAN release: 2025-03-05

- Change original tutorial title to “Tutorials in RStudio.”

- Add new tutorial: “Tutorials in Positron.”

- Add set_positron_settings() function.

- Rewrite format_tutorial() to not use **parsermd** package.

## tutorial.helpers 0.3.1

CRAN release: 2024-12-07

- Clean up “Instructions for Writing R Tutorials” vignette.

- Revise “Getting Started with Tutorials” tutorial.

## tutorial.helpers 0.3.0

CRAN release: 2024-06-26

- Add show_file().

- Add process_submissions().

- Remove the ability to save answers as either RDS or PDF files.

## tutorial.helpers 0.2.7

CRAN release: 2024-05-06

- Get test cases for
  [`format_tutorial()`](https://ppbds.github.io/tutorial.helpers/reference/format_tutorial.md)
  working again.

- Fix
  [`format_tutorial()`](https://ppbds.github.io/tutorial.helpers/reference/format_tutorial.md)
  to deal with changes in parsermd 0.1.3.

- Setting rmd_viewer_type to “pane” within `set_rstudio_settings()`, per
  suggestion from Jade Cao.

- Add “ID” field to default information page.

- Change tutorial title to “Getting Started with Tutorials.”

- Give `set_rstudio_settings()` a set.binary argument which is set to
  TRUE by default, causing the function to run
  `set_binary_only_in_r_profile()` at the end. This is handy for the
  “Getting Started with Tutorials”” tutorial.

- Remove “Getting Started with Tutorials” from shinyapps.io.

## tutorial.helpers 0.2.6

CRAN release: 2024-01-16

- Add
  [`determine_code_chunk_name()`](https://ppbds.github.io/tutorial.helpers/reference/determine_code_chunk_name.md)
  and
  [`determine_exercise_number()`](https://ppbds.github.io/tutorial.helpers/reference/determine_exercise_number.md)
  functions so that
  [`make_exercise()`](https://ppbds.github.io/tutorial.helpers/reference/exercise_creation.md)
  is more manageable. Update logic for
  [`determine_code_chunk_name()`](https://ppbds.github.io/tutorial.helpers/reference/determine_code_chunk_name.md)
  to handle forward slashes and ending dashes better.

- Add test case for
  [`write_answers()`](https://ppbds.github.io/tutorial.helpers/reference/write_answers.md).
  Add associated files to .Rbuildignore so as not to violate the CRAN
  size restriction of 5 mb.

- Add vignette about downloading answers. Reorder all five vignettes in
  Articles menu.

- Add Spanish translation of Getting Started tutorial. Thanks to
  [@xavidp](https://github.com/xavidp)!

- Add several more settings changes to `set_rstudio_settings()`. The set
  of changes is now quite extensive, but this seems the best approach to
  ensuring that new students have the best possible learning
  environment.

- Rewrite `set_rstudio_settings()` to report any changes made in
  settings.

## tutorial.helpers 0.2.5

CRAN release: 2023-05-21

- Remove test case for
  [`write_answers()`](https://ppbds.github.io/tutorial.helpers/reference/write_answers.md)
  to meet 5 mb maximum package size.

## tutorial.helpers 0.2.4

- Add test case for
  [`write_answers()`](https://ppbds.github.io/tutorial.helpers/reference/write_answers.md).

- Fix (really!) error on CRAN Debian systems (caused by attempts to
  write to the user library) by setting the intermediates_dir argument
  to [`tempdir()`](https://rdrr.io/r/base/tempfile.html) in the call to
  `render()` within
  [`knit_tutorials()`](https://ppbds.github.io/tutorial.helpers/reference/knit_tutorials.md).

## tutorial.helpers 0.2.3

CRAN release: 2023-05-12

- Fix error on Debian systems caused by attempts to write to the user
  library. Thanks to Kurt Hornik for pointing out the problem.

- Create “Rstudio Addins” vignette.

- Create “Testing Your Package of Tutorials” vignette.

- Create “Tutorials for Books” vignette.

- Fix error in downloading files by exporting
  [`write_answers()`](https://ppbds.github.io/tutorial.helpers/reference/write_answers.md).
  Thanks to Xavier de Pedro Puente for the report.

## tutorial.helpers 0.2.2

CRAN release: 2023-05-08

- Replace /dontrun{} with if(interactive()){}.

- Fix return value in
  [`submission_server()`](https://ppbds.github.io/tutorial.helpers/reference/submission_functions.md).

## tutorial.helpers 0.2.1

- Changes for CRAN submission.

## tutorial.helpers 0.2.0

- Add examples and return values for all exported functions.

## tutorial.helpers 0.1.2

- Move `prep_rstudio_settings()` to r4ds.tutorials.

- Publish Getting Started tutorial to Shiny Apps and adjust
  \_pkgdown.yml to make use of it.

## tutorial.helpers 0.1.1

- Add `prep_rstudio_settings()`.

- Add Getting Started tutorial.

- Change copy_button to only use base R.

## tutorial.helpers 0.1.0

- Basic working version. Big code clean up since spinning out of
  **all.primer.tutorials** package.

- Revise most test cases.

- Centralize answers creation with
  [`write_answers()`](https://ppbds.github.io/tutorial.helpers/reference/write_answers.md).

- Added a `NEWS.md` file to track changes to the package.
