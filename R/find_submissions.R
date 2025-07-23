#' Find Submissions
#'
#' This function finds and reads HTML/XML files from a local directory or Google Drive folder that match specified patterns.
#' It extracts tables from the files and returns a list of tibbles.
#'
#' @param path The path to the local directory containing the HTML/XML files, or a Google Drive folder URL.
#'        If it's a Google Drive URL, the function will download individual files to a temporary directory.
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
#' @importFrom utils download.file unzip
#'
#' @examples
#' \dontrun{
#' # Find submissions from local directory
#' tibble_list <- find_submissions(path = "path/to/directory", title = ".")
#'
#' # Find submissions from Google Drive
#' tibble_list <- find_submissions(path = "https://drive.google.com/drive/folders/your_folder_id", title = c("getting", "get-to-know"))
#'
#' # Find submissions with specific patterns and email filtering
#' tibble_list <- find_submissions(path = "path/to/directory", title = c("getting", "get-to-know"), emails = c("user1@example.com", "user2@example.com"))
#' 
#' # Find submissions including all emails (no email filtering)
#' tibble_list <- find_submissions(path = "path/to/directory", title = c("getting", "get-to-know"), emails = "*")
#' }
#' @export

find_submissions <- function(path, title, emails = NULL, verbose = 0) {
  
  # Validation: path must be provided
  if (missing(path) || is.null(path)) {
    stop("'path' must be provided.")
  }
  
  # Determine if path is a Google Drive URL or local directory
  is_drive_url <- grepl("^https?://", path)
  
  if (is_drive_url) {
    # Handle Google Drive URL
    if (verbose >= 1) {
      message("Detected Google Drive URL. Accessing Google Drive folder...")
    }
    
    # Check if required packages are available for Google Drive functionality
    if (!requireNamespace("googledrive", quietly = TRUE)) {
      stop("Package 'googledrive' is required for Google Drive functionality. Please install it with: install.packages('googledrive')")
    }
    
    # Validate Google Drive link format
    if (!grepl("drive\\.google\\.com", path)) {
      stop("Invalid Google Drive link format.")
    }
    
    # Extract folder ID from Google Drive link
    folder_id <- extract_drive_folder_id(path)
    
    # Create temporary directory for downloaded files
    temp_dir <- file.path(tempdir(), paste0("drive_files_", as.numeric(Sys.time())))
    dir.create(temp_dir, recursive = TRUE)
    
    # Get list of files from Google Drive and download them
    tryCatch({
      drive_files <- googledrive::drive_ls(googledrive::as_id(folder_id))
      
      if (nrow(drive_files) == 0) {
        stop("No files found in the Google Drive folder or folder is not accessible.")
      }
      
      # Download each file to temp directory
      for (i in seq_len(nrow(drive_files))) {
        file_info <- drive_files[i, ]
        local_path <- file.path(temp_dir, file_info$name)
        
        if (verbose >= 2) {
          message("Downloading: ", file_info$name)
        }
        
        googledrive::drive_download(
          googledrive::as_id(file_info$id), 
          path = local_path, 
          overwrite = TRUE
        )
      }
      
      real_path <- temp_dir
      
      if (verbose >= 2) {
        message("Files downloaded to: ", real_path)
      }
      
    }, error = function(e) {
      stop("Failed to access Google Drive folder. Please check the link and ensure it's publicly accessible. Error: ", e$message)
    })
    
  } else {
    # Handle local directory
    if (!dir.exists(path)) {
      stop("The specified directory does not exist.")
    }
    real_path <- path
  }
  
  # Initialize list to store results from all patterns
  all_tibbles <- list()
  
  # Process each pattern
  for (current_title in title) {
    
    # Get list of files from the real path
    all_files <- list.files(real_path, full.names = FALSE)
    num_files <- length(all_files)
    
    if (verbose >= 1) {
      if (length(title) > 1) {
        message("Processing pattern '", current_title, "':")
      }
      message("There are ", num_files, " files in the directory.")
    }
    
    # Filter HTML/XML files
    full_file_paths <- file.path(real_path, all_files)
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
    
    matching_files <- grep(current_title, html_xml_file_names, value = TRUE)
    non_matching_files <- setdiff(html_xml_file_names, matching_files)
    
    if (verbose == 3 && length(non_matching_files) > 0) {
      message("Removing file(s) '", paste(non_matching_files, collapse = "', '"), "' for not matching the pattern '", current_title, "'.")
    }
    
    if (verbose >= 1) {
      message("There are ", length(matching_files), " HTML/XML files matching the pattern '", current_title, "'.")
    }
    
    tibble_list <- list()
    well_formed_files <- 0
    malformed_files <- character()
    
    for (file_name in matching_files) {
      # Process local file
      file_path <- file.path(real_path, file_name)
      html_content <- tryCatch({
        rvest::read_html(file_path)
      }, error = function(e) {
        malformed_files <<- c(malformed_files, file_name)
        return(NULL)
      })
      
      if (is.null(html_content)) {
        next
      }
      
      table_data <- tryCatch({
        rvest::html_table(html_content)[[1]]
      }, error = function(e) {
        malformed_files <<- c(malformed_files, file_name)
        return(NULL)
      })
      
      if (is.null(table_data)) {
        malformed_files <<- c(malformed_files, file_name)
        next
      }
      
      tibble_data <- tibble::as_tibble(table_data)
      
      # Filter by email if specified and not "*"
      if (!is.null(emails) && !identical(emails, "*")) {
        # Check if tibble has 'id' and 'answer' columns for email filtering
        if ("id" %in% colnames(tibble_data) && "answer" %in% colnames(tibble_data)) {
          # Try multiple possible email field names
          email_fields <- c("email", "information-email", "Email", "e-mail", 
                           "Email Address", "email-address", "information_email")
          email_row <- NULL
          found_email_field <- FALSE
          
          for (field_name in email_fields) {
            email_row <- tibble_data[tibble_data$id == field_name, ]
            if (nrow(email_row) > 0) {
              found_email_field <- TRUE
              if (verbose >= 3) {
                message("Found email field '", field_name, "' in file: ", file_name)
              }
              break  # Found email field
            }
          }
          
          if (found_email_field && nrow(email_row) > 0) {
            email_value <- email_row$answer[1]
            # Only keep this tibble if email matches one in the emails vector
            if (!email_value %in% emails) {
              if (verbose >= 3) {
                message("Email '", email_value, "' in file '", file_name, "' does not match any target emails. Skipping.")
              }
              next  # Skip this file
            } else {
              if (verbose >= 3) {
                message("Email '", email_value, "' in file '", file_name, "' matches target. Keeping file.")
              }
            }
          } else {
            # No email found in this file, skip it
            if (verbose >= 2) {
              message("No email field found in file: ", file_name, 
                     ". Available id values: ", paste(tibble_data$id, collapse = ", "))
            }
            next
          }
        } else {
          # No proper structure for email filtering, skip this file
          if (verbose >= 2) {
            message("File '", file_name, "' does not have proper 'id' and 'answer' columns for email filtering. Skipping.")
          }
          next
        }
      } else if (identical(emails, "*") && verbose >= 3) {
        # Special case: emails = "*" includes all files
        message("Including all emails (emails = '*'). Keeping file: ", file_name)
      }
      
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

#' Extract Google Drive Folder ID from URL
#'
#' Helper function to extract folder ID from various Google Drive URL formats
#'
#' @param drive_url The Google Drive URL
#' @return The folder ID string
extract_drive_folder_id <- function(drive_url) {
  # Handle different Google Drive URL formats
  if (grepl("/folders/", drive_url)) {
    # Standard folder URL: https://drive.google.com/drive/folders/FOLDER_ID
    folder_id <- regmatches(drive_url, regexpr("(?<=/folders/)[^/?]+", drive_url, perl = TRUE))
  } else if (grepl("id=", drive_url)) {
    # URL with id parameter: https://drive.google.com/drive/u/0/folders/FOLDER_ID?id=FOLDER_ID
    folder_id <- regmatches(drive_url, regexpr("(?<=id=)[^&]+", drive_url, perl = TRUE))
  } else if (grepl("/open\\?id=", drive_url)) {
    # Open format: https://drive.google.com/open?id=FOLDER_ID
    folder_id <- regmatches(drive_url, regexpr("(?<=id=)[^&]+", drive_url, perl = TRUE))
  } else {
    stop("Unable to extract folder ID from Google Drive URL. Please check the URL format.")
  }
  
  if (length(folder_id) == 0) {
    stop("Unable to extract folder ID from Google Drive URL.")
  }
  
  return(folder_id)
}