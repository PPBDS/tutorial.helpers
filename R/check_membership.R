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
#' @param verbose Verbosity level for reporting (default: 0)
#'   - 0: No messages
#'   - 1: Report removed files and their values, plus summary
#'   - 2: Also report files that pass each check
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
check_membership <- function(tibble_list, key_var, membership, verbose = 0) {
  
  # First, use check_key_vars to filter tibbles that have the required key variable
  if (verbose >= 1) {
    message("Step 1: Checking for required key variable '", key_var, "'...")
  }
  
  # Set verbose level for check_key_vars (reduce verbosity to avoid duplicate messages)
  check_verbose <- ifelse(verbose >= 2, 1, 0)
  tibbles_with_key <- check_key_vars(tibble_list, key_var, verbose = check_verbose)
  
  if (length(tibbles_with_key) == 0) {
    if (verbose >= 1) {
      message("No tibbles contain the required key variable '", key_var, "'")
    }
    return(list())
  }
  
  if (verbose >= 1) {
    message("Step 2: Checking membership for key variable '", key_var, "'...")
  }
  
  # Initialize list to store valid tibbles
  valid_tibbles <- list()
  
  # Check membership for each tibble that passed the key variable check
  for (file_name in names(tibbles_with_key)) {
    tibble_data <- tibbles_with_key[[file_name]]
    
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
    n_with_key <- length(tibbles_with_key)
    n_final <- length(valid_tibbles)
    n_removed_key <- n_original - n_with_key
    n_removed_membership <- n_with_key - n_final
    
    message("Final summary:")
    message("- Started with: ", n_original, " tibble(s)")
    message("- Removed ", n_removed_key, " tibble(s) for missing key variable '", key_var, "'")
    message("- Removed ", n_removed_membership, " tibble(s) for membership check")
    message("- Final result: ", n_final, " tibble(s) retained")
  }
  
  return(valid_tibbles)
}