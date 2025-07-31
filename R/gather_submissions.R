#' Find Submissions
#'
#' This function finds and reads HTML/XML files from a local directory or Google Drive folder that match specified patterns.
#' It extracts tables from the files and returns a list of tibbles.
#'
#' @param path The path to the local directory containing the HTML/XML files, or a Google Drive folder URL.
#'        If it's a Google Drive URL, the function will download the entire folder to a temporary directory.
#' @param title A character vector of patterns to match against the file names.
#'        Each pattern is processed separately and results are combined.
#' @param emails A character vector of email addresses to filter results by, "*" to include all emails, or NULL to skip email filtering (default: NULL).
#' @param verbose An integer specifying the verbosity level. 0: no messages, 1: file count messages, 2: some detailed messages about files, 3: detailed messages including all file problems (default: 0).
#'
#' @return A named list of tibbles, where each tibble contains the data from one HTML/XML file
#'         that matches any of the specified patterns and has valid table structure.
#'
#' @examples
#' \dontrun{
#' # Find submissions from local directory
#' tibble_list <- gather_submissions(path = "path/to/directory", title = ".")
#'
#' # Find submissions from Google Drive folder
#' drive_url <- "https://drive.google.com/drive/folders/your_folder_id"
#' tibble_list <- gather_submissions(
#'   path = drive_url, 
#'   title = c("getting", "get-to-know")
#' )
#'
#' # Find submissions with specific patterns and email filtering
#' tibble_list <- gather_submissions(
#'   path = "path/to/directory", 
#'   title = c("getting", "get-to-know"), 
#'   emails = c("user1@example.com", "user2@example.com")
#' )
#' 
#' # Find submissions including all emails (no email filtering)
#' tibble_list <- gather_submissions(
#'   path = "path/to/directory", 
#'   title = c("getting", "get-to-know"), 
#'   emails = "*"
#' )
#' }
#' @export

gather_submissions <- function(path, title, emails = NULL, verbose = 0) {
  
  # Input validation
  if (missing(path) || is.null(path)) {
    stop("'path' must be provided.")
  }
  
  if (missing(title) || is.null(title)) {
    stop("'title' must be provided.")
  }
  
  # Determine if path is a Google Drive URL or local directory
  is_drive_url <- grepl("^https?://", path)
  
  if (is_drive_url) {
    real_path <- handle_google_drive_url(path, title, verbose)
  } else {
    real_path <- handle_local_directory(path, verbose)
  }
  
  # Get all files in directory
  all_files <- list.files(real_path, full.names = FALSE, recursive = TRUE)
  
  if (verbose >= 1) {
    message("There are ", length(all_files), " files in the directory.")
  }
  
  # Filter HTML/XML files
  html_xml_files <- filter_html_xml_files(all_files, real_path, verbose)
  
  if (verbose >= 1) {
    message("There are ", length(html_xml_files), " HTML/XML files in the directory.")
  }
  
  # Filter by title patterns
  matching_files <- filter_by_title_patterns(html_xml_files, title, verbose)
  
  if (verbose >= 1) {
    message("There are ", length(matching_files), " HTML/XML files matching the pattern '", 
            paste(title, collapse = "|"), "'.")
  }
  
  # Process matching files
  tibble_list <- process_matching_files(matching_files, real_path, emails, verbose)
  
  # Final summary messages  
  valid_files_count <- length(tibble_list)
  
  if (verbose >= 1) {
    message("There were ", valid_files_count, " files with valid HTML tables.")
    # Count files that have usable data AND proper structure (id and answer columns)
    no_problems_count <- sum(sapply(tibble_list, function(x) {
      !is.null(x) && nrow(x) > 0 && 
      "id" %in% colnames(x) && "answer" %in% colnames(x)
    }))
    message("There were ", no_problems_count, " files with no problems.")
  }
  
  return(tibble_list)
}

# Handle Google Drive URL
handle_google_drive_url <- function(path, title, verbose) {
  if (verbose >= 1) {
    message("Detected Google Drive URL. Downloading entire folder...")
  }
  
  # Check if required packages are available
  if (!requireNamespace("googledrive", quietly = TRUE)) {
    stop("Package 'googledrive' is required for Google Drive functionality. ",
         "Please install it with: install.packages('googledrive')")
  }
  
  # Validate Google Drive link format
  if (!grepl("drive\\.google\\.com", path)) {
    stop("Invalid Google Drive link format.")
  }
  
  if (!grepl("/folders/", path)) {
    stop("Only Google Drive folder URLs are supported. ",
         "Please provide a folder URL in the format: ",
         "https://drive.google.com/drive/folders/FOLDER_ID")
  }
  
  # Use the existing download_google_drive function
  downloaded_path <- download_google_drive(url = path, path = NULL, title = title)
  
  # Validate that the download was successful
  if (is.null(downloaded_path) || !dir.exists(downloaded_path)) {
    stop("Google Drive download failed - no valid directory returned.")
  }
  
  if (verbose >= 1) {
    message("Google Drive folder successfully downloaded to: ", downloaded_path)
  }
  
  return(downloaded_path)
}

# Handle Local Directory
handle_local_directory <- function(path, verbose) {
  if (!dir.exists(path)) {
    stop("The specified directory does not exist: ", path)
  }
  
  return(normalizePath(path))
}

# Filter HTML/XML Files
filter_html_xml_files <- function(all_files, real_path, verbose) {
  if (length(all_files) == 0) {
    return(character(0))
  }
  
  # Check if mime package is available
  if (!requireNamespace("mime", quietly = TRUE)) {
    stop("Package 'mime' is required. Please install it with: install.packages('mime')")
  }
  
  full_file_paths <- file.path(real_path, all_files)
  
  html_xml_files <- sapply(full_file_paths, function(file) {
    if (!file.exists(file)) return(FALSE)
    
    # Check MIME type
    mime_type <- tryCatch({
      mime::guess_type(file)
    }, error = function(e) "")
    
    # Check both MIME type and extension
    grepl("html|xml", mime_type, ignore.case = TRUE) || 
      grepl("\\.(html?|xml)$", basename(file), ignore.case = TRUE)
  })
  
  html_xml_file_names <- all_files[html_xml_files]
  non_html_xml_file_names <- all_files[!html_xml_files]
  
  if (verbose >= 3 && length(non_html_xml_file_names) > 0) {
    if (!requireNamespace("utils", quietly = TRUE)) {
      stop("Package 'utils' is required. Please install it with: install.packages('utils')")
    }
    files_to_show <- utils::head(non_html_xml_file_names, 3)
    message("Removing file(s) '", paste(files_to_show, collapse = "', '"), 
           if(length(non_html_xml_file_names) > 3) "', ..." else "'", 
           " for not being HTML/XML.")
  }
  
  return(html_xml_file_names)
}

# Filter Files by Title Patterns
filter_by_title_patterns <- function(html_xml_files, title, verbose) {
  if (length(html_xml_files) == 0) {
    return(character(0))
  }
  
  all_matching_files <- character()
  
  for (current_title in title) {
    pattern_matches <- grep(current_title, html_xml_files, value = TRUE)
    all_matching_files <- c(all_matching_files, pattern_matches)
    
    if (verbose >= 2 && length(title) > 1) {
      message("Pattern '", current_title, "' matched ", length(pattern_matches), " files.")
    }
  }
  
  return(unique(all_matching_files))
}

# Process Matching Files
process_matching_files <- function(matching_files, real_path, emails, verbose) {
  if (length(matching_files) == 0) {
    return(list())
  }
  
  tibble_list <- list()
  processed_count <- 0
  
  for (file_name in matching_files) {
    result <- process_single_file(file_name, real_path, emails, verbose)
    
    if (!is.null(result)) {
      tibble_list[[file_name]] <- result
    }
    
    processed_count <- processed_count + 1
    
    # Progress indicator for large file sets
    if (verbose >= 2 && length(matching_files) > 10 && processed_count %% 5 == 0) {
      message("Processed ", processed_count, "/", length(matching_files), " files...")
    }
  }
  
  return(tibble_list)
}

# Process Single File
# @param file_name Name of the file to process
# @param real_path Base directory path
# @param emails Email filter
# @param verbose Verbosity level
# @return Tibble or NULL if processing failed
process_single_file <- function(file_name, real_path, emails, verbose) {
  file_path <- file.path(real_path, file_name)
  
  # Check if rvest package is available
  if (!requireNamespace("rvest", quietly = TRUE)) {
    stop("Package 'rvest' is required. Please install it with: install.packages('rvest')")
  }
  
  # Read HTML content
  html_content <- tryCatch({
    rvest::read_html(file_path)
  }, error = function(e) {
    if (verbose >= 3) {
      message("Failed to read HTML from: ", file_name, " - ", e$message)
    }
    return(NULL)
  })
  
  if (is.null(html_content)) {
    return(NULL)
  }
  
  # Extract table data
  table_data <- tryCatch({
    tables <- rvest::html_table(html_content)
    if (length(tables) == 0) {
      if (verbose >= 3) {
        message("No tables found in: ", file_name)
      }
      return(NULL)
    }
    tables[[1]]
  }, error = function(e) {
    if (verbose >= 3) {
      message("Failed to extract table from: ", file_name, " - ", e$message)
    }
    return(NULL)
  })
  
  if (is.null(table_data) || nrow(table_data) == 0) {
    if (verbose >= 3) {
      message("Empty or invalid table in: ", file_name)
    }
    return(NULL)
  }
  
  # Check if tibble package is available
  if (!requireNamespace("tibble", quietly = TRUE)) {
    stop("Package 'tibble' is required. Please install it with: install.packages('tibble')")
  }
  
  # Convert to tibble
  tibble_data <- tryCatch({
    tibble::as_tibble(table_data)
  }, error = function(e) {
    if (verbose >= 3) {
      message("Failed to convert to tibble: ", file_name, " - ", e$message)
    }
    return(NULL)
  })
  
  if (is.null(tibble_data)) {
    return(NULL)
  }
  
  # Apply email filtering if specified
  if (!is.null(emails) && !identical(emails, "*")) {
    tibble_data <- filter_by_email(tibble_data, emails, file_name, verbose)
  }
  
  return(tibble_data)
}

# Filter Tibble by Email
filter_by_email <- function(tibble_data, emails, file_name, verbose) {
  # Check if tibble has required structure for email filtering
  if (!("id" %in% colnames(tibble_data) && "answer" %in% colnames(tibble_data))) {
    if (verbose >= 3) {
      message("File '", file_name, "' lacks 'id' and 'answer' columns for email filtering. Skipping.")
    }
    return(NULL)
  }
  
  # Try multiple possible email field names
  email_fields <- c("email", "information-email", "Email", "e-mail", 
                   "Email Address", "email-address", "information_email")
  
  email_value <- NULL
  for (field_name in email_fields) {
    email_rows <- tibble_data[tibble_data$id == field_name, ]
    if (nrow(email_rows) > 0) {
      email_value <- email_rows$answer[1]
      break
    }
  }
  
  if (is.null(email_value)) {
    if (verbose >= 3) {
      message("No email field found in file '", file_name, "'. Skipping.")
    }
    return(NULL)
  }
  
  # Check if email matches filter
  if (!email_value %in% emails) {
    if (verbose >= 3) {
      message("Email '", email_value, "' in file '", file_name, "' does not match filter. Skipping.")
    }
    return(NULL)
  }
  
  return(tibble_data)
}