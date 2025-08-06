#' Check Membership in List of Tibbles
#'
#' This function filters a list of tibbles based on whether a key variable's value
#' is among the membership values. It first uses check_key_vars() to ensure the 
#' key variable exists, then checks membership. Useful for keeping only specific 
#' students or participants.
#'
#' @param tibble_list A named list of tibbles, each containing an "id" column and a data column
#' @param key_var A character string specifying the key variable to check
#' @param membership A character vector of allowed values for the key variable
#' @param verbose A logical value (TRUE or FALSE) specifying verbosity level.
#'        If TRUE, reports files that are removed and why.
#'
#' @return A list of tibbles where the key variable exists and its value is in the membership list
#'
#' @examples
#' \dontrun{
#' # Create sample data with student emails
#' tibble1 <- tibble(id = c("name", "email", "age"), 
#'                   data = c("John", "john@student.edu", "20"))
#' tibble2 <- tibble(id = c("name", "email", "age"), 
#'                   data = c("Jane", "jane@external.com", "22"))
#' 
#' tibble_list <- list("student1.html" = tibble1, "student2.html" = tibble2)
#' my_students <- c("john@student.edu", "mary@student.edu", "bob@student.edu")
#' 
#' # Keep only students with allowed emails
#' valid_students <- check_membership(tibble_list, "email", my_students)
#' }
#' @export
check_membership <- function(tibble_list, key_var, membership, verbose = FALSE) {
  
  # Validate verbose parameter
  if (!is.logical(verbose) || length(verbose) != 1) {
    stop("'verbose' must be a single logical value (TRUE or FALSE).")
  }
  
  # First, use check_key_vars to filter tibbles that have the required key variable
  tibbles_with_key <- check_key_vars(tibble_list, key_var, verbose = FALSE)
  
  if (length(tibbles_with_key) == 0) {
    if (verbose) {
      message("Removed all ", length(tibble_list), " tibble(s): none contain the required key variable '", key_var, "'")
    }
    return(list())
  }
  
  # Track removed files from key variable check
  key_removed_count <- length(tibble_list) - length(tibbles_with_key)
  
  # Initialize list to store valid tibbles
  valid_tibbles <- list()
  removed_files <- character()
  removal_reasons <- character()
  
  # Check membership for each tibble that passed the key variable check
  for (file_name in names(tibbles_with_key)) {
    tibble_data <- tibbles_with_key[[file_name]]
    
    # Get the value of the key variable
    key_var_row <- which(tibble_data$id == key_var)
    
    # Check if tibble has a 'data' column
    if (!"data" %in% colnames(tibble_data)) {
      removed_files <- c(removed_files, file_name)
      removal_reasons <- c(removal_reasons, "no 'data' column to check value")
      next
    }
    
    key_var_value <- tibble_data$data[key_var_row]
    
    # Check if the value is in the membership list
    if (key_var_value %in% membership) {
      valid_tibbles[[file_name]] <- tibble_data
    } else {
      removed_files <- c(removed_files, file_name)
      removal_reasons <- c(removal_reasons, paste0(key_var, " = '", key_var_value, "' not in membership list"))
    }
  }
  
  # Report removed files if verbose
  if (verbose) {
    # Report files removed for missing key variable
    if (key_removed_count > 0) {
      message("Removed ", key_removed_count, " tibble(s): missing key variable '", key_var, "'")
    }
    
    # Report files removed for membership check
    if (length(removed_files) > 0) {
      for (i in seq_along(removed_files)) {
        message("Removed '", removed_files[i], "': ", removal_reasons[i])
      }
    }
    
    # Final summary
    n_original <- length(tibble_list)
    n_final <- length(valid_tibbles)
    message("Summary: ", (n_original - n_final), " tibble(s) removed, ", n_final, " tibble(s) retained")
  }
  
  return(valid_tibbles)
}