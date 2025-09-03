#' Display the contents of a text file that match a pattern
#'
#' This function reads the contents of a text file and either prints the specified range of rows
#' that match a given regular expression pattern, prints the code lines within R code chunks,
#' or extracts the YAML header. If start is a negative number, it prints the last abs(start) lines,
#' ignoring missing lines at the end of the file. If start is 0, it prints the entire file.
#'
#' @param path A character vector representing the path to the text file.
#' @param start An integer specifying the starting row number (inclusive) to consider. Default is 1.
#'              If negative, it represents the number of lines to print from the end of the file.
#'              If 0, prints the entire file.
#' @param end An integer specifying the ending row number (inclusive) to consider. Default is the last row.
#' @param pattern A regular expression pattern to match against each row. Default is NULL (no pattern matching).
#' @param chunk A character string indicating what content to extract. 
#'              Possible values are "None" (default - no chunk processing),
#'              "All" (print all R code chunks), "Last" (print only the last R code chunk),
#'              or "YAML" (extract the YAML header without delimiters).
#' @return The function prints the contents of the specified range of rows that match the pattern (if provided),
#'         the code lines within R code chunks (if chunk is "All" or "Last"),
#'         or the YAML header content (if chunk is "YAML") to the console. If no rows match the pattern,
#'         nothing is printed. If start is negative, the function prints the last abs(start) lines, ignoring
#'         missing lines at the end of the file. If start is 0, the function prints the entire file.
#'
#' @examples
#' \dontrun{
#' # Display all rows of a text file
#' show_file("path/to/your/file.txt")
#'
#' # Display the entire file
#' show_file("path/to/your/file.txt", start = 0)
#'
#' # Display rows 5 to 10 of a text file
#' show_file("path/to/your/file.txt", start = 5, end = 10)
#'
#' # Display all rows of a text file that contain the word "example"
#' show_file("path/to/your/file.txt", pattern = "example")
#'
#' # Print all code lines within R code chunks
#' show_file("path/to/your/file.txt", chunk = "All")
#'
#' # Print only the last R code chunk
#' show_file("path/to/your/file.txt", chunk = "Last")
#'
#' # Extract the YAML header
#' show_file("path/to/your/file.Rmd", chunk = "YAML")
#'
#' # Display the last 5 lines of a text file, ignoring missing lines at the end
#' show_file("path/to/your/file.txt", start = -5)
#' }
#'
#' @importFrom utils tail
#'
#' @export

show_file <- function(path, start = 1, end = NULL, pattern = NULL, chunk = "None") {
  # Check if the file exists
  if (!file.exists(path)) {
    stop("File does not exist.")
  }
  
  # Validate chunk parameter
  allowed_chunks <- c("None", "All", "Last", "YAML")
  if (!chunk %in% allowed_chunks) {
    stop("chunk must be one of: ", paste(allowed_chunks, collapse = ", "))
  }
  
  # Read the contents of the file
  contents <- readLines(path)
  
  # Remove trailing empty lines from the contents
  while (length(contents) > 0 && contents[length(contents)] == "") {
    contents <- contents[-length(contents)]
  }
  
  # If chunk is "YAML", extract and return the YAML header
  if (chunk == "YAML") {
    if (length(contents) == 0 || !grepl("^---\\s*$", contents[1])) {
      stop("No YAML header found.")
    }
    
    # Find the closing --- for the YAML header
    yaml_end <- NULL
    for (i in 2:length(contents)) {
      if (grepl("^---\\s*$", contents[i])) {
        yaml_end <- i
        break
      }
    }
    
    if (is.null(yaml_end)) {
      stop("No YAML header found.")
    }
    
    # Extract YAML content (excluding the --- delimiters)
    if (yaml_end > 2) {
      yaml_content <- contents[2:(yaml_end - 1)]
      cat(yaml_content, sep = "\n")
    }
    return(invisible(NULL))
  }
  
  # If start is 0, print the entire file
  if (start == 0) {
    cat(contents, sep = "\n")
    return(invisible(NULL))
  }
  
  # If start is negative, print the last abs(start) lines
  if (start < 0) {
    selected_contents <- tail(contents, abs(start))
    cat(selected_contents, sep = "\n")
    return(invisible(NULL))
  }
  
  # If chunk is "All" or "Last", print code lines within R code chunks
  if (chunk %in% c("All", "Last")) {
    in_chunk <- FALSE
    code_chunks <- list()
    current_chunk <- character()
    
    for (line in contents) {
      if (grepl("^```\\{r", line)) {
        in_chunk <- TRUE
        if (length(current_chunk) > 0) {
          code_chunks <- c(code_chunks, list(current_chunk))
          current_chunk <- character()
        }
      } else if (grepl("^```$", line)) {
        in_chunk <- FALSE
        if (length(current_chunk) > 0) {
          code_chunks <- c(code_chunks, list(current_chunk))
          current_chunk <- character()
        }
      } else if (in_chunk) {
        current_chunk <- c(current_chunk, line)
      }
    }
    
    if (chunk == "All") {
      for (i in seq_along(code_chunks)) {
        cat(code_chunks[[i]], sep = "\n")
        if (i < length(code_chunks)) {
          cat("\n")
        }
      }
    } else if (chunk == "Last") {
      if (length(code_chunks) > 0) {
        cat(code_chunks[[length(code_chunks)]], sep = "\n")
      }
    }
    return(invisible(NULL))
  }
  
  # Get the total number of rows
  total_rows <- length(contents)
  
  # Set default value for end if not provided
  if (is.null(end)) {
    end <- total_rows
  }
  
  # Check if start and end are within the valid range
  if (start < 1 || start > total_rows || end < 1 || end > total_rows) {
    stop("start and end must be within the valid range of rows.")
  }
  
  # Check if start is smaller or equal to end
  if (start > end) {
    stop("start must be smaller or equal to end.")
  }
  
  # Extract the specified range of rows
  selected_contents <- contents[start:end]
  
  # Filter the selected rows based on the pattern (if provided)
  if (!is.null(pattern)) {
    selected_contents <- selected_contents[grepl(pattern, selected_contents)]
  }
  
  # Print the selected contents to the console if there are matching rows
  if (length(selected_contents) > 0) {
    cat(selected_contents, sep = "\n")
  }
}