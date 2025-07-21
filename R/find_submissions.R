#' Find Submissions
#'
#' This function finds and reads HTML/XML files from a directory that match specified patterns.
#' It extracts tables from the files and returns a list of tibbles.
#'
#' @param path The path to the directory containing the HTML/XML files.
#' @param pattern A character vector of patterns to match against the file names.
#'        Each pattern is processed separately and results are combined.
#' @param verbose An integer specifying the verbosity level. 0: no messages, 1: file count messages, 2: some detailed messages about files, 3: detailed messages including all file problems (default: 0).
#'
#' @return A named list of tibbles, where each tibble contains the data from one HTML/XML file
#'         that matches any of the specified patterns and has valid table structure.
#'
#' @importFrom rvest read_html html_table
#' @importFrom tibble as_tibble
#' @importFrom mime guess_type
#'
#' @examples
#' \dontrun{
#' # Find submissions with default pattern
#' tibble_list <- find_submissions("path/to/directory", pattern = ".")
#'
#' # Find submissions with specific patterns
#' tibble_list <- find_submissions("path/to/directory", pattern = c("getting", "get-to-know"))
#' }
#' @export

find_submissions <- function(path, pattern, verbose = 0) {
  
  # Check if the directory exists
  if (!dir.exists(path)) {
    stop("The specified directory does not exist.")
  }
  
  # Initialize list to store results from all patterns
  all_tibbles <- list()
  
  # Process each pattern
  for (current_pattern in pattern) {
    
    # Get the list of all files in the directory
    all_files <- list.files(path, full.names = FALSE)
    num_files <- length(all_files)
    
    if (verbose >= 1) {
      if (length(pattern) > 1) {
        message("Processing pattern '", current_pattern, "':")
      }
      message("There are ", num_files, " files in the directory.")
    }
    
    full_file_paths <- file.path(path, all_files)
    html_xml_files <- sapply(full_file_paths, function(file) {
      mime_type <- mime::guess_type(file)
      grepl("html|xml", mime_type, ignore.case = TRUE)
    })
    
    html_xml_file_names <- all_files[html_xml_files]
    non_html_xml_file_names <- all_files[!html_xml_files]
    
    if (verbose == 3 && length(non_html_xml_file_names) > 0) {
      message("Removing file(s) '", paste(non_html_xml_file_names, collapse = "', '"), "' for not being HTML/XML.")
    }
    
    if (verbose >= 1) {
      message("There are ", length(html_xml_file_names), " HTML/XML files in the directory.")
    }
    
    matching_files <- grep(current_pattern, html_xml_file_names, value = TRUE)
    non_matching_files <- setdiff(html_xml_file_names, matching_files)
    
    if (verbose == 3 && length(non_matching_files) > 0) {
      message("Removing file(s) '", paste(non_matching_files, collapse = "', '"), "' for not matching the pattern '", current_pattern, "'.")
    }
    
    if (verbose >= 1) {
      message("There are ", length(matching_files), " HTML/XML files matching the pattern '", current_pattern, "'.")
    }
    
    matching_file_paths <- file.path(path, matching_files)
    tibble_list <- list()
    well_formed_files <- 0
    malformed_files <- character()
    
    for (file in matching_file_paths) {
      html_content <- tryCatch(
        {
          rvest::read_html(file)
        },
        error = function(e) {
          malformed_files <- c(malformed_files, basename(file))
          return(NULL)
        }
      )
      
      if (is.null(html_content)) {
        next
      }
      
      table_data <- tryCatch(
        {
          rvest::html_table(html_content)[[1]]
        },
        error = function(e) {
          malformed_files <- c(malformed_files, basename(file))
          return(NULL)
        }
      )
      
      if (is.null(table_data)) {
        malformed_files <- c(malformed_files, basename(file))
        next
      }
      
      tibble_data <- tibble::as_tibble(table_data)
      file_name <- basename(file)
      tibble_list[[file_name]] <- tibble_data
      well_formed_files <- well_formed_files + 1
    }
    
    if (verbose >= 2 && length(malformed_files) > 0) {
      message("Removing file(s) '", paste(malformed_files, collapse = "', '"), "' due to invalid table structure.")
    }
    
    if (verbose >= 1) {
      message("There were ", well_formed_files, " files with valid HTML tables.")
    }
    
    # Add tibbles from this pattern to the overall list
    all_tibbles <- c(all_tibbles, tibble_list)
  }
  
  return(all_tibbles)
}