#' Extract Answers from List of Tibbles
#'
#' This function takes a list of tibbles and extracts specified questions/variables,
#' returning a tibble with one row per input tibble and one column per question.
#' Missing questions result in NA values.
#'
#' @param tibble_list A named list of tibbles, each containing "id" and "answer" columns
#' @param questions A character vector of questions/variables to extract
#' @param keep_file_name How to handle file names: NULL (don't include), "All" (full name),
#'        "Space" (up to first space), "Underscore" (up to first underscore)
#'
#' @return A tibble with one row per input tibble, columns for each question,
#'         optionally a "source" column, and an "answers" column with row counts
#'
#' @importFrom dplyr mutate select
#' @importFrom tibble tibble as_tibble add_column
#' @importFrom purrr map_dfr
#'
#' @examples
#' \dontrun{
#' # Extract email and age from list of tibbles
#' result <- submissions_answers(my_tibble_list, c("email", "age"))
#'
#' # Include source file names
#' result <- submissions_answers(my_tibble_list, c("email", "age"), keep_file_name = "All")
#' }
#' @export
submissions_answers <- function(tibble_list, questions, keep_file_name = NULL) {
  
  if (length(tibble_list) == 0) {
    return(tibble::tibble())
  }
  
  # Validate keep_file_name parameter
  if (!is.null(keep_file_name) && !(keep_file_name %in% c("All", "Space", "Underscore"))) {
    stop("Invalid keep_file_name. Allowed values are NULL, 'All', 'Space', or 'Underscore'.")
  }
  
  # Process each tibble in the list
  result <- purrr::map_dfr(names(tibble_list), function(file_name) {
    tibble_data <- tibble_list[[file_name]]
    
    # Create base row with source information if requested
    if (!is.null(keep_file_name)) {
      if (keep_file_name == "All") {
        source_name <- file_name
      } else if (keep_file_name == "Space") {
        source_name <- sub("\\s.*", "", file_name)
      } else if (keep_file_name == "Underscore") {
        source_name <- sub("_.*", "", file_name)
      }
    }
    
    # Initialize result row
    row_data <- list()
    
    # Add source column if requested
    if (!is.null(keep_file_name)) {
      row_data[["source"]] <- source_name
    }
    
    # Extract each question
    for (question in questions) {
      if ("id" %in% colnames(tibble_data) && question %in% tibble_data$id) {
        # Get the answer for this question
        answer_value <- tibble_data$answer[tibble_data$id == question]
        # Take first answer if multiple exist
        row_data[[question]] <- if (length(answer_value) > 0) answer_value[1] else NA
      } else {
        # Question not found, set to NA
        row_data[[question]] <- NA
      }
    }
    
    # Add count of total answers in this tibble
    row_data[["answers"]] <- nrow(tibble_data)
    
    # Convert to tibble
    tibble::as_tibble(row_data)
  })
  
  return(result)
}