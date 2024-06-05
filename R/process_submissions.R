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
#' @param verbose An integer specifying the verbosity level. 0: no messages, 1: file count messages, 2: some detailed messages about files, 3: detailed messages including all file problems (default: 0).
#' @param keep_file_name Specifies whether to keep the file name in the summary tibble. Allowed values are NULL (default), "All" (keep entire file name), "Space" (keep up to first space), or "Underscore" (keep up to first underscore). Only used when `return_value` is "Summary".
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
#' # Process submissions with verbose output (level 3)
#' process_submissions("path/to/directory", verbose = 3)
#'
#' # Process submissions and keep the entire file name in the summary tibble
#' process_submissions("path/to/directory", return_value = "Summary", keep_file_name = "All")
#' }
#' @export

process_submissions <- function(path, 
                                pattern = ".", 
                                return_value = "Summary", 
                                key_vars = NULL, 
                                verbose = 0, 
                                keep_file_name = NULL) {
  
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
  
  if (!is.null(keep_file_name) && return_value != "Summary") {
    stop("keep_file_name can only be used when return_value is 'Summary'.")
  }
  
  if (!is.null(keep_file_name) && !(keep_file_name %in% c("All", "Space", "Underscore"))) {
    stop("Invalid keep_file_name. Allowed values are NULL, 'All', 'Space', or 'Underscore'.")
  }
  
  # Get the list of all files in the directory
  all_files <- list.files(path, full.names = FALSE)
  num_files <- length(all_files)
  
  if (verbose >= 1) {
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
  
  matching_files <- grep(pattern, html_xml_file_names, value = TRUE)
  non_matching_files <- setdiff(html_xml_file_names, matching_files)
  
  if (verbose == 3 && length(non_matching_files) > 0) {
    message("Removing file(s) '", paste(non_matching_files, collapse = "', '"), "' for not matching the pattern '", pattern, "'.")
  }
  
  if (verbose >= 1) {
    message("There are ", length(matching_files), " HTML/XML files matching the pattern '", pattern, "'.")
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
  
  filtered_tibble_list <- list()
  removed_files <- character()
  missing_key_vars_files <- character()
  
  for (file_name in names(tibble_list)) {
    tibble_data <- tibble_list[[file_name]]
    
    if (!"id" %in% colnames(tibble_data)) {
      if (verbose == 2) {
        message("File '", file_name, "' does not have an 'id' column. Removing from list.")
      }
      removed_files <- c(removed_files, file_name)
    } else if (!is.null(key_vars) && !all(key_vars %in% tibble_data$id)) {
      missing_key_vars_files <- c(missing_key_vars_files, file_name)
      removed_files <- c(removed_files, file_name)
    } else {
      for (key_var in key_vars) {
        key_var_value <- tibble_data$answer[tibble_data$id == key_var]
        tibble_data[[key_var]] <- key_var_value
      }
      filtered_tibble_list[[file_name]] <- tibble_data
    }
  }
  
  if (verbose >= 2 && length(missing_key_vars_files) > 0) {
    message("Removing file(s) '", paste(missing_key_vars_files, collapse = "', '"), "' due to missing key variables.")
  }
  
  if (verbose >= 1) {
    message("There were ", length(filtered_tibble_list), " files with no problems.")
  }
  
  if (return_value == "Summary") {
    if (length(filtered_tibble_list) > 0) {
      summary_tibble <- purrr::map_dfr(names(filtered_tibble_list), function(file_name) {
        tibble_data <- filtered_tibble_list[[file_name]]
        answers <- nrow(tibble_data)
        
        if (!is.null(keep_file_name)) {
          if (keep_file_name == "All") {
            source_name <- file_name
          } else if (keep_file_name == "Space") {
            source_name <- sub("\\s.*", "", file_name)
          } else if (keep_file_name == "Underscore") {
            source_name <- sub("_.*", "", file_name)
          }
        } else {
          source_name <- NULL
        }
        
        summary_row <- dplyr::slice(tibble_data, 1) |>
          dplyr::select(all_of(key_vars)) |>
          dplyr::mutate(answers = answers)
        
        if (!is.null(source_name)) {
          summary_row <- tibble::add_column(summary_row, source = source_name, .before = 1)
        }
        
        summary_row
      })
      return(summary_tibble)
    } else {
      return(tibble::tibble())
    }
  }
  else if (return_value == "All") {
    if (length(filtered_tibble_list) > 0) {
      all_tibble <- dplyr::bind_rows(filtered_tibble_list)
      return(all_tibble)
    } else {
      return(tibble::tibble())
    }
  }
}