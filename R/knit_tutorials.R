#' Knit all the tutorials in a package
#'
#' @param package character vector of the package name to be tested
#'
#' @return NULL
#' @export

knit_tutorials <- function(package){

  # This testing approach only works, I think, when you click `Build -> Check`.
  # Otherwise, the tutorials you are testing might be those you installed
  # previously, not the ones you just edited.

  tutorial_paths <- return_tutorial_paths(package)

  stopifnot(length(tutorial_paths) >= 1)

  # We use the tutorial_paths vector in the testing functions which now get run.

  # Our definition of "test" for a tutorial file is to run render() and hope there
  # is no error. There is no check to see if "tutorial.html" looks OK, just that
  # that string is returned.

  # Might we do more here? For example, what we really want to confirm is that,
  # when a student presses the "Start Tutorial" button, things will work. I am not
  # sure if render() is the same thing. But, the good news is that this test seems
  # much more robust than that. In other words, it catches things that do not
  # cause (immediate) failures with Start Tutorial.

  for(i in tutorial_paths){
    cat(paste("Testing tutorial:", i, "\n"))
    testthat::test_that(paste("rendering", i), {
      testthat::expect_output(rmarkdown::render(i, output_file = "tutorial.html"),
                    "tutorial.html")
    })
  }

  # There are two problems with this list of files. First, it is long! There are a
  # lot of tutorials and they take a while to run. There is not a lot to be done
  # about that. The second problem is that there is no way to customize it.
  # Sometimes, we would just like to test one tutorial, especially while we are
  # working on it. Other times, we want to test all the tutorials but one.

  NULL
}

