#' Check Key Variables in Tibble
#'
#' This function checks if specified key variables are present in a tibble's "id" column
#' and reports on their availability.
#'
#' @param tibble_data A tibble containing an "id" column with question identifiers
#' @param key_vars A character vector of key variables to check for
#' @param file_name Optional file name for reporting purposes (default: "Unknown")
#' @param verbose Verbosity level for reporting (default: 1)
#'
#' @return A list containing:
#'   - valid: logical indicating if all key variables are present
#'   - missing: character vector of missing key variables
#'   - present: character vector of present key variables
#'   - error: character string describing any structural errors (e.g., missing 'id' column)
#'
#' @examples
#' \dontrun{
#' check_result <- check_key_vars(my_tibble, c("email", "age"), "file1.html")
#' if (!check_result$valid) {
#'   message("Missing variables: ", paste(check_result$missing, collapse = ", "))
#' }
#' }
#' @export
check_key_vars <- function(tibble_data, key_vars, file_name = "Unknown", verbose = 1) {
  
  # Check if tibble has an 'id' column
  if (!"id" %in% colnames(tibble_data)) {
    if (verbose >= 1) {
      message("File '", file_name, "' does not have an 'id' column.")
    }
    return(list(
      valid = FALSE,
      missing = key_vars,
      present = character(0),
      error = "No 'id' column"
    ))
  }
  
  # Check which key variables are present
  present_vars <- intersect(key_vars, tibble_data$id)
  missing_vars <- setdiff(key_vars, tibble_data$id)
  
  # Report results if verbose
  if (verbose >= 1) {
    if (length(missing_vars) > 0) {
      message("File '", file_name, "' is missing key variables: ", 
              paste(missing_vars, collapse = ", "))
    } else if (verbose >= 2) {
      message("File '", file_name, "' has all required key variables.")
    }
  }
  
  return(list(
    valid = length(missing_vars) == 0,
    missing = missing_vars,
    present = present_vars,
    error = NULL
  ))
}