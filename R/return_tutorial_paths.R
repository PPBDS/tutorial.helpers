#' Return all the paths to tutorials
#'
#' @param package character vector of the package name to be tested
#'
#' @return character vector of tutorial paths
#' @export

return_tutorial_paths <- function(package){

  # Would be nice if the function could automatically discover the library it is
  # currently operating within.

  # Make code rely on fewer packages.

  # This testing approach only works, I think, when you click `Build -> Check`.
  # Otherwise, the tutorials you are testing might be those you installed
  # previously, not the ones you just edited.

  package_location <- system.file("tutorials", package = package)

  tutorial_paths <-
    learnr::available_tutorials(package) |>
    dplyr::mutate(path = paste0(package_location, "/",
                                name,
                                "/tutorial.Rmd")) |>
    dplyr::pull(path)


}

# Never understand what this hack does or why it is necessary.


