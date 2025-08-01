#' Check Key Variables in List of Tibbles
#'
#' This function checks if specified key variables are present in each tibble's "id" column
#' and returns only tibbles that contain all required key variables.
#'
#' @param tibble_list A named list of tibbles, each containing an "id" column with question identifiers
#' @param key_vars A character vector of key variables to check for
#' @param verbose Verbosity level for reporting (default: 1)
#'   - 0: No messages
#'   - 1: Report removed files and missing variables
#'   - 2: Also report files that pass validation
#'
#' @return A list of tibbles that contain all required key variables
#'
#' @examples
#' \dontrun{
#' # Create sample data
#' tibble1 <- tibble(id = c("email", "age", "name"))
#' tibble2 <- tibble(id = c("email", "phone"))
#' tibble3 <- tibble(id = c("email", "age", "address"))
#' 
#' tibble_list <- list("file1.html" = tibble1, "file2.html" = tibble2, "file3.html" = tibble3)
#' 
#' # Check for required variables
#' valid_tibbles <- check_key_vars(tibble_list, c("email", "age"))
#' }
#' @export
check_key_vars <- function(tibble_list, key_vars, verbose = 0) {
  
  # Initialize list to store valid tibbles
  valid_tibbles <- list()
  
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
      if (verbose >= 1) {
        message("Removing '", file_name, "': no 'id' column")
      }
      next
    }
    
    # Check which key variables are present
    present_vars <- intersect(key_vars, tibble_data$id)
    missing_vars <- setdiff(key_vars, tibble_data$id)
    
    # If all key variables are present, keep the tibble
    if (length(missing_vars) == 0) {
      valid_tibbles[[file_name]] <- tibble_data
      if (verbose >= 2) {
        message("Keeping '", file_name, "': has all required key variables")
      }
    } else {
      # Report missing variables if verbose
      if (verbose >= 1) {
        message("Removing '", file_name, "': missing key variables: ", 
                paste(missing_vars, collapse = ", "))
      }
    }
  }
  
  # Report summary if verbose
  if (verbose >= 1) {
    n_original <- length(tibble_list)
    n_valid <- length(valid_tibbles)
    n_removed <- n_original - n_valid
    
    if (n_removed > 0) {
      message("Summary: ", n_removed, " tibble(s) removed, ", n_valid, " tibble(s) retained")
    } else {
      message("Summary: All ", n_original, " tibble(s) retained")
    }
  }
  
  return(valid_tibbles)
}