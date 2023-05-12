#' Knit a set of tutorials
#'
#' @description We define "testing" a tutorial as (successfully) running
#'   `render()` on it. This function renders all the tutorials provided in
#'   `tutorial_paths`. There is no check to see if the rendered file looks OK,
#'   just that something has been produced. If a tutorial fails to render, then
#'   (we assume!) an error will be generated which will then filter up to our
#'   testing rig.
#'
#' @param tutorial_paths Character vector of the paths to the tutorials to be
#'   knitted.
#'
#' @returns No return value, called for side effects.
#'
#' @examples
#'   knit_tutorials(tutorial_paths = return_tutorial_paths("tutorial.helpers"))
#'
#' @export

knit_tutorials <- function(tutorial_paths){
  
  stopifnot(all(file.exists(tutorial_paths)))

  # Might we do more here? For example, what we really want to confirm is that,
  # when a student presses the "Start Tutorial" button, things will work. I am not
  # sure if render() is the same thing. But, the good news is that this test seems
  # much more robust than that. In other words, it catches things that do not
  # cause (immediate) failures with Start Tutorial.
  
  # The created files must be written in a temp directory in order to avoid
  # errors on Debian CRAN systems.
  
  # Recall that render() returns the path to the output document, so our "test"
  # just confirms that render() returns the same path as the tempfile() which we
  # provided as the output_file argument.

  for(i in tutorial_paths){
    out_file <- tempfile()
    cat(paste("Testing tutorial:", i, "\n"))
    testthat::test_that(paste("Rendering", i), {
      testthat::expect_output(
        rmarkdown::render(i, 
                          output_file = out_file),
        out_file)
    })
  }
  
  NULL
}

