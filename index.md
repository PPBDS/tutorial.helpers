# Tutorial Helper Functions

## About this package

**tutorial.helpers** provides functions to help you write R tutorials,
especially if you follow [my
advice](https://ppbds.github.io/tutorial.helpers/articles/ai.html) about
the best way to do so.

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

#### Creating a tutorial

To create a new tutorial, you first need a new directory, located in the
`inst/tutorials` directory of your package. Create a `tutorial.Rmd` file
within it. The [AI
vignette](https://ppbds.github.io/tutorial.helpers/articles/ai.html)
provides a highly opinionated framework for teaching students how to use
AI to do data science, including the required `info_section` and
`download-answers` chunks which every tutorial should contain.

#### Testing

The package includes two important functions:
[`make_exercise()`](https://ppbds.github.io/tutorial.helpers/reference/exercise_creation.md)
and
[`check_current_tutorial()`](https://ppbds.github.io/tutorial.helpers/reference/check_current_tutorial.md).
Use
[`make_exercise()`](https://ppbds.github.io/tutorial.helpers/reference/exercise_creation.md)
to add a new exercise to the current tutorial. It will number the
exercise, and the code chunk labels, automatically. Use
[`check_current_tutorial()`](https://ppbds.github.io/tutorial.helpers/reference/check_current_tutorial.md)
to renumber all the exercises and relabel all the code chunks. This is
especially useful if you add or delete an exercise in the middle of a
section.

There are three exported functions for checking the tutorials in your
package. See the [testing
vignette](https://ppbds.github.io/tutorial.helpers/articles/testing.html)
for details on their use.

#### Tutorials

The package includes the “Getting Started” tutorial, which uses VS Code
on GitHub Codespaces. You should require your students to complete it if
you are creating your own tutorials with the **tutorial.helpers**
package. Have students run:

``` R
learnr::run_tutorial("getting-started", package = "tutorial.helpers")
```

This will teach them enough about how tutorials work to be able to
complete the tutorials you write.

#### Download answers

The most useful tool is the [download answers
trick](https://ppbds.github.io/tutorial.helpers/articles/downloads.html).
In your tutorial, simply include
[`library(tutorial.helpers)`](https://ppbds.github.io/tutorial.helpers/)
in the setup R code chunk and then insert this empty code chunk at the
end.

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
