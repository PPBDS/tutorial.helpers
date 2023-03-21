#' Return all the paths to tutorials
#'
#' @param package character vector of the package name to be tested
#'
#' @return character vector of the full paths to all installed tutorials in
#'   `package`
#' @description Takes a package name and returns a character vector of all the
#'   paths to tutorialsin the installed package, if those tutorials are named
#'   `tutorial.Rmd`.
#' @export

return_tutorial_paths <- function(package){

  # I am not sure if we need to worry about which installed version of the
  # package we are getting. Presumable the first item in .libPaths() is used . .
  # .

  # First, we need the location of the installed package. Second, we need  the
  # name of the directories in which the tutorials live. (I think this is all
  # the directories underneath inst/tutorials.) With those two components, we
  # find the path to all the Rmd files in those directories. (I think that, by
  # definition, any Rmd is a tutorial. We could, of course, parse the files
  # directly to see if they are all tutorials.)

  # Sadly, we can't simplify this since available_tutorials() does not return a
  # path. Maybe we submit a PR to available_tutorials() to add this?

  # Warning: Does this work on Windows?

  x <- list.files(paste0(system.file("tutorials", package = package),
                    "/",
                    learnr::available_tutorials(package)$name), pattern = "Rmd$", full.names = TRUE)

  # Check that all the files exist. Perhaps useless since list.files() only
  # returns files which exist?

  stopifnot(all(file.exists(x)))

  x
}



