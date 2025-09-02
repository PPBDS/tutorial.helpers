#' Gather Submissions
#'
#' @description This function finds and reads HTML/XML files from a local directory 
#' or Google Drive folder that match specified patterns. It extracts tables from the 
#' files and returns a list of tibbles containing the submission data.
#'
#' @param path The path to the local directory containing the HTML/XML files, or a Google Drive folder URL.
#'        If it's a Google Drive URL, the function will download the entire folder to a temporary directory.
#' @param title A character vector of patterns to match against the file names.
#'        Each pattern is processed separately and results are combined.
#' @param keep_loc A character string specifying where to save downloaded files (only for Google Drive URLs). 
#'        If NULL (default), files are downloaded to a temporary directory and deleted after processing.
#'        If specified, files are downloaded to this location and kept.
#' @param verbose A logical value (TRUE or FALSE) specifying verbosity level. 
#'        If TRUE, reports files that are removed during processing.
#'
#' @details Google Drive allows for more than one file with the exact same name. 
#' If you download files manually ("by hand"), you will get both files but with 
#' one of them automatically renamed by your browser. However, if you use the 
#' Google Drive functionality in this function, the second file will overwrite 
#' the first, potentially resulting in data loss.
#'
#' @return A named list of tibbles, where each tibble contains the data from one HTML/XML file
#'         that matches any of the specified patterns and has valid table structure.
#'
#' @examples
#' \dontrun{
#' # Find submissions from local directory
#' 
#' path <- file.path(find.package("tutorial.helpers"), "tests/testthat/fixtures/answers_html")
#' 
#' tibble_list <- gather_submissions(path = path, title = "stop", verbose = TRUE)
#'
#' # Find submissions from Google Drive folder (temporary download)
#' drive_url <- "https://drive.google.com/drive/folders/10do12t0fZsfrIrKePxwjpH8IqBNVO86N"
#' tibble_list <- gather_submissions(
#'   path = drive_url, 
#'   title = c("positron")
#' )
#'
#' # Find submissions from Google Drive folder (keep files)
#' tibble_list <- gather_submissions(
#'   path = drive_url, 
#'   title = c("introduction"),
#'   keep_loc = "temp_file"
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
  
  # Validate verbose parameter
  if (!is.logical(verbose) || length(verbose) != 1) {
    stop("'verbose' must be a single logical value (TRUE or FALSE).")
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
  
  # Filter HTML/XML files
  html_xml_files <- filter_html_xml_files(all_files, real_path, verbose)
  
  # Filter by title patterns
  matching_files <- filter_by_title_patterns(html_xml_files, title, verbose)
  
  # Process matching files
  tibble_list <- process_matching_files(matching_files, real_path, verbose)
  
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
    # Use specified location - download_google_drive will create a subdirectory there
    download_base_path <- keep_loc
    temp_dir_to_cleanup <- NULL
  } else {
    # Use temporary directory - download_google_drive will create a subdirectory there
    download_base_path <- tempdir()
    # We'll need to clean up the subdirectory that download_google_drive creates
    temp_dir_to_cleanup <- NULL  # Will be set after download
  }
  
  # Capture output to suppress the cat() messages if not verbose
  if (!verbose) {
    invisible(capture.output({
      downloaded_path <- download_google_drive(url = path, path = download_base_path, title = title)
    }))
  } else {
    downloaded_path <- download_google_drive(url = path, path = download_base_path, title = title)
  }
  
  # Validate that the download was successful
  if (is.null(downloaded_path) || !dir.exists(downloaded_path)) {
    stop("Google Drive download failed - no valid directory returned.")
  }
  
  if (verbose) {
    message("Google Drive folder successfully downloaded to: ", downloaded_path)
  }
  
  # Set temp directory for cleanup if using temporary location
  if (is.null(keep_loc)) {
    # The downloaded_path is the full path to the created subdirectory (e.g., /tmp/gdrive_download_2025-08-31)
    # This is what we want to clean up, not its parent
    temp_dir_to_cleanup <- downloaded_path
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
  
  # Only report removed files when verbose = TRUE
  if (verbose && length(non_html_xml_file_names) > 0) {
    if (!requireNamespace("utils", quietly = TRUE)) {
      stop("Package 'utils' is required. Please install it with: install.packages('utils')")
    }
    files_to_show <- utils::head(non_html_xml_file_names, 3)
    message("Removed ", length(non_html_xml_file_names), " non-HTML/XML file(s): '", 
           paste(files_to_show, collapse = "', '"), 
           if(length(non_html_xml_file_names) > 3) "', ..." else "'")
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
  }
  
  all_matching_files <- unique(all_matching_files)
  
  # Report files that matched patterns when verbose = TRUE
  if (verbose && length(all_matching_files) > 0) {
    if (!requireNamespace("utils", quietly = TRUE)) {
      stop("Package 'utils' is required. Please install it with: install.packages('utils')")
    }
    files_to_show <- utils::head(all_matching_files, 3)
    message("Found ", length(all_matching_files), " file(s) matching pattern '", 
           paste(title, collapse = "|"), "': '", 
           paste(files_to_show, collapse = "', '"), 
           if(length(all_matching_files) > 3) "', ..." else "'")
  }
  
  return(all_matching_files)
}

# Process Matching Files
process_matching_files <- function(matching_files, real_path, verbose) {
  if (length(matching_files) == 0) {
    return(list())
  }
  
  tibble_list <- list()
  failed_files <- character()
  
  for (file_name in matching_files) {
    result <- process_single_file(file_name, real_path, verbose)
    
    if (!is.null(result)) {
      tibble_list[[file_name]] <- result
    } else {
      failed_files <- c(failed_files, file_name)
    }
  }
  
  # Report files that failed processing when verbose = TRUE
  if (verbose && length(failed_files) > 0) {
    if (!requireNamespace("utils", quietly = TRUE)) {
      stop("Package 'utils' is required. Please install it with: install.packages('utils')")
    }
    files_to_show <- utils::head(failed_files, 3)
    message("Removed ", length(failed_files), " file(s) due to processing failures: '", 
           paste(files_to_show, collapse = "', '"), 
           if(length(failed_files) > 3) "', ..." else "'")
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
    return(NULL)
  })
  
  if (is.null(html_content)) {
    return(NULL)
  }
  
  # Extract table data
  table_data <- tryCatch({
    tables <- rvest::html_table(html_content)
    if (length(tables) == 0) {
      return(NULL)
    }
    tables[[1]]
  }, error = function(e) {
    return(NULL)
  })
  
  if (is.null(table_data) || nrow(table_data) == 0) {
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
    return(NULL)
  })
  
  return(tibble_data)
}