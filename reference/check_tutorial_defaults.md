# Confirm that a tutorial has the recommended components

Checks that tutorials contain required libraries and child documents.
The function looks for library() calls and child document inclusions in
the tutorial files.

## Usage

``` r
check_tutorial_defaults(
  tutorial_paths,
  libraries = c("learnr", "tutorial.helpers"),
  children = c("info_section", "download_answers")
)
```

## Arguments

- tutorial_paths:

  Character vector of the paths to the tutorials to be examined.

- libraries:

  Character vector of library names that should be loaded in the
  tutorial. The function looks for
  [`library(name)`](https://github.com/christopherkenny/name) calls.
  Default is `c("learnr", "tutorial.helpers")`.

- children:

  Character vector of child document names (without the .Rmd extension)
  that should be included in the tutorial. The function looks for these
  in child document inclusion chunks. Default is
  `c("info_section", "download_answers")`.

## Value

No return value, called for side effects.

## Examples

``` r
  # Check with default requirements
  check_tutorial_defaults(
    tutorial_paths = return_tutorial_paths("tutorial.helpers")
  )
  
  # Check for specific libraries only
  check_tutorial_defaults(
    tutorial_paths = return_tutorial_paths("tutorial.helpers"),
    libraries = c("learnr", "knitr"),
    children = c("copy_button")
  )
```
