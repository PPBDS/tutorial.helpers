#' Match Questions by Pattern
#'
#' This function takes a single HTML file or tibble and finds all questions/answers
#' that contain a specified pattern. It returns the question IDs (from the 'id' column)
#' for rows where the answer contains the pattern.
#'
#' @param x Either a file path to an HTML file or a tibble with 'id' and 'answer'/'data' columns
#' @param pattern A character string to search for in the answers
#' @param ignore.case Logical; should the search be case-insensitive? (default: TRUE)
#'
#' @return A character vector of question IDs where the answer contains the pattern
#'
#' @examples
#' \dontrun{
#' # Search in an HTML file
#' question_ids <- match_questions("path/to/submission.html", "temperance")
#' # Returns: c("temperance-16", "temperance-19")
#'
#' # Search in a tibble
#'
#' path <- file.path(find.package("tutorial.helpers"), "tests/testthat/fixtures/answers_html")
#' 
#' tibble <- gather_submissions(path, title = "stop")[[1]]
#' 
#' result <- match_questions(tibble, "http")
#' }
#' @export
match_questions <- function(x, pattern, ignore.case = TRUE) {
  
  # Input validation
  if (missing(x) || is.null(x)) {
    stop("'x' must be provided (either a file path or tibble).")
  }
  
  if (missing(pattern) || is.null(pattern)) {
    stop("'pattern' must be provided.")
  }
  
  if (!is.logical(ignore.case) || length(ignore.case) != 1) {
    stop("'ignore.case' must be a single logical value (TRUE or FALSE).")
  }
  
  # Determine if x is a file path or tibble
  if (is.character(x) && length(x) == 1) {
    # x is a file path
    tibble_data <- read_html_file(x)
  } else if (is.data.frame(x)) {
    # x is already a tibble/data.frame
    tibble_data <- x
  } else {
    stop("'x' must be either a file path (character string) or a tibble/data.frame.")
  }
  
  # Validate tibble structure
  if (is.null(tibble_data)) {
    return(character(0))
  }
  
  if (!"id" %in% colnames(tibble_data)) {
    stop("The data must have an 'id' column.")
  }
  
  # Find the answer column (either 'answer' or 'data')
  answer_col <- NULL
  if ("answer" %in% colnames(tibble_data)) {
    answer_col <- "answer"
  } else if ("data" %in% colnames(tibble_data)) {
    answer_col <- "data"
  } else {
    stop("The data must have either an 'answer' or 'data' column.")
  }
  
  # Search for pattern in answers
  matching_rows <- grepl(pattern, tibble_data[[answer_col]], ignore.case = ignore.case)
  
  # Return the IDs for matching rows
  matching_ids <- tibble_data$id[matching_rows]
  
  # Convert to character vector and remove any NAs
  result <- as.character(matching_ids[!is.na(matching_ids)])
  
  return(result)
}

# Helper function to read HTML file
read_html_file <- function(file_path) {
  # Check if file exists
  if (!file.exists(file_path)) {
    stop("File does not exist: ", file_path)
  }
  
  # Check if rvest package is available
  if (!requireNamespace("rvest", quietly = TRUE)) {
    stop("Package 'rvest' is required. Please install it with: install.packages('rvest')")
  }
  
  # Check if tibble package is available
  if (!requireNamespace("tibble", quietly = TRUE)) {
    stop("Package 'tibble' is required. Please install it with: install.packages('tibble')")
  }
  
  # Read HTML content
  html_content <- tryCatch({
    rvest::read_html(file_path)
  }, error = function(e) {
    stop("Failed to read HTML file: ", e$message)
  })
  
  # Extract table data
  table_data <- tryCatch({
    tables <- rvest::html_table(html_content)
    if (length(tables) == 0) {
      return(NULL)
    }
    tables[[1]]
  }, error = function(e) {
    stop("Failed to extract table from HTML: ", e$message)
  })
  
  if (is.null(table_data) || nrow(table_data) == 0) {
    return(NULL)
  }
  
  # Convert to tibble
  tibble_data <- tryCatch({
    tibble::as_tibble(table_data)
  }, error = function(e) {
    stop("Failed to convert to tibble: ", e$message)
  })
  
  return(tibble_data)
}