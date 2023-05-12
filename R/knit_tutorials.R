#' Knit a set of tutorials
#'
#' @description We define "testing" a tutorial as (successfully) running
#'   `render()` on it. This function renders all the tutorials provided in
#'   `tutorial_paths`. There is no check to see if the rendered file looks OK.
#'   If a tutorial fails to render, then (we assume!) an error will be generated
#'   which will then filter up to our testing rig.
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

  for(i in tutorial_paths){
     testthat::test_that(paste("Rendering", i), {
        rmarkdown::render(i, 
                          output_file = tempfile())
    })
  }
  
  NULL
}

