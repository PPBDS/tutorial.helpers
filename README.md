
<!-- README.md is generated from README.Rmd. Edit ONLY this file if needed. But, after you edit it, you NEED TO KNIT IT BY HAND in order to create the new README.md, which is the thing which is actually used. -->

# Tutorial Helper Functions

<!-- badges: start -->

[![R build
status](https://github.com/PPBDS/tutorial.helpers/workflows/R-CMD-check/badge.svg)](https://github.com/PPBDS/tutorial.helpers/actions)
<!-- badges: end -->

## About this package

**tutorial.helpers** provides functions and RStudio Addins to help you
write R tutorials, especially if you follow [my
advice](https://ppbds.github.io/tutorial.helpers/articles/instructions.html)
about the best way to do so. This approach is currently used in two
packages:
[**all.primer.tutorials**](https://ppbds.github.io/all.primer.tutorials/)
and [**r4ds.tutorials**](https://ppbds.github.io/r4ds.tutorials/).

## Installation

To install the package from CRAN:

``` r
install.packages("tutorial.helpers")
```

You can install the development version from
[GitHub](https://github.com/) with:

``` r
remotes::install_github("PPBDS/tutorial.helpers")
```

## Useful tools

- The most useful tool is the download answers trick. Simply insert this
  empty code chunk at the end of your tutorial.

```` default
```{r download-answers, child = system.file("child_documents/download_answers.Rmd", package = "tutorial.helpers")}
```
````

This will ask the student to provide an estimate of how long the
tutorial took to complete. It will then provide the ability to download
the student’s answers in three different formats: html, pdf and rds.
Students submit these files to their instructors, who can then confirm
that the work was completed and look for any patterns in student
(mis)understandings.

- There are three exported functions for checking the tutorials in your
  package.
  - `return_tutorial_paths("your.package.name")` will return a vector of
    paths to all the tutorials in **your.package.name**. This vector is
    used as an input to the next two functions.
  - `knit_tutorials()` takes a vector of tutorial paths and then knits
    all the tutorials. This is the most useful function in
    **tutorial.helpers** because it ensures that all your tutorials are
    still working.
  - `check_tutorial_defaults()` takes a vector of tutorial paths and
    then ensures that all the tutorials include the default child code
    chunks which we recommend. This is only useful if you want to
    include the options which we recommend.
- We recommend this child document at the start of each tutorial:

```` default
```{r info-section, child = system.file("child_documents/info_section.Rmd", package = "tutorial.helpers")}
```
````

This will insert questions asking for the student’s name and email
address.

- We also recommend including this at the beginning of your tutorial:

```` default
```{r copy-code-chunk, child = system.file("child_documents/copy_button.Rmd", package = "tutorial.helpers")}
```
````

This allows you to place a button in an exercise which will copy over
all the code from the previous exercise. Use:

    <button onclick = "transfer_code(this)">Copy previous code</button>

This is handy for students when a serious of exercises requires them to
build up a long pipe, line-by-line.

## Accessing Addins

In order to access the Addins, load the package.

``` r
library(tutorial.helpers)
```

This will load the relevant RStudio Addins.
