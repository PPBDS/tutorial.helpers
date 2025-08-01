#' Check Membership in List of Tibbles
#'
#' This function filters a list of tibbles based on whether a key variable's value
#' is among the allowed values. Useful for keeping only specific students or participants.
#'
#' @param tibble_list A named list of tibbles, each containing an "id" column and a data column
#' @param key_var A character string specifying the key variable to check (must exist in each tibble's "id" column)
#' @param membership A character vector of allowed values for the key variable
#' @param verbose Verbosity level for reporting (default: 0)
#'   - 0: No messages
#'   - 1: Report removed files and their values
#'   - 2: Also report files that pass the membership check
#'
#' @return A list of tibbles where the key variable's value is in the membership list
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
#' allowed_emails <- c("john@student.edu", "mary@student.edu", "bob@student.edu")
#' 
#' # Keep only students with allowed emails
#' valid_students <- check_membership(tibble_list, "email", allowed_emails)
#' }
#' @export
check_membership <- function(tibble_list, key_var, membership, verbose = 0) {
  
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
    
    # Check if tibble has the key variable
    if (!key_var %in% tibble_data$id) {
      if (verbose >= 1) {
        message("Removing '", file_name, "': missing key variable '", key_var, "'")
      }
      next
    }
    
    # Get the value of the key variable
    key_var_row <- which(tibble_data$id == key_var)
    
    # Check if tibble has a 'data' column
    if (!"data" %in% colnames(tibble_data)) {
      if (verbose >= 1) {
        message("Removing '", file_name, "': no 'data' column to check value")
      }
      next
    }
    
    key_var_value <- tibble_data$data[key_var_row]
    
    # Check if the value is in the membership list
    if (key_var_value %in% membership) {
      valid_tibbles[[file_name]] <- tibble_data
      if (verbose >= 2) {
        message("Keeping '", file_name, "': ", key_var, " = '", key_var_value, "' is in membership list")
      }
    } else {
      if (verbose >= 1) {
        message("Removing '", file_name, "': ", key_var, " = '", key_var_value, "' not in membership list")
      }
    }
  }
  
  # Report summary if verbose
  if (verbose >= 1) {
    n_original <- length(tibble_list)
    n_valid <- length(valid_tibbles)
    n_removed <- n_original - n_valid
    
    if (n_removed > 0) {
      message("Membership check summary: ", n_removed, " tibble(s) removed, ", n_valid, " tibble(s) retained")
    } else {
      message("Membership check summary: All ", n_original, " tibble(s) retained")
    }
  }
  
  return(valid_tibbles)
}