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
#' @return A tibble containing either the full submission data or a summary based on the specified return value.
#'   - If return_value is "All", the tibble has the following columns:
#'     - id: The unique identifier for each submission.
#'     - submission_type: The type of submission.
#'     - answer: The answer or response corresponding to each submission.
#'   - If return_value is "Summary", the tibble has the following columns:
#'     - name: The value in the "information-name" column.
#'     - email: The value in the "information-email" column.
#'     - time: The value in the "download-answers" column.
#'     - answers: The number of rows in the submitted file.
#'
#' @examples
#' \dontrun{
#' # Process submissions in the "submissions" directory with filenames ending in ".html" and matching "project"
#' submission_data <- process_submissions("path/to/submissions", "project", return_value = "All")
#' print(submission_data)
#'
#' # Process submissions and return a summary
#' submission_summary <- process_submissions("path/to/submissions", "project")
#' print(submission_summary)
#' }
#'
#' @importFrom rvest read_html html_table
#' @importFrom tibble tibble as_tibble
#' @importFrom dplyr bind_rows filter pull
#' @importFrom purrr map_int
#' @export
process_submissions <- function(path, pattern, return_value = "Summary") {
  # Check if the directory exists
  if (!dir.exists(path)) {
    stop("The specified directory does not exist.")
  }
  
  # Get the list of all files in the directory
  all_files <- list.files(path, full.names = FALSE)
  
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
    
    # Read the HTML file
    html_content <- read_html(file_path)
    
    # Extract the table data from the HTML
    table_data <- html_table(html_content)[[1]]
    
    # Convert the extracted data to a tibble
    table_data <- as_tibble(table_data)
    
    # Append the extracted data to the submission_data_list
    submission_data_list[[file]] <- table_data
  }
  
  # If return_value is "Summary", process the submission data to create a summary
  if (return_value == "Summary") {
    submission_summary <- tibble(
      name = map_chr(submission_data_list, ~ pull(filter(., id == "information-name"), answer)),
      email = map_chr(submission_data_list, ~ pull(filter(., id == "information-email"), answer)),
      time = map_chr(submission_data_list, ~ pull(filter(., id == "download-answers"), answer)),
      answers = map_int(submission_data_list, ~ nrow(filter(., submission_type == "question")))
    )
    return(submission_summary)
  }
  
  # If return_value is "All", combine the submission data from all files into a single tibble
  submission_data <- bind_rows(submission_data_list)
  return(submission_data)
}