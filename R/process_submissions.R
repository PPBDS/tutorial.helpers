#' Process Submissions
#'
#' This function processes submissions from a directory containing HTML/XML files.
#' It extracts tables from the files, filters them based on a pattern and key variables,
#' and returns either a summary tibble or a combined tibble with all the data.
#'
#' @param path The path to the directory containing the HTML/XML files.
#' @param pattern The pattern to match against the file names (default: ".").
#' @param return_value The type of value to return. Allowed values are "Summary" (default) or "All".
#' @param key_vars A character vector of key variables to extract from the "id" column (default: NULL).
#' @param verbose An integer specifying the verbosity level. 0: no messages, 1: file count messages, 2: detailed messages (default: 0).
#'
#' @return If `return_value` is "Summary", returns a tibble with one row for each file, columns corresponding to the `key_vars`,
#'         and an additional "answers" column indicating the number of rows in each tibble.
#'         If `return_value` is "All", returns a tibble with all the data combined from all the files.
#'
#' @importFrom dplyr select slice mutate bind_rows all_of
#' @importFrom purrr map_dfr
#' @importFrom rvest read_html html_table
#' @importFrom tibble as_tibble tibble
#' @importFrom mime guess_type
#'
#' @examples
#' \dontrun{
#' # Process submissions with default settings
#' process_submissions("path/to/directory")
#'
#' # Process submissions with a specific pattern and key variables
#' process_submissions("path/to/directory", pattern = "^submission", key_vars = c("name", "email"))
#'
#' # Process submissions and return all data
#' process_submissions("path/to/directory", return_value = "All")
#'
#' # Process submissions with verbose output
#' process_submissions("path/to/directory", verbose = 2)
#' }

process_submissions <- function(path, pattern = ".", return_value = "Summary", key_vars = NULL, verbose = 0) {
  
  # Check if the directory exists
  if (!dir.exists(path)) {
    stop("The specified directory does not exist.")
  }
  
  # Check if return_value is valid
  if (!(return_value %in% c("Summary", "All"))) {
    stop("Invalid return_value. Allowed values are 'Summary' or 'All'.")
  }
  
  # Check if key_vars is provided when return_value is "Summary"
  if (return_value == "Summary" && is.null(key_vars)) {
    stop("key_vars must be provided when return_value is 'Summary'.")
  }
  
  # Get the list of all files in the directory
  all_files <- list.files(path, full.names = FALSE)
  
  # Count the number of files in the directory
  num_files <- length(all_files)
  
  # Print a message reporting the number of files if verbose is 1 or 2
  if (verbose >= 1) {
    message("There are ", num_files, " files in the directory.")
  }
  
  # Construct the full file paths
  full_file_paths <- file.path(path, all_files)
  
  # Check which files are HTML/XML files
  html_xml_files <- sapply(full_file_paths, function(file) {
    mime_type <- mime::guess_type(file)
    grepl("html|xml", mime_type, ignore.case = TRUE)
  })
  
  # Get the names of HTML/XML files
  html_xml_file_names <- all_files[html_xml_files]
  
  # Get the names of non-HTML/XML files
  non_html_xml_file_names <- all_files[!html_xml_files]
  
  # Print the names of non-HTML/XML files if verbose is 2
  if (verbose == 2 && length(non_html_xml_file_names) > 0) {
    message("Removing file(s) '", paste(non_html_xml_file_names, collapse = "', '"), "' for not being HTML.")
  }
  
  # Print a message reporting the number of HTML/XML files if verbose is 1 or 2
  if (verbose >= 1) {
    message("There are ", length(html_xml_file_names), " HTML/XML files in the directory.")
  }
  
  # Check which HTML/XML files match the provided pattern
  matching_files <- grep(pattern, html_xml_file_names, value = TRUE)
  non_matching_files <- setdiff(html_xml_file_names, matching_files)
  
  # Print the names of non-matching files if verbose is 2
  if (verbose == 2 && length(non_matching_files) > 0) {
    message("Removing file(s) '", paste(non_matching_files, collapse = "', '"), "' for not matching the pattern '", pattern, "'.")
  }
  
  # Print a message reporting the number of matching files if verbose is 1 or 2
  if (verbose >= 1) {
    message("There are ", length(matching_files), " HTML/XML files matching the pattern '", pattern, "'.")
  }
  
  # Construct the full file paths for the matching files
  matching_file_paths <- file.path(path, matching_files)
  
  # Initialize an empty list to store the tibbles
  tibble_list <- list()
  
  # Initialize a counter for well-formed HTML files
  well_formed_files <- 0
  
  # Loop through each matching HTML file
  for (file in matching_file_paths) {
    # Read the HTML content
    html_content <- rvest::read_html(file)
    
    # Extract the table from the HTML content
    table_data <- tryCatch(
      {
        rvest::html_table(html_content)[[1]]
      },
      error = function(e) {
        if (verbose == 2) {
          message("File '", basename(file), "' has malformed HTML or does not contain a valid table.")
        }
        return(NULL)
      }
    )
    
    # If table_data is NULL, skip to the next iteration
    if (is.null(table_data)) {
      next
    }
    
    # Convert the table data into a tibble
    tibble_data <- tibble::as_tibble(table_data)
    
    # Get the file name without the path
    file_name <- basename(file)
    
    # Store the tibble in the list with the file name as the element name
    tibble_list[[file_name]] <- tibble_data
    
    # Increment the counter for well-formed HTML files
    well_formed_files <- well_formed_files + 1
  }
  
  # Print a message indicating the number of well-formed HTML files if verbose is 1 or 2
  if (verbose >= 1) {
    message("There were ", well_formed_files, " files with valid HTML tables.")
  }
  
  # Process each tibble in the list
  filtered_tibble_list <- tibble_list  # Create a copy of the original list
  removed_files <- character()  # Initialize an empty vector to store removed file names
  missing_key_vars_files <- character()  # Initialize an empty vector to store files with missing key variables
  
  for (file_name in names(tibble_list)) {
    tibble_data <- tibble_list[[file_name]]
    
    # Check if the tibble has an "id" column
    if (!"id" %in% colnames(tibble_data)) {
      if (verbose == 2) {
        message("File '", file_name, "' does not have an 'id' column.")
        message("Removing file '", file_name, "' from the list.")
      }
      filtered_tibble_list[[file_name]] <- NULL  # Remove the element from the filtered list
      removed_files <- c(removed_files, file_name)  # Add the file name to the removed files vector
    } else if (!is.null(key_vars) && !all(key_vars %in% tibble_data$id)) {
      missing_key_vars_files <- c(missing_key_vars_files, file_name)  # Add the file name to the missing key variables files vector
      filtered_tibble_list[[file_name]] <- NULL  # Remove the element from the filtered list
      removed_files <- c(removed_files, file_name)  # Add the file name to the removed files vector
    } else {
      # Add new columns based on key_vars
      for (key_var in key_vars) {
        key_var_value <- tibble_data$answer[tibble_data$id == key_var]
        tibble_data[[key_var]] <- key_var_value
      }
      
      # Update the tibble in the filtered list
      filtered_tibble_list[[file_name]] <- tibble_data
    }
  }
  
  # Print the names of files with missing key variables if verbose is 2
  if (verbose == 2 && length(missing_key_vars_files) > 0) {
    message("Removing file(s) '", paste(missing_key_vars_files, collapse = "', '"), "' from the list due to missing key variables.")
  }
  
  # Print a message indicating the number of files with no problems if verbose is 1 or 2
  if (verbose >= 1) {
    message("There were ", length(filtered_tibble_list), " files with no problems.")
  }
  
  # Return the result based on the return_value parameter
  if (return_value == "Summary") {
    if (length(filtered_tibble_list) > 0) {
      # Calculate the number of rows in each tibble and create a summary tibble
      summary_tibble <- purrr::map_dfr(filtered_tibble_list, function(tibble_data) {
        answers <- nrow(tibble_data)
        dplyr::slice(tibble_data, 1) |>
          dplyr::select(all_of(key_vars)) |>
          dplyr::mutate(answers = answers)
      })
      return(summary_tibble)
    } else {
      return(tibble())
    }
  } else if (return_value == "All") {
    if (length(filtered_tibble_list) > 0) {
      all_tibble <- dplyr::bind_rows(filtered_tibble_list)
      return(all_tibble)
    } else {
      return(tibble())
    }
  }
}