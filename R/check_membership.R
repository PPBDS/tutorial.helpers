#' Check Membership in List of Tibbles
#'
#' This function filters a list of tibbles based on whether a key variable's value
#' is among the membership values. It first uses check_key_vars() to ensure the 
#' key variable exists, then checks membership. Useful for keeping only specific 
#' students or participants.
#'
#' @param tibble_list A named list of tibbles, each containing an "id" column and an "answer" column
#' @param key_var A character string specifying the key variable to check
#' @param membership A character vector of allowed values for the key variable
#' @param verbose Logical indicating whether to report removed items (default: FALSE)
#'
#' @return A list of tibbles where the key variable exists and its value is in the membership list
#'
#' @examples
#' \dontrun{
#' # Create sample data with student emails
#' path <- file.path(find.package("tutorial.helpers"), "tests/testthat/fixtures/answers_html")
#' 
#' tibble_list <- gather_submissions(path, "stop")
#' 
#' result <- check_membership(tibble_list, 
#'                            key_var = "email", 
#'                            membership = c("bluebird.jack.xu@gmail.com", 
#'                                           "hassan.alisoni007@gmail.com"))
#' 
#' }
#' @export
check_membership <- function(tibble_list, key_var, membership, verbose = FALSE) {
  
  # First, use check_key_vars to filter tibbles that have the required key variable
  if (verbose) {
    message("Step 1: Checking for required key variable '", key_var, "'...")
  }
  
  # Use check_key_vars without verbose output to avoid duplicate messages
  tibbles_with_key <- check_key_vars(tibble_list, key_var, verbose = FALSE)
  
  if (length(tibbles_with_key) == 0) {
    if (verbose) {
      message("No tibbles contain the required key variable '", key_var, "'")
    }
    return(list())
  }
  
  if (verbose) {
    message("Step 2: Checking membership for key variable '", key_var, "'...")
  }
  
  # Initialize list to store valid tibbles
  valid_tibbles <- list()
  
  # Track emails found for verbose reporting
  emails_found <- character()
  emails_kept <- character()
  emails_removed <- character()
  
  # Check membership for each tibble that passed the key variable check
  for (file_name in names(tibbles_with_key)) {
    tibble_data <- tibbles_with_key[[file_name]]
    
    # Get the value of the key variable
    key_var_row <- which(tibble_data$id == key_var)
    
    # Check if we found the key variable
    if (length(key_var_row) == 0) {
      next
    }
    
    # Check if tibble has an 'answer' column (where the values are stored)
    if (!"answer" %in% colnames(tibble_data)) {
      next
    }
    
    key_var_value <- tibble_data$answer[key_var_row]
    emails_found <- c(emails_found, key_var_value)
    
    # Check if the value is in the membership list
    if (key_var_value %in% membership) {
      valid_tibbles[[file_name]] <- tibble_data
      emails_kept <- c(emails_kept, key_var_value)
    } else {
      emails_removed <- c(emails_removed, key_var_value)
    }
  }
  
  # Report summary if verbose
  if (verbose) {
    n_original <- length(tibble_list)
    n_with_key <- length(tibbles_with_key)
    n_final <- length(valid_tibbles)
    n_removed_key <- n_original - n_with_key
    n_removed_membership <- n_with_key - n_final
    
    message("Email summary:")
    
    # Show emails that were kept (present in membership)
    if (length(emails_kept) > 0) {
      message("- Emails found and kept (", length(emails_kept), "): ", paste(emails_kept, collapse = ", "))
    } else {
      message("- Emails found and kept: none")
    }
    
    # Show emails that were removed (not in membership)
    if (length(emails_removed) > 0) {
      message("- Emails found but not in membership (", length(emails_removed), "): ", paste(emails_removed, collapse = ", "))
    } else {
      message("- Emails found but not in membership: none")
    }
    
    # Show membership emails that were not found
    emails_not_found <- setdiff(membership, emails_found)
    if (length(emails_not_found) > 0) {
      message("- Membership emails not found (", length(emails_not_found), "): ", paste(emails_not_found, collapse = ", "))
    } else {
      message("- All membership emails were found")
    }
    
    message("Final summary:")
    message("- Started with: ", n_original, " tibble(s)")
    message("- Removed ", n_removed_key, " tibble(s) for missing key variable '", key_var, "'")
    message("- Removed ", n_removed_membership, " tibble(s) for membership check")
    message("- Final result: ", n_final, " tibble(s) retained")
  }
  
  return(valid_tibbles)
}