#' Check that a tutorial has the standard components
#'
#' @param path character variable of the path to the tutorial to be tested
#'
#' @export

check_tutorial_defaults <- function(path){

  # There are three code components: the use of a copy-code button, an
  # information request, and a download page. It is tricky to know where to
  # store the "truth" of what these components should look like. For now, the
  # truth is defined as the skeleton.Rmd which defines the template for creating
  # a new tutorial.

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

  if(! all(components %in% readLines(path))){
    stop("Missing a component part from file ", path, "\n")
  }

  # All tutorials should have library(learnr) and library(tutorial.helpers),
  # both of which exist in the skeleton.

  libs <- skeleton_lines[ grepl("library", skeleton_lines) ]

  if(! all(libs %in% readLines(path))){
    stop("Missing a library call from file ", path, "\n")
  }

}


