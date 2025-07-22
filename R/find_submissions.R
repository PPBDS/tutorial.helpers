#' Find Submissions
#'
#' This function finds and reads HTML/XML files from a directory or Google Drive folder that match specified patterns.
#' It extracts tables from the files and returns a list of tibbles.
#'
#' @param path The path to the local directory containing the HTML/XML files. Cannot be used together with drive.
#' @param drive A public Google Drive folder link to access files online. Cannot be used together with path.
#' @param title A character vector of patterns to match against the file names.
#'        Each pattern is processed separately and results are combined.
#' @param emails A character vector of email addresses to filter results by, or "*" to match all (default: "*").
#' @param verbose An integer specifying the verbosity level. 0: no messages, 1: file count messages, 2: some detailed messages about files, 3: detailed messages including all file problems (default: 0).
#'
#' @return A named list of tibbles, where each tibble contains the data from one HTML/XML file
#'         that matches any of the specified patterns and has valid table structure.
#'
#' @importFrom rvest read_html html_table
#' @importFrom tibble as_tibble
#' @importFrom mime guess_type
#' @importFrom googledrive drive_ls drive_download as_id
#' @importFrom httr GET content
#'
#' @examples
#' \dontrun{
#' # Find submissions from local directory
#' tibble_list <- find_submissions(path = "path/to/directory", title = ".")
#'
#' # Find submissions from Google Drive
#' tibble_list <- find_submissions(drive = "https://drive.google.com/drive/folders/your_folder_id", title = c("getting", "get-to-know"))
#'
#' # Find submissions with specific patterns and email filtering
#' tibble_list <- find_submissions(path = "path/to/directory", title = c("getting", "get-to-know"), emails = c("user1@example.com", "user2@example.com"))
#' }
#' @export

find_submissions <- function(path = NULL, drive = NULL, title, emails = "*", verbose = 0) {
  
  # Validation: path and drive cannot both be NULL or both be non-NULL
  if (is.null(path) && is.null(drive)) {
    stop("Either 'path' or 'drive' must be provided, but not both.")
  }
  
  if (!is.null(path) && !is.null(drive)) {
    stop("Only one of 'path' or 'drive' can be provided, not both.")
  }
  
  # Check if using local directory
  if (!is.null(path)) {
    if (!dir.exists(path)) {
      stop("The specified directory does not exist.")
    }
    use_drive <- FALSE
  } else {
    use_drive <- TRUE
    # Validate Google Drive link format
    if (!grepl("drive\\.google\\.com", drive)) {
      stop("Invalid Google Drive link format.")
    }
  }
  
  # Initialize list to store results from all patterns
  all_tibbles <- list()
  
  # Process each pattern
  for (current_title in title) {
    
    if (use_drive) {
      # Google Drive processing
      if (verbose >= 1) {
        if (length(title) > 1) {
          message("Processing pattern '", current_title, "' from Google Drive:")
        }
        message("Accessing Google Drive folder...")
      }
      
      # Extract folder ID from Google Drive link
      folder_id <- extract_drive_folder_id(drive)
      
      # Get list of files from Google Drive
      tryCatch({
        drive_files <- googledrive::drive_ls(googledrive::as_id(folder_id))
        all_files <- drive_files$name
        num_files <- length(all_files)
      }, error = function(e) {
        stop("Failed to access Google Drive folder. Please check the link and ensure it's publicly accessible. Error: ", e$message)
      })
      
    } else {
      # Local directory processing
      all_files <- list.files(path, full.names = FALSE)
      num_files <- length(all_files)
    }
    
    if (verbose >= 1) {
      if (length(title) > 1) {
        message("Processing pattern '", current_title, "':")
      }
      message("There are ", num_files, " files in the ", ifelse(use_drive, "Google Drive folder", "directory"), ".")
    }
    
    if (use_drive) {
      # Filter HTML/XML files for Google Drive
      html_xml_files <- sapply(all_files, function(file) {
        # Check file extension for HTML/XML
        grepl("\\.(html|htm|xml)$", file, ignore.case = TRUE)
      })
    } else {
      # Filter HTML/XML files for local directory
      full_file_paths <- file.path(path, all_files)
      html_xml_files <- sapply(full_file_paths, function(file) {
        mime_type <- mime::guess_type(file)
        grepl("html|xml", mime_type, ignore.case = TRUE)
      })
    }
    
    html_xml_file_names <- all_files[html_xml_files]
    non_html_xml_file_names <- all_files[!html_xml_files]
    
    if (verbose == 3 && length(non_html_xml_file_names) > 0) {
      message("Removing file(s) '", paste(non_html_xml_file_names, collapse = "', '"), "' for not being HTML/XML.")
    }
    
    if (verbose >= 1) {
      message("There are ", length(html_xml_file_names), " HTML/XML files in the ", ifelse(use_drive, "Google Drive folder", "directory"), ".")
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
      if (use_drive) {
        # Download and process Google Drive file
        html_content <- tryCatch({
          # Get the file ID for the matching file
          file_info <- drive_files[drive_files$name == file_name, ]
          if (nrow(file_info) == 0) {
            stop("File not found in Google Drive folder")
          }
          
          # Create a temporary file to download to
          temp_file <- tempfile(fileext = paste0(".", tools::file_ext(file_name)))
          
          # Download the file
          googledrive::drive_download(googledrive::as_id(file_info$id), path = temp_file, overwrite = TRUE)
          
          # Read the HTML content
          content <- rvest::read_html(temp_file)
          
          # Clean up temp file
          unlink(temp_file)
          
          content
        }, error = function(e) {
          malformed_files <<- c(malformed_files, file_name)
          return(NULL)
        })
      } else {
        # Process local file
        file_path <- file.path(path, file_name)
        html_content <- tryCatch({
          rvest::read_html(file_path)
        }, error = function(e) {
          malformed_files <<- c(malformed_files, file_name)
          return(NULL)
        })
      }
      
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
      
      # Filter by email if specified
      if (!identical(emails, "*")) {
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