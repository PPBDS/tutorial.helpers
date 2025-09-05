#' Return all the paths to the tutorials in a package
#'
#' @param package Character string of the package name to be tested.
#' 
#' @description Takes a package name and returns a character vector of all the
#'   paths to tutorials in the installed package. This function looks for all
#'   R Markdown files (.Rmd) in the inst/tutorials/ subdirectories of the
#'   specified package. It uses learnr::available_tutorials() to identify
#'   tutorial directories, with a fallback to directory scanning if that fails.
#'   
#' @details The function first checks if the package is installed and has a
#'   tutorials directory. It then attempts to use learnr::available_tutorials()
#'   to get the official list of tutorial directories. If that fails (e.g., if
#'   the package doesn't properly register its tutorials with learnr), it falls
#'   back to scanning all subdirectories under inst/tutorials/. Finally, it
#'   collects all .Rmd files from these directories.
#'   
#'   Returns an empty character vector if the package has no tutorials or
#'   doesn't exist, rather than throwing an error.
#'   
#' @returns Character vector of the full paths to all installed tutorials in
#'   `package`. Returns character(0) if no tutorials are found or if the
#'   package doesn't exist.
#'   
#' @examples
#' \dontrun{
#'   # Get all learnr tutorial paths
#'   return_tutorial_paths('learnr')
#'   
#'   # Get tutorial paths from your own package
#'   return_tutorial_paths('tutorial.helpers')
#'   
#'   # Returns empty vector for packages without tutorials
#'   return_tutorial_paths('base')
#' }
#'   
#' @export

return_tutorial_paths <- function(package) {
  
  # Input validation
  if (!is.character(package) || length(package) != 1) {
    stop("'package' must be a single character string", call. = FALSE)
  }
  
  # Check if package exists
  if (!requireNamespace(package, quietly = TRUE)) {
    warning("Package '", package, "' is not installed", call. = FALSE)
    return(character(0))
  }
  
  # Get base tutorials directory
  tutorials_base <- system.file("tutorials", package = package)
  if (tutorials_base == "") {
    # Package exists but has no tutorials directory
    return(character(0))
  }
  
  # Get tutorial subdirectories - try learnr first, fallback to manual scan
  tutorial_dirs <- tryCatch({
    # Attempt to use learnr's official tutorial registry
    available <- learnr::available_tutorials(package)
    if (is.data.frame(available) && "name" %in% names(available)) {
      available$name
    } else {
      character(0)
    }
  }, error = function(e) {
    # learnr method failed, fall back to directory scanning
    character(0)
  })
  
  # If learnr method failed or returned nothing, scan directories manually
  if (length(tutorial_dirs) == 0) {
    all_dirs <- list.dirs(tutorials_base, recursive = FALSE, full.names = FALSE)
    tutorial_dirs <- all_dirs[all_dirs != ""]
  }
  
  if (length(tutorial_dirs) == 0) {
    return(character(0))
  }
  
  # Build full paths to tutorial directories
  full_dirs <- file.path(tutorials_base, tutorial_dirs)
  
  # Find all .Rmd files in these directories
  tutorial_files <- character(0)
  
  for (dir in full_dirs) {
    if (dir.exists(dir)) {
      rmd_files <- list.files(dir, pattern = "\\.Rmd$", full.names = TRUE, 
                             recursive = FALSE, ignore.case = TRUE)
      tutorial_files <- c(tutorial_files, rmd_files)
    }
  }
  
  # Return sorted paths for consistent output
  sort(tutorial_files)
}