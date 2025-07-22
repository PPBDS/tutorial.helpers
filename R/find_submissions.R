#' Find Submissions
#'
#' This function finds and reads HTML/XML files from a directory that match specified patterns.
#' It extracts tables from the files and returns a list of tibbles.
#'
#' @param path The path to the directory containing the HTML/XML files.
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
#'
#' @examples
#' \dontrun{
#' # Find submissions with default pattern
#' tibble_list <- find_submissions("path/to/directory", pattern = ".")
#'
#' # Find submissions with specific patterns
#' tibble_list <- find_submissions("path/to/directory", title = c("getting", "get-to-know"))
#'
#' # Find submissions with specific patterns and email filtering
#' tibble_list <- find_submissions("path/to/directory", title = c("getting", "get-to-know"), emails = c("user1@example.com", "user2@example.com"))
#' }
#' @export

find_submissions <- function(path, title, emails = "*", verbose = 0) {
  
  # Check if the directory exists
  if (!dir.exists(path)) {
    stop("The specified directory does not exist.")
  }
  
  # Initialize list to store results from all patterns
  all_tibbles <- list()
  
  # Process each pattern
  for (current_title in title) {
    
    # Get the list of all files in the directory
    all_files <- list.files(path, full.names = FALSE)
    num_files <- length(all_files)
    
    if (verbose >= 1) {
      if (length(title) > 1) {
        message("Processing pattern '", current_title, "':")
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
    
    matching_files <- grep(current_title, html_xml_file_names, value = TRUE)
    non_matching_files <- setdiff(html_xml_file_names, matching_files)
    
    if (verbose == 3 && length(non_matching_files) > 0) {
      message("Removing file(s) '", paste(non_matching_files, collapse = "', '"), "' for not matching the pattern '", current_title, "'.")
    }
    
    if (verbose >= 1) {
      message("There are ", length(matching_files), " HTML/XML files matching the pattern '", current_title, "'.")
    }
    
    matching_file_paths <- file.path(path, all_files)[all_files %in% matching_files]
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
          rvest::html_table(html_content)[[1]]
        },
        error = function(e) {
          malformed_files <<- c(malformed_files, basename(file))
          return(NULL)
        }
      )
      
      if (is.null(table_data)) {
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