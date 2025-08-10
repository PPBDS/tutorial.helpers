#' Confirm that a tutorial has the recommended components
#'
#' @description Checks that tutorials contain required libraries and child 
#'   documents. The function looks for library() calls and child document
#'   inclusions in the tutorial files.
#'
#' @param tutorial_paths Character vector of the paths to the tutorials to be
#'   examined.
#'   
#' @param libraries Character vector of library names that should be loaded
#'   in the tutorial. The function looks for `library(name)` calls. Default
#'   is `c("learnr", "tutorial.helpers")`.
#'   
#' @param children Character vector of child document names (without the .Rmd
#'   extension) that should be included in the tutorial. The function looks 
#'   for these in child document inclusion chunks. Default is 
#'   `c("info_section", "download_answers")`.
#'
#' @examples
#'   # Check with default requirements
#'   check_tutorial_defaults(
#'     tutorial_paths = return_tutorial_paths("tutorial.helpers")
#'   )
#'   
#'   # Check for specific libraries only
#'   check_tutorial_defaults(
#'     tutorial_paths = return_tutorial_paths("tutorial.helpers"),
#'     libraries = c("learnr", "knitr"),
#'     children = c("copy_button")
#'   )
#'
#' @returns No return value, called for side effects. 
#'
#' @export

check_tutorial_defaults <- function(tutorial_paths,
                                    libraries = c("learnr", "tutorial.helpers"),
                                    children = c("info_section", "download_answers")) {
  
  stopifnot(all(file.exists(tutorial_paths)))
  
  for(tutorial_path in tutorial_paths) {
    
    # Read the tutorial content
    
    tutorial_lines <- readLines(tutorial_path)
    
    
    # Check for required libraries
    # Look for lines like: library(learnr) or library("learnr") or library('learnr')
    
    if(length(libraries) > 0) {
      for(lib in libraries) {
        
        # Create regex pattern to match library calls with or without quotes
        
        lib_pattern <- sprintf("library\\(['\"]?%s['\"]?\\)", lib)
        
        if(!any(grepl(lib_pattern, tutorial_lines))) {
          stop("Missing library(", lib, ") call in file ", tutorial_path, "\n")
        }
      }
    }
    
    
    # Check for required child documents
    # Look for lines containing child document inclusions
    # Pattern matches: child = system.file("child_documents/[name].Rmd", package = "tutorial.helpers")
    # Also handles variations in spacing and quotes
    
    if(length(children) > 0) {
      for(child in children) {
        
        # Create regex pattern to match child document inclusion
        # This pattern is flexible about quotes and spacing
        
        child_pattern <- sprintf(
          "child\\s*=\\s*system\\.file\\(['\"].*/%s\\.Rmd['\"]",
          child
        )
        
        if(!any(grepl(child_pattern, tutorial_lines))) {
          stop("Missing child document '", child, "' in file ", tutorial_path, "\n")
        }
      }
    }
  }
  
  invisible(NULL)
}
