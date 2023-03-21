#' Check that all the tutorials in a package have standard components
#'
#' @param package character vector of the package name to be tested
#'
#' @return NULL
#' @export

check_tutorial_defaults <- function(package){

  # Only makes sense to run this function on a package in which all the
  # tutorials follow the pattern used in r4ds.tutorials. There are three
  # components: the use of a copy-code button, an information request, and a
  # download page.

  tutorial_paths <- return_tutorial_paths(package)

  stopifnot(length(tutorial_paths) >= 1)

  # This code/approach is very similar to the knit_tutorials() function. But, it
  # is separate since someone might not want to use these patterns, but should
  # still check to see that their tutorials knit.

  # Check location of these files.

  copy_button_lines <- readLines("test-data/copy_button_check.txt")
  information_lines <- readLines("test-data/information_check.txt")
  submission_lines  <- readLines("test-data/submission_check.txt")

  for(i in tutorial_paths){
    cur_file <- readLines(i)
    cat(paste("Testing tutorial:", i, "\n"))
    if(! all(copy_button_lines %in% cur_file)){
      stop("Copy button lines missing from file ", i, "\n")
      }
    if(! all(information_lines %in% cur_file)){
      stop("Information lines missing from file ", i, "\n")
      }
    if(! all(submission_lines %in% cur_file)){
      stop("Submission lines missing from file ", i, "\n")
      }
    }
}

