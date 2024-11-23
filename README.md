
<!-- README.md is generated from README.Rmd. Edit ONLY this file if you need to make a change in README.md. But, after you edit it, you NEED TO KNIT IT BY HAND in order to create the new README.md, which is the thing which is actually used. -->

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
[**primer.tutorials**](https://ppbds.github.io/primer.tutorials/) and
[**r4ds.tutorials**](https://ppbds.github.io/r4ds.tutorials/).

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

#### Download answers

The most useful tool is the [download answers
trick](https://ppbds.github.io/tutorial.helpers/articles/downloads.html).
In your tutorial, simply include `library(tutorial.helpers)` in the
setup R code chunk and then insert this empty code chunk at the end.

```` default
```{r download-answers, child = system.file("child_documents/download_answers.Rmd", package = "tutorial.helpers")}
```
````

This will ask the student to provide an estimate of how long the
tutorial took to complete. It will then provide the ability to download
the student’s answers in html format. Students submit these files to
their instructors, who can then confirm that the work was completed and
look for any patterns in student (mis)understandings.

#### Testing

There are three exported functions for checking the tutorials in your
package. See the [testing
vignette](https://ppbds.github.io/tutorial.helpers/articles/testing.html)
for details on their use.

#### Recommended components

We recommend including this child document at the start of each
tutorial:

```` default
```{r info-section, child = system.file("child_documents/info_section.Rmd", package = "tutorial.helpers")}
```
````

This will insert (optinal) questions asking for the student’s name,
email and id.

We also recommend including this at the beginning of your tutorial:

```` default
```{r copy-code-chunk, child = system.file("child_documents/copy_button.Rmd", package = "tutorial.helpers")}
```
````

This allows you to place a button in an exercise which will allow
students to copy over all the code from the previous exercise. Use:

    <button onclick = "transfer_code(this)">Copy previous code</button>

This is handy for students when a series of exercises requires them to
build up a long pipe, line-by-line.

We recommend ending the tutorial with the download-answers child
document, as discussed above.

```` default
```{r download-answers, child = system.file("child_documents/download_answers.Rmd", package = "tutorial.helpers")}
```
````

#### Addins

In order to access the addins, load the package. See the [addins
vignette](https://ppbds.github.io/tutorial.helpers/articles/addins.html)
for details about their use.

#### Getting Started with Tutorials

The package includes a tutorial, “Getting Started with Tutorials,” which
provides an introduction to tutorials for beginning students. You should
require your students to complete this tutorial if you are using
**tutorial.packages** to create your own tutorials.
