#' Check that a tutorial has the standard components
#'
#' @param path character variable of the path to the tutorial to be tested
#'
#' @export

check_tutorial_defaults <- function(path){

  # There are three components: the use of a copy-code button, an information
  # request, and a download page. It is tricky to know where to store the
  # "truth" of what these components should look like. For now, the truth as
  # defined as the skeleton.Rmd which defines the template for creating a new
  # tutorial.

  components <- readLines(
    system.file(
      "rmarkdown/templates/tutorial_template/skeleton/skeleton.Rmd",
      package = "tutorial.helpers"))

  # The true hack is reducing components to just the three lines which we want
  # to ensure are present. This is especially dangerous because all the
  # components in the skeleton are placed on a single line. However, a tutorial
  # writer might format them differently. They would still work even if they
  # included line breaks. But such components would fail this check.

  components <- components[ grepl("child = system.file", components) ]

  if(! all(components %in% readLines(path))){
    stop("Missing a component part from file ", i, "\n")
    }
}

