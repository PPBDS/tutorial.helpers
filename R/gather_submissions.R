#' Gather Submissions
#'
#' This function finds and reads HTML/XML files from a local directory or Google Drive folder that match specified patterns.
#' It extracts tables from the files and returns a list of tibbles.
#'
#' @param path The path to the local directory containing the HTML/XML files, or a Google Drive folder URL.
#'        If it's a Google Drive URL, the function will download the entire folder to a temporary directory.
#' @param title A character vector of patterns to match against the file names.
#'        Each pattern is processed separately and results are combined.
#' @param keep_loc A character string specifying where to save downloaded files (only for Google Drive URLs). 
#'        If NULL (default), files are downloaded to a temporary directory and deleted after processing.
#'        If specified, files are downloaded to this location and kept.
#' @param verbose A logical value specifying verbosity level. FALSE (default): no messages, TRUE: detailed messages.
#'
#' @return A named list of tibbles, where each tibble contains the data from one HTML/XML file
#'         that matches any of the specified patterns and has valid table structure.
#'
#' @examples
#' \dontrun{
#' # Find submissions from local directory
#' tibble_list <- gather_submissions(path = "path/to/directory", title = ".")
#'
#' # Find submissions from Google Drive folder (temporary download)
#' drive_url <- "https://drive.google.com/drive/folders/your_folder_id"
#' tibble_list <- gather_submissions(
#'   path = drive_url, 
#'   title = c("getting", "get-to-know")
#' )
#'
#' # Find submissions from Google Drive folder (keep files)
#' tibble_list <- gather_submissions(
#'   path = drive_url, 
#'   title = c("getting", "get-to-know"),
#'   keep_loc = "~/my_downloads/"
#' )
#' }
#' @export

gather_submissions <- function(path, title, keep_loc = NULL, verbose = FALSE) {
  
  # Input validation
  if (missing(path) || is.null(path)) {
    stop("'path' must be provided.")
  }
  
  if (missing(title) || is.null(title)) {
    stop("'title' must be provided.")
  }
  
  # Determine if path is a Google Drive URL or local directory
  is_drive_url <- grepl("^https?://", path)
  
  # Validate keep_loc usage
  if (!is.null(keep_loc) && !is_drive_url) {
    stop("'keep_loc' can only be used with Google Drive URLs.")
  }
  
  # Track temporary directory for cleanup
  temp_dir_to_cleanup <- NULL
  
  if (is_drive_url) {
    result <- handle_google_drive_url(path, title, keep_loc, verbose)
    real_path <- result$path
    temp_dir_to_cleanup <- result$temp_dir
  } else {
    real_path <- handle_local_directory(path, verbose)
  }
  
  # Get all files in directory
  all_files <- list.files(real_path, full.names = FALSE, recursive = TRUE)
  
  if (verbose) {
    message("There are ", length(all_files), " files in the directory.")
  }
  
  # Filter HTML/XML files
  html_xml_files <- filter_html_xml_files(all_files, real_path, verbose)
  
  if (verbose) {
    message("There are ", length(html_xml_files), " HTML/XML files in the directory.")
  }
  
  # Filter by title patterns
  matching_files <- filter_by_title_patterns(html_xml_files, title, verbose)
  
  if (verbose) {
    message("There are ", length(matching_files), " HTML/XML files matching the pattern '", 
            paste(title, collapse = "|"), "'.")
  }
  
  # Process matching files
  tibble_list <- process_matching_files(matching_files, real_path, verbose)
  
  # Final summary messages  
  valid_files_count <- length(tibble_list)
  
  if (verbose) {
    message("There were ", valid_files_count, " files with valid HTML tables.")
    # Count files that have usable data AND proper structure (id and answer columns)
    no_problems_count <- sum(sapply(tibble_list, function(x) {
      !is.null(x) && nrow(x) > 0 && 
      "id" %in% colnames(x) && "answer" %in% colnames(x)
    }))
    message("There were ", no_problems_count, " files with no problems.")
  }
  
  # Cleanup temporary directory if needed
  if (!is.null(temp_dir_to_cleanup) && dir.exists(temp_dir_to_cleanup)) {
    unlink(temp_dir_to_cleanup, recursive = TRUE)
    if (verbose) {
      message("Cleaned up temporary directory: ", temp_dir_to_cleanup)
    }
  }
  
  return(tibble_list)
}

# Handle Google Drive URL
handle_google_drive_url <- function(path, title, keep_loc, verbose) {
  if (verbose) {
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
  
  # Determine download location
  if (!is.null(keep_loc)) {
    # Use specified location
    download_base_path <- keep_loc
    temp_dir_to_cleanup <- NULL
  } else {
    # Use temporary directory (let download_google_drive create its own structure)
    download_base_path <- NULL
    temp_dir_to_cleanup <- NULL  # Will be set after download
  }
  
  # Use the existing download_google_drive function
  # Note: download_google_drive creates its own subdirectory
  downloaded_path <- download_google_drive(url = path, path = download_base_path, title = title)
  
  # Validate that the download was successful
  if (is.null(downloaded_path) || !dir.exists(downloaded_path)) {
    stop("Google Drive download failed - no valid directory returned.")
  }
  
  if (verbose) {
    message("Google Drive folder successfully downloaded to: ", downloaded_path)
  }
  
  # Set temp directory for cleanup if using temporary location
  if (is.null(keep_loc)) {
    # If keep_loc is NULL, we need to clean up the parent directory created by download_google_drive
    # since download_google_drive creates a subdirectory structure
    temp_dir_to_cleanup <- dirname(downloaded_path)
  }
  
  return(list(path = downloaded_path, temp_dir = temp_dir_to_cleanup))
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
  
  if (verbose && length(non_html_xml_file_names) > 0) {
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
    
    if (verbose && length(title) > 1) {
      message("Pattern '", current_title, "' matched ", length(pattern_matches), " files.")
    }
  }
  
  return(unique(all_matching_files))
}

# Process Matching Files
process_matching_files <- function(matching_files, real_path, verbose) {
  if (length(matching_files) == 0) {
    return(list())
  }
  
  tibble_list <- list()
  processed_count <- 0
  
  for (file_name in matching_files) {
    result <- process_single_file(file_name, real_path, verbose)
    
    if (!is.null(result)) {
      tibble_list[[file_name]] <- result
    }
    
    processed_count <- processed_count + 1
    
    # Progress indicator for large file sets
    if (verbose && length(matching_files) > 10 && processed_count %% 5 == 0) {
      message("Processed ", processed_count, "/", length(matching_files), " files...")
    }
  }
  
  return(tibble_list)
}

# Process Single File
# @param file_name Name of the file to process
# @param real_path Base directory path
# @param verbose Verbosity level
# @return Tibble or NULL if processing failed
process_single_file <- function(file_name, real_path, verbose) {
  file_path <- file.path(real_path, file_name)
  
  # Check if rvest package is available
  if (!requireNamespace("rvest", quietly = TRUE)) {
    stop("Package 'rvest' is required. Please install it with: install.packages('rvest')")
  }
  
  # Read HTML content
  html_content <- tryCatch({
    rvest::read_html(file_path)
  }, error = function(e) {
    if (verbose) {
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
      if (verbose) {
        message("No tables found in: ", file_name)
      }
      return(NULL)
    }
    tables[[1]]
  }, error = function(e) {
    if (verbose) {
      message("Failed to extract table from: ", file_name, " - ", e$message)
    }
    return(NULL)
  })
  
  if (is.null(table_data) || nrow(table_data) == 0) {
    if (verbose) {
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
    if (verbose) {
      message("Failed to convert to tibble: ", file_name, " - ", e$message)
    }
    return(NULL)
  })
  
  return(tibble_data)
}