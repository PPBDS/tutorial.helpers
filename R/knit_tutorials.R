#' Knit a set of tutorials
#'
#' @description We define "testing" a tutorial as (successfully) running
#'   `render()` on it. This function renders all the tutorials provided in
#'   `tutorial_paths`. There is no check to see if the rendered file looks OK.
#'   If a tutorial fails to render, then an error will be generated which will
#'   propagate to the caller.
#'
#' @param tutorial_paths Character vector of the paths to the tutorials to be
#'   knitted.
#'
#' @returns No return value, called for side effects.
#'
#' @examples
#' \dontrun{
#'   knit_tutorials(tutorial_paths = return_tutorial_paths("tutorial.helpers"))
#' }
#'
#' @export

knit_tutorials <- function(tutorial_paths){
  
  stopifnot(all(file.exists(tutorial_paths)))

  # Might we do more here? For example, what we really want to confirm is that,
  # when a student presses the "Start Tutorial" button, things will work. I am not
  # sure if render() is the same thing. But, the good news is that this test seems
  # much more robust than that. In other words, it catches things that do not
  # cause (immediate) failures with Start Tutorial.
  
  # Note that the Debian setup on CRAN does not allow for writing files to any
  # location other than the temporary directory, which is why we must specify
  # tempdir() in the two dir arguments.
  
  # Would be nice to have more flexibility with knit_tutorials(). The problem
  # arises when knitting a collection of tutorial paths takes too long,
  # especially on CRAN, where all tests should only take 10 minutes total. Might
  # be nice if tutorial paths:
    
  # 1) Had an option to report the time (or start/end time) which each knitting
  # used. We want to identify which tutorials take too long to knit. Right now,
  # there is no easy way to do so.
  
  # 2) Provide a `skip` argument to knit_tutorials which allows it to skip any
  # tutorial path which includes a specific string. This will generally be used
  # like skip = c("06-data-tidying", "08-data-import"). Note that these are not
  # the names of tutorial files (which are mostly "tutorial.Rmd") nor the full
  # path to those tutorials (which we don't know until we run
  # `return_tutorial_paths()`). Instead, they are strings from within the path.
  # (Maybe require that they be full parts of the path? Or maybe any match is
  # fine?)

  for(i in tutorial_paths){
    message("Rendering: ", i)
    tryCatch({
      rmarkdown::render(input = i, 
                        output_dir = tempdir(),
                        intermediates_dir = tempdir())
      message("Successfully rendered: ", i)
    }, error = function(e) {
      stop("Failed to render ", i, ": ", e$message, call. = FALSE)
    })
  }
  
  message("Successfully rendered ", length(tutorial_paths), " tutorial(s)")
  invisible(NULL)
}