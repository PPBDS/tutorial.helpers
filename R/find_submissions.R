#' Find Submissions
#'
#' This function finds and reads HTML/XML files from a local directory or Google Drive folder that match specified patterns.
#' It extracts tables from the files and returns a list of tibbles.
#'
#' @param path The path to the local directory containing the HTML/XML files.
#'        Cannot be used together with `drive` parameter.
#' @param title A character vector of patterns to match against the file names.
#'        Each pattern is processed separately and results are combined.
#' @param emails A character vector of email addresses to filter results by, or "*" to match all (default: "*").
#' @param verbose An integer specifying the verbosity level. 0: no messages, 1: file count messages, 2: some detailed messages about files, 3: detailed messages including all file problems (default: 0).
#' @param drive A Google Drive folder URL. If provided, the function will download the entire folder
#'        using download_google_drive() and then recursively call find_submissions() with the downloaded path.
#'        Cannot be used together with `path` parameter.
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
#' # Find submissions from local directory
#' tibble_list <- find_submissions(path = "path/to/directory", title = ".")
#'
#' # Find submissions from Google Drive folder
#' tibble_list <- find_submissions(
#'   title = c("getting", "get-to-know"),
#'   drive = "https://drive.google.com/drive/folders/your_folder_id"
#' )
#'
#' # Find submissions with specific patterns and email filtering from Google Drive
#' tibble_list <- find_submissions(
#'   title = c("getting", "get-to-know"), 
#'   emails = c("user1@example.com", "user2@example.com"),
#'   drive = "https://drive.google.com/drive/folders/your_folder_id"
#' )
#' 
#' # Find submissions from local directory with email filtering
#' tibble_list <- find_submissions(
#'   path = "path/to/directory", 
#'   title = c("getting", "get-to-know"), 
#'   emails = c("user1@example.com", "user2@example.com")
#' )
#' }
#' @export

find_submissions <- function(path = NULL, title, emails = "*", verbose = 0, drive = NULL) {
  
  # Validate parameters - cannot have both path and drive
  if (!is.null(path) && !is.null(drive)) {
    stop("Cannot specify both 'path' and 'drive' parameters. Please provide only one.")
  }
  
  # Must have either path or drive
  if (is.null(path) && is.null(drive)) {
    stop("Either 'path' or 'drive' must be provided.")
  }
  
  # If drive is provided, download and recursively call with path
  if (!is.null(drive)) {
    if (verbose >= 1) {
      message("Google Drive URL provided. Downloading folder using download_google_drive()...")
    }
    
    # Check if googledrive package is available
    if (!requireNamespace("googledrive", quietly = TRUE)) {
      stop("Package 'googledrive' is required for Google Drive functionality. ",
           "Please install it with: install.packages('googledrive')")
    }
    
    # Download from Google Drive with title filtering
    downloaded_path <- download_google_drive(url = drive, path = NULL, title = title)
    
    # Validate that the download was successful
    if (is.null(downloaded_path) || !dir.exists(downloaded_path)) {
      stop("Google Drive download failed - no valid directory returned.")
    }
    
    if (verbose >= 1) {
      message("Google Drive folder downloaded to: ", downloaded_path)
      message("Now processing downloaded files...")
    }
    
    # Recursively call find_submissions with the downloaded path
    return(find_submissions(path = downloaded_path, title = title, emails = emails, verbose = verbose, drive = NULL))
  }
  
  # From here on, we're working with a local path
  working_path <- path
  
  # Check if the directory exists
  if (!dir.exists(working_path)) {
    stop("The specified directory does not exist: ", working_path)
  }
  
  # Initialize list to store results from all patterns
  all_tibbles <- list()
  
  # Process each pattern
  for (current_title in title) {
    
    # Get the list of all files in the directory
    all_files <- list.files(working_path, full.names = FALSE, recursive = TRUE)
    num_files <- length(all_files)
    
    if (verbose >= 1) {
      if (length(title) > 1) {
        message("Processing pattern '", current_title, "':")
      }
      message("There are ", num_files, " files in the directory.")
    }
    
    full_file_paths <- file.path(working_path, all_files)
    html_xml_files <- sapply(full_file_paths, function(file) {
      if (!file.exists(file)) return(FALSE)
      
      mime_type <- tryCatch({
        mime::guess_type(file)
      }, error = function(e) "")
      
      # Check both MIME type and extension
      grepl("html|xml", mime_type, ignore.case = TRUE) || 
        grepl("\\.(html?|xml)$", basename(file), ignore.case = TRUE)
    })
    
    html_xml_file_names <- all_files[html_xml_files]
    non_html_xml_file_names <- all_files[!html_xml_files]
    
    if (verbose == 3 && length(non_html_xml_file_names) > 0) {
      files_to_show <- head(non_html_xml_file_names, 3)
      message("Removing file(s) '", paste(files_to_show, collapse = "', '"), 
             if(length(non_html_xml_file_names) > 3) "', ..." else "'", 
             " for not being HTML/XML.")
    }
    
    if (verbose >= 1) {
      message("There are ", length(html_xml_file_names), " HTML/XML files in the directory.")
    }
    
    matching_files <- grep(current_title, html_xml_file_names, value = TRUE)
    non_matching_files <- setdiff(html_xml_file_names, matching_files)
    
    if (verbose == 3 && length(non_matching_files) > 0) {
      files_to_show <- head(non_matching_files, 3)
      message("Removing file(s) '", paste(files_to_show, collapse = "', '"), 
             if(length(non_matching_files) > 3) "', ..." else "'", 
             " for not matching the pattern '", current_title, "'.")
    }
    
    if (verbose >= 1) {
      message("There are ", length(matching_files), " HTML/XML files matching the pattern '", current_title, "'.")
    }
    
    matching_file_paths <- file.path(working_path, all_files)[all_files %in% matching_files]
    tibble_list <- list()
    well_formed_files <- 0
    malformed_files <- character()
    
    for (file in matching_file_paths) {
      html_content <- tryCatch(
        {
          rvest::read_html(file)
        },
        error = function(e) {
          malformed_files <<- c(malformed_files, basename(file))
          return(NULL)
        }
      )
      
      if (is.null(html_content)) {
        next
      }
      
      table_data <- tryCatch(
        {
          tables <- rvest::html_table(html_content)
          if (length(tables) == 0) {
            malformed_files <<- c(malformed_files, basename(file))
            return(NULL)
          }
          tables[[1]]
        },
        error = function(e) {
          malformed_files <<- c(malformed_files, basename(file))
          return(NULL)
        }
      )
      
      if (is.null(table_data) || nrow(table_data) == 0) {
        malformed_files <<- c(malformed_files, basename(file))
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
                message("Found email field '", field_name, "' in file: ", basename(file))
              }
              break  # Found email field
            }
          }
          
          if (found_email_field && nrow(email_row) > 0) {
            email_value <- email_row$answer[1]
            # Only keep this tibble if email matches one in the emails vector
            if (!email_value %in% emails) {
              if (verbose >= 3) {
                message("Email '", email_value, "' in file '", basename(file), "' does not match any target emails. Skipping.")
              }
              next  # Skip this file
            } else {
              if (verbose >= 3) {
                message("Email '", email_value, "' in file '", basename(file), "' matches target. Keeping file.")
              }
            }
          } else {
            # No email found in this file, skip it
            if (verbose >= 2) {
              message("No email field found in file: ", basename(file), 
                     ". Available id values: ", paste(tibble_data$id, collapse = ", "))
            }
            next
          }
        } else {
          # No proper structure for email filtering, skip this file
          if (verbose >= 2) {
            message("File '", basename(file), "' does not have proper 'id' and 'answer' columns for email filtering. Skipping.")
          }
          next
        }
      }
      
      file_name <- basename(file)
      tibble_list[[file_name]] <- tibble_data
      well_formed_files <- well_formed_files + 1
    }
    
    if (verbose >= 2 && length(malformed_files) > 0) {
      files_to_show <- head(malformed_files, 3)
      message("Removing file(s) '", paste(files_to_show, collapse = "', '"), 
             if(length(malformed_files) > 3) "', ..." else "'", 
             " due to invalid table structure.")
    }
    
    if (verbose >= 1) {
      message("There were ", well_formed_files, " files with valid HTML tables.")
    }
    
    # Add tibbles from this pattern to the overall list
    all_tibbles <- c(all_tibbles, tibble_list)
  }
  
  return(all_tibbles)
}