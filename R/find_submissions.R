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
#' @importFrom rvest read_html html_table
#' @importFrom tibble as_tibble
#' @importFrom mime guess_type
#' @importFrom utils download.file unzip head
#'
#' @examples
#' \dontrun{
#' # Find submissions from local directory
#' tibble_list <- find_submissions(path = "path/to/directory", title = ".")
#'
#' # Find submissions from Google Drive folder
#' drive_url <- "https://drive.google.com/drive/folders/your_folder_id"
#' tibble_list <- find_submissions(
#'   path = drive_url, 
#'   title = c("getting", "get-to-know")
#' )
#'
#' # Find submissions with specific patterns and email filtering
#' tibble_list <- find_submissions(
#'   path = "path/to/directory", 
#'   title = c("getting", "get-to-know"), 
#'   emails = c("user1@example.com", "user2@example.com")
#' )
#' 
#' # Find submissions including all emails (no email filtering)
#' tibble_list <- find_submissions(
#'   path = "path/to/directory", 
#'   title = c("getting", "get-to-know"), 
#'   emails = "*"
#' )
#' }
#' @export

find_submissions <- function(path, title, emails = NULL, verbose = 0) {
  
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
    real_path <- handle_google_drive_url(path, verbose)
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
# @param path Google Drive URL
# @param verbose Verbosity level
# @return Path to downloaded folder
handle_google_drive_url <- function(path, verbose) {
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
  
  # Extract folder ID and download
  folder_id <- extract_drive_folder_id(path)
  temp_dir <- tempdir(check = TRUE)
  folder_download_path <- file.path(temp_dir, paste0("drive_folder_", folder_id))
  
  # Check for cached folder
  if (dir.exists(folder_download_path)) {
    folder_age <- difftime(Sys.time(), file.info(folder_download_path)$mtime, units = "hours")
    if (folder_age < 1) {
      if (verbose >= 1) {
        message("Using cached Google Drive folder from: ", folder_download_path)
      }
      return(folder_download_path)
    } else {
      unlink(folder_download_path, recursive = TRUE)
    }
  }
  
  return(download_drive_folder(folder_id, folder_download_path, verbose))
}

# Handle Local Directory
# @param path Local directory path
# @param verbose Verbosity level
# @return Validated directory path
handle_local_directory <- function(path, verbose) {
  if (!dir.exists(path)) {
    stop("The specified directory does not exist: ", path)
  }
  
  return(normalizePath(path))
}

# Filter HTML/XML Files
# @param all_files Vector of all file names
# @param real_path Base directory path
# @param verbose Verbosity level
# @return Vector of HTML/XML file names
filter_html_xml_files <- function(all_files, real_path, verbose) {
  if (length(all_files) == 0) {
    return(character(0))
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
    files_to_show <- head(non_html_xml_file_names, 3)
    message("Removing file(s) '", paste(files_to_show, collapse = "', '"), 
           if(length(non_html_xml_file_names) > 3) "', ..." else "'", 
           " for not being HTML/XML.")
  }
  
  return(html_xml_file_names)
}

# Filter Files by Title Patterns
# @param html_xml_files Vector of HTML/XML file names
# @param title Vector of patterns to match
# @param verbose Verbosity level
# @return Vector of matching file names
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
# @param matching_files Vector of file names to process
# @param real_path Base directory path
# @param emails Email filter (NULL, "*", or vector of emails)
# @param verbose Verbosity level
# @return Named list of tibbles
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
# @param tibble_data The tibble to filter
# @param emails Vector of allowed emails
# @param file_name Name of source file (for messages)
# @param verbose Verbosity level
# @return Filtered tibble or NULL if no match
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

# Extract Google Drive Folder ID from URL
# @param drive_url The Google Drive URL
# @return The folder ID string
extract_drive_folder_id <- function(drive_url) {
  folder_id <- NULL
  
  if (grepl("/folders/", drive_url)) {
    # Standard folder URL
    folder_id <- regmatches(drive_url, regexpr("(?<=/folders/)[^/?]+", drive_url, perl = TRUE))
  } else if (grepl("id=", drive_url)) {
    # URL with id parameter
    folder_id <- regmatches(drive_url, regexpr("(?<=id=)[^&]+", drive_url, perl = TRUE))
  } else if (grepl("/open\\?id=", drive_url)) {
    # Open format
    folder_id <- regmatches(drive_url, regexpr("(?<=id=)[^&]+", drive_url, perl = TRUE))
  }
  
  if (is.null(folder_id) || length(folder_id) == 0) {
    stop("Unable to extract folder ID from Google Drive URL: ", drive_url)
  }
  
  return(folder_id)
}

# Download Google Drive Folder
# @param folder_id Google Drive folder ID
# @param folder_download_path Local path to download to
# @param verbose Verbosity level
# @return Path to downloaded folder
download_drive_folder <- function(folder_id, folder_download_path, verbose) {
  # Verify folder exists and is accessible
  tryCatch({
    folder_info <- googledrive::drive_get(googledrive::as_id(folder_id))
    
    if (nrow(folder_info) == 0) {
      stop("Google Drive folder not found or not accessible. ",
           "Please check the folder ID and sharing permissions.")
    }
    
    # Verify it's actually a folder
    if (folder_info$drive_resource[[1]]$mimeType != "application/vnd.google-apps.folder") {
      stop("The provided Google Drive URL does not point to a folder.")
    }
    
    if (verbose >= 2) {
      message("Confirmed Google Drive folder: ", folder_info$name)
    }
    
  }, error = function(e) {
    stop("Failed to verify Google Drive folder: ", e$message)
  })
  
  # Download the folder
  tryCatch({
    if (verbose >= 1) {
      message("Downloading Google Drive folder to temporary directory...")
    }
    
    # Create download directory
    dir.create(folder_download_path, recursive = TRUE, showWarnings = FALSE)
    
    # Get all files in the folder
    drive_files <- googledrive::drive_ls(googledrive::as_id(folder_id), recursive = TRUE)
    
    if (nrow(drive_files) == 0) {
      stop("No files found in the Google Drive folder.")
    }
    
    # Filter out folders, keep only files
    files_to_download <- drive_files[sapply(drive_files$drive_resource, function(x) {
      x$mimeType != "application/vnd.google-apps.folder"
    }), ]
    
    if (nrow(files_to_download) == 0) {
      stop("No downloadable files found in the Google Drive folder.")
    }
    
    if (verbose >= 1) {
      message("Downloading ", nrow(files_to_download), " files...")
    }
    
    # Download files
    for (i in seq_len(nrow(files_to_download))) {
      file_info <- files_to_download[i, ]
      local_path <- file.path(folder_download_path, file_info$name)
      
      # Create subdirectories if needed
      local_dir <- dirname(local_path)
      if (!dir.exists(local_dir)) {
        dir.create(local_dir, recursive = TRUE, showWarnings = FALSE)
      }
      
      if (verbose >= 3) {
        message("Downloading: ", file_info$name)
      }
      
      # Download with appropriate verbosity
      if (verbose < 3) {
        googledrive::with_drive_quiet(
          googledrive::drive_download(
            googledrive::as_id(file_info$id), 
            path = local_path, 
            overwrite = TRUE
          )
        )
      } else {
        googledrive::drive_download(
          googledrive::as_id(file_info$id), 
          path = local_path, 
          overwrite = TRUE
        )
      }
      
      # Progress indicator
      if (verbose >= 1 && nrow(files_to_download) > 10 && i %% 5 == 0) {
        message("Downloaded ", i, "/", nrow(files_to_download), " files...")
      }
    }
    
    if (verbose >= 1) {
      message("Google Drive folder successfully downloaded to: ", folder_download_path)
    }
    
    return(folder_download_path)
    
  }, error = function(e) {
    stop("Failed to download Google Drive folder: ", e$message)
  })
}