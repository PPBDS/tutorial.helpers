# Testing Your Package of Tutorials

This vignette demonstrates how to use the **tutorial.helpers** package
to “test” the tutorials in your package. I place “test” in quotes
because the testing is not very extensive. We are merely ensuring that
your tutorials can be knitted without error. I *think* that this
guarantees that the tutorials will run when students run
[`learnr::run_tutorial()`](https://pkgs.rstudio.com/learnr/reference/run_tutorial.html),
but I am not certain. This testing certainly does nothing to ensure that
the substance of your tutorial is correct.

If you are using the [**testthat**](https://testthat.r-lib.org/)
framework for testing, the `tests` directory would have a file called
`testthat.R` which just contains:

    library(testthat)
    library(your.package)

    test_check("your.packge")

Note how the name of **your.package** is not quoted with
[`library()`](https://rdrr.io/r/base/library.html) but is quoted with
`test_check()`.

Within the `tests/testthat` directory there will be a variety of testing
scripts. Create a file called `test-tutorials.R`. (The file can be named
whatever you want, consistent with **testthat** requirements.) It might
contain:

    tut_paths <- tutorial.helpers::return_tutorial_paths("your.package")

    test_that("All tutorials can be knit without error", {
      expect_null(
        tutorial.helpers::knit_tutorials(tut_paths)
      )
    })


    test_that("All tutorials have the expected components", {
      expect_null(
        tutorial.helpers::check_tutorial_defaults(tut_paths)
      )
    })

The first step in testing the tutorials in your package is to determine
the the full paths to all those tutorials. The
[`return_tutorial_paths()`](https://ppbds.github.io/tutorial.helpers/reference/return_tutorial_paths.md)
returns a vector of those paths.

The second step is to confirm that all your tutorials knit without
error.
[`knit_tutorials()`](https://ppbds.github.io/tutorial.helpers/reference/knit_tutorials.md),
perhaps the most useful function in the entire package, accomplishes
this. If a tutorial does not knit, an error is generated and the test
fails.

The third step is only relevant for tutorial creators who follow [our
advice](https://ppbds.github.io/tutorial.helpers/articles/ai.md)
concerning tutorial construction. In particular,
[`check_tutorial_defaults()`](https://ppbds.github.io/tutorial.helpers/reference/check_tutorial_defaults.md)
ensures that, somewhere in each tutorial, you have included the same key
components as exist in the “Tutorial Helpers” R Markdown template.

[`check_tutorial_defaults()`](https://ppbds.github.io/tutorial.helpers/reference/check_tutorial_defaults.md)
also fails if you do not have
[`library(learnr)`](https://rstudio.github.io/learnr/) and
[`library(tutorial.helpers)`](https://ppbds.github.io/tutorial.helpers/)
in your tutorial.

Both
[`knit_tutorials()`](https://ppbds.github.io/tutorial.helpers/reference/knit_tutorials.md)
and
[`check_tutorial_defaults()`](https://ppbds.github.io/tutorial.helpers/reference/check_tutorial_defaults.md)
return `NULL`, which is why we use `expect_null()`.
