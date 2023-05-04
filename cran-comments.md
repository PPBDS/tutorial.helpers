## Resubmission

This is a resubmission. In this version I have:

* Removed unnecessary spaces in Description.

* Added \value to .Rd files for check_tutorial_defaults.Rd and knit_tutorials.Rd.

* I could not replace \dontrun with \donttest because these functions can not 
  be executed directly by the user. They only work from within a live runtime 
  shiny_prerendered tutorial session.

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.

* There are no references for the package.

