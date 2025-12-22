
<!-- README.md is generated from README.Rmd. Edit ONLY this file if you need to make a change in README.md. But, after you edit it, you need to run devtools::build_readme() in order to create the new README.md, which is the thing which is actually used. -->

# Tutorial Helper Functions

<!-- badges: start -->

[![R build
status](https://github.com/PPBDS/tutorial.helpers/workflows/R-CMD-check/badge.svg)](https://github.com/PPBDS/tutorial.helpers/actions)
<!-- badges: end -->

## About this package

**tutorial.helpers** provides functions to help you write R tutorials,
especially if you follow [my
advice](https://ppbds.github.io/tutorial.helpers/articles/instructions.html)
about the best way to do so. This approach is currently used in several
packages, including
[**r4ds.tutorials**](https://ppbds.github.io/r4ds.tutorials/) and
[**positron.tutorials**](https://ppbds.github.io/positron.tutorials/).

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

#### Tutorial template

To create a new tutorial, you first need a new directory, located in the
`inst/tutorials` directory of your package. Once you create that
directory, make sure that your R session is located within it. Then,
issue this command:

    > rmarkdown::draft("tutorial.Rmd", 
                       template = "tutorial_template", 
                       package = "tutorial.helpers",
                       edit = TRUE)

This will create a new file, `tutorial.Rmd` in the current directory.
This highly opinionated template provides [a framework for teaching
students how to use AI to do data
science](https://ppbds.github.io/tutorial.helpers/articles/ai.html).

#### Testing

The package includes two important functions: `make_exercise()` and
`check_current_tutorial()`. Use `make_exercise()` to add a new exercise
to the current tutorial. It will number the exercise, and the code chunk
labels, automatically. Use `check_current_tutorial()` to renumber all
the exercises and relabel all the code chunks. This is especially useful
if you add or delete an exercise in the middle of a section.

There are three exported functions for checking the tutorials in your
package. See the [testing
vignette](https://ppbds.github.io/tutorial.helpers/articles/testing.html)
for details on their use.

#### Tutorials

The package includes three tutorials: “Getting Started,” “Introduction
to R,” and “Introduction to Python.” You should require your students to
complete the “Getting Started” tutorial if you are creating your own
tutorials with **tutorial.helpers** package. For example, in Positron,
have students run:

    learnr::run_tutorial(getting-started", package = "tutorial.helpers")

This will teach them enough about how tutorials work to be able to
complete the tutorials you write. If you are also teaching R, we
strongly recommend the “Introduction to R” tutorial.

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

#### Recommended components

We recommend including this child document at the start of each
tutorial:

```` default
```{r info-section, child = system.file("child_documents/info_section.Rmd", package = "tutorial.helpers")}
```
````

This will insert (optional) questions asking for the student’s name,
email and id.

We recommend ending the tutorial with the download-answers child
document, as discussed above.

```` default
```{r download-answers, child = system.file("child_documents/download_answers.Rmd", package = "tutorial.helpers")}
```
````
