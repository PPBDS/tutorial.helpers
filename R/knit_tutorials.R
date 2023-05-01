#' Knit all the tutorials in a package
#'
#' @param tutorial_paths character vector of the paths to the tutorials to be 
#'  knitted
#'
#' @return NULL
#' 
#' @examples
#' \dontrun{
#' knit_tutorials(tutorial_paths = return_tutorial_paths('learnr'))
#' }
#' 
#' @export

knit_tutorials <- function(tutorial_paths){
  
  stopifnot(all(file.exists(tutorial_paths)))

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
  
  NULL
}

