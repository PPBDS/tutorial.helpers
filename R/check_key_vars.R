#' Check Key Variables in List of Tibbles
#'
#' This function checks if specified key variables are present in each tibble's "id" column
#' and returns only tibbles that contain all required key variables.
#'
#' @param tibble_list A named list of tibbles, each containing an "id" column with question identifiers
#' @param key_vars A character vector of key variables to check for
#' @param verbose A logical value (TRUE or FALSE) specifying verbosity level. 
#'        If TRUE, reports tibbles that are removed and why.
#'
#' @return A list of tibbles that contain all required key variables
#'
#' @examples
#' \dontrun{
#' # Create sample data
#' path <- file.path(find.package("tutorial.helpers"), "tests/testthat/fixtures/answers_html")
#' 
#' tibble_list <- gather_submissions(path, "stop")
#' 
#' result <- check_key_vars(tibble_list, 
#'                          key_vars = c("name", "email"))
#'
#' }
#' @export
check_key_vars <- function(tibble_list, key_vars, verbose = FALSE) {
  
  # Validate verbose parameter
  if (!is.logical(verbose) || length(verbose) != 1) {
    stop("'verbose' must be a single logical value (TRUE or FALSE).")
  }
  
  # Initialize list to store valid tibbles
  valid_tibbles <- list()
  removed_files <- character()
  removal_reasons <- character()
  
  # Get names of tibbles (use indices if no names provided)
  if (is.null(names(tibble_list))) {
    tibble_names <- paste0("tibble_", seq_along(tibble_list))
  } else {
    tibble_names <- names(tibble_list)
  }
  
  # Check each tibble
  for (i in seq_along(tibble_list)) {
    tibble_data <- tibble_list[[i]]
    file_name <- tibble_names[i]
    
    # Check if tibble has an 'id' column
    if (!"id" %in% colnames(tibble_data)) {
      removed_files <- c(removed_files, file_name)
      removal_reasons <- c(removal_reasons, "no 'id' column")
      next
    }
    
    # Check which key variables are present
    missing_vars <- setdiff(key_vars, tibble_data$id)
    
    # If all key variables are present, keep the tibble
    if (length(missing_vars) == 0) {
      valid_tibbles[[file_name]] <- tibble_data
    } else {
      # Track removal
      removed_files <- c(removed_files, file_name)
      removal_reasons <- c(removal_reasons, paste("missing key variables:", paste(missing_vars, collapse = ", ")))
    }
  }
  
  # Report removed files if verbose
  if (verbose && length(removed_files) > 0) {
    for (i in seq_along(removed_files)) {
      message("Removed '", removed_files[i], "': ", removal_reasons[i])
    }
    message("Summary: ", length(removed_files), " tibble(s) removed, ", length(valid_tibbles), " tibble(s) retained")
  }
  
  return(valid_tibbles)
}