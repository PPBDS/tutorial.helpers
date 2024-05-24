#' Process submissions from HTML files
#'
#' This function takes a directory path and a regular expression pattern as input and processes
#' the submission files in the specified directory whose filenames have the suffix ".html"
#' and match the given pattern. It extracts the relevant information from the HTML tables
#' and returns either the full submission data or a summary based on the specified return value.
#'
#' @param path A character string specifying the path to the directory containing the submission files.
#' @param pattern A character string representing the regular expression pattern to match against the filenames.
#' @param return_value A character string specifying the desired return value. "All" returns the full submission data,
#'                     and "Summary" (default) returns a summary with one row per processed file.
#'
#' @return A tibble containing either the full submission data or a summary based 
#'.        on the specified return value.
#'   - If return_value is "All", the tibble has the following columns:
#'     - id: The unique identifier for each submission.
#'     - submission_type: The type of submission.
#'     - answer: The answer or response corresponding to each submission.
#'   - If return_value is "Summary", the tibble has the following columns:
#'     - name: The value in the "information-name" column.
#'     - email: The value in the "information-email" column.
#'     - id: The value in the "information-id" column. This column is present only if at least one of the matching files in the directory has id information. If all files are missing id information, this column is omitted.
#'     - time: The value in the "download-answers" column.
#'     - answers: The number of rows in the submitted file.
#'
#' @examples
#' \dontrun{
#' process_submissions("path/to/submissions", "project", return_value = "All")
#' }
#'
#' @importFrom rvest read_html html_table
#' @importFrom tibble tibble as_tibble
#' @importFrom dplyr bind_rows filter pull
#' @importFrom purrr map_chr map_dbl imap_dfr
#' @export
process_submissions <- function(path, pattern, return_value = "Summary") {
  # Check if the directory exists
  if (!dir.exists(path)) {
    stop("The specified directory does not exist.")
  }
  
  # Get the list of all files in the directory
  all_files <- list.files(path, full.names = FALSE)
  
  # Check each file and issue a message for files without an ".html" suffix
  for (file in all_files) {
    if (!grepl("\\.html$", file)) {
      message("Could not process file: ", file)
    }
  }
  
  # Filter the files based on the ".html" suffix
  html_files <- grep("\\.html$", all_files, value = TRUE)
  
  # Filter the HTML files based on the provided pattern
  matching_files <- grep(pattern, html_files, value = TRUE)
  
  # Initialize an empty list to store the submission data for each file
  submission_data_list <- list()
  
  # Process each matching HTML file
  for (file in matching_files) {
    # Create the full file path by combining the directory path and file name
    file_path <- file.path(path, file)
    
    # Use tryCatch to handle errors
    submission_data <- tryCatch({
      # Read the HTML file
      html_content <- read_html(file_path)
      
      # Extract the table data from the HTML
      table_data <- html_table(html_content)[[1]]
    
    }, error = function(e) {
      # If an error occurs, print a message indicating the file could not be processed
      message("Could not process file: ", file)
      # Return NULL to indicate an error occurred
      return(NULL)
    })
    
    # Append the extracted data to the submission_data_list if no error occurred
    if (!is.null(submission_data)) {
      submission_data_list[[file]] <- submission_data
    }
  }
  
  # If return_value is "Summary", process the submission data to create a summary
  if (return_value == "Summary") {
    submission_summary <- imap_dfr(submission_data_list, ~ {
      file <- .y
      tryCatch({
        if (!(any(.x$id == "information-name") && any(.x$id == "information-email") && any(.x$id == "download-answers"))) {
          message("Could not process file: ", file)
          return(tibble(
            name = NA_character_,
            email = NA_character_,
            id = NA_character_,
            time = NA_character_,
            answers = NA_integer_
          ))
        }
        
        tibble(
          name = pull(filter(.x, id == "information-name"), answer),
          email = pull(filter(.x, id == "information-email"), answer),
          id = {
            id_value <- pull(filter(.x, id == "information-id"), answer)
            if (length(id_value) == 0) {
              NA_character_
            } else {
              id_value
            }
          },
          time = pull(filter(.x, id == "download-answers"), answer),
          answers = nrow(.x)
        )
      }, error = function(e) {
        message("Could not process file: ", file)
        return(tibble(
          name = NA_character_,
          email = NA_character_,
          id = NA_character_,
          time = NA_character_,
          answers = NA_integer_
        ))
      })
    })
    
    # Remove rows with NA values in all columns
    submission_summary <- submission_summary[rowSums(is.na(submission_summary)) != ncol(submission_summary), ]
    
    # Check if all values in the "id" column are NA
    if (all(is.na(submission_summary$id))) {
      # Remove the "id" column if all values are NA
      submission_summary$id <- NULL
    }
    
    return(submission_summary)
  }
  
  # If return_value is "All", combine the submission data from all files into a single tibble
  submission_data <- bind_rows(submission_data_list)
  return(submission_data)
}