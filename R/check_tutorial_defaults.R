#' Confirm that a tutorial has the recommended components
#'
#' @description There are three code components: the use of a copy-code button,
#'   an information request, and a download page. It is tricky to know where to
#'   store the "truth" of what these components should look like. For now, the
#'   truth is defined as the `skeleton.Rmd` which defines the template for
#'   creating a new tutorial.
#'
#'   All tutorials should also have `library(learnr)` and
#'   `library(tutorial.helpers)`, both of which exist in the skeleton
#'
#' @param tutorial_paths Character vector of the paths to the tutorials to be
#'   examined.
#'
#' @examples
#'   check_tutorial_defaults(tutorial_paths = return_tutorial_paths("tutorial.helpers"))
#'
#' @returns No return value, called for side effects. 
#'
#' @export

check_tutorial_defaults <- function(tutorial_paths){
  
  stopifnot(all(file.exists(tutorial_paths)))

  skeleton_lines <- readLines(
    system.file(
      "rmarkdown/templates/tutorial_template/skeleton/skeleton.Rmd",
      package = "tutorial.helpers"))

  # The true hack is reducing components to just the three lines which we want
  # to ensure are present. This is especially dangerous because all the
  # components in the skeleton are placed on a single line. However, a tutorial
  # writer might format them differently. They would still work even if they
  # included line breaks. But such components would fail this check.

  components <- skeleton_lines[ grepl("child = system.file", skeleton_lines) ]

  # All tutorials should have library(learnr) and library(tutorial.helpers),
  # both of which exist in the skeleton.
  
  libs <- skeleton_lines[ grepl("library", skeleton_lines) ]
  
  for(i in tutorial_paths){
    target <- readLines(i)
    if(! all(components %in% target)){
      stop("Missing a component part from file ", i, "\n")
    }
    if(! all(libs %in% target)){
      stop("Missing a library call from file ", i, "\n")
    }
  }

  NULL
}


