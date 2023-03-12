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
  # package we are getting. Presumable the first item is=n .libPaths() is used .
  # . .

  # Perhaps the package should not require the the tutorials are in files called
  # `tutorial.Rmd`? It seems like tutorials files can have any name . . .

  # Not sure how to test this given that I don't want to install any fake
  # tutorials in this package. Maybe run it on learnr which, by default, must be
  # installed?

  # There are four parts to the path. First, the location of the installed
  # package. Second, a slash to end the path. Third, the name of the tutorials
  # (which is, I think, the name of the directory in which the tutorial lives).
  # Fourth, the name of the file, which we hard code to `tutorial.Rmd`.

  # Warning: Does this work on Windows?

  paste0(system.file("tutorials", package = package),
         "/",
         learnr::available_tutorials(package)$name,
         "/tutorial.Rmd")
}



