#' Download Files from a Google Drive Folder
#'
#' Downloads all files or filtered files from a public Google Drive folder to a local directory.
#'
#' @param url Character string. The Google Drive folder URL or ID. Supports standard folder URLs
#'   (e.g., \code{"https://drive.google.com/drive/folders/FOLDER_ID"}) or direct folder IDs.
#' @param path Character string or NULL. The local directory path for downloads.
#'   If NULL (default), uses the current working directory. If the directory doesn't exist, it will be created.
#' @param title Character vector or NULL. Patterns to match against file names for filtering.
#'   If provided, only files whose names contain any of these patterns (case-insensitive) are downloaded.
#'   If NULL (default), all files are downloaded.
#' @param overwrite Logical. If TRUE (default), overwrites existing files. If FALSE, skips files that already exist.
#' @param verbose Logical. If TRUE (default), prints detailed progress messages.
#'
#' @return Character string. The path to the directory where files were downloaded.
#' 
#' @importFrom utils capture.output
#' 
#' @examples
#' \dontrun{
#' # Download all files to current directory
#' download_google_drive("https://drive.google.com/drive/folders/1Rgxfiw")
#'
#' # Download to a specific directory with filtering
#' download_google_drive(
#'   url = "https://drive.google.com/drive/folders/1Rgxfiw",
#'   path = "./my_data",
#'   title = c("report", ".csv"),
#'   overwrite = FALSE
#' )
#' }
#'
#' @export

download_google_drive <- function(url, path = NULL, title = NULL, overwrite = TRUE, verbose = TRUE) {
  # Extract folder ID from URL or use directly if ID is provided
  folder_id <- if (grepl("drive\\.google\\.com", url)) {
    # Extract the ID between /folders/ and the next / or ? or end of string
    # This handles various URL formats including those with additional parameters
    if (grepl("/folders/", url)) {
      # Extract everything after /folders/ until we hit ? or end
      id <- sub(".*/folders/([^/?]+).*", "\\1", url)
    } else if (grepl("id=", url)) {
      # Handle old-style URLs with id= parameter
      id <- sub(".*id=([^&]+).*", "\\1", url)
    } else {
      stop("Could not extract folder ID from URL. Please check the URL format.")
    }
    
    # Basic validation - folder IDs should be alphanumeric with hyphens and underscores
    # Remove the length restriction as IDs can vary
    if (!grepl("^[a-zA-Z0-9_-]+$", id)) {
      stop("Invalid Google Drive folder ID extracted from URL: ", id)
    }
    id
  } else {
    # Assume it's a direct folder ID
    url
  }
  
  if (verbose) cat("Using folder ID:", folder_id, "\n")
  
  # Deauthorize for public access
  googledrive::drive_deauth()
  
  # Get list of files in the folder
  if (verbose) cat("Fetching file list from Google Drive...\n")
  
  tryCatch(
    {
      files <- googledrive::drive_ls(googledrive::as_id(folder_id))
    },
    error = function(e) {
      stop("Failed to list files from Google Drive folder. ",
           "Please ensure the folder is publicly accessible. ",
           "Error: ", e$message)
    }
  )
  
  # Filter files by title patterns if provided
  if (!is.null(title)) {
    pattern <- paste(title, collapse = "|")
    files <- files[grepl(pattern, files$name, ignore.case = TRUE), ]
    if (verbose && nrow(files) > 0) {
      cat("Filtered to", nrow(files), "files matching pattern(s):", paste(title, collapse = ", "), "\n")
    }
  }
  
  if (nrow(files) == 0) {
    if (verbose) cat("No files found matching the criteria.\n")
    return(character(0))
  }
  
  # Set download directory
  download_dir <- if (is.null(path)) getwd() else path
  
  # Create directory if it doesn't exist
  if (!dir.exists(download_dir)) {
    if (verbose) cat("Creating directory:", download_dir, "\n")
    dir.create(download_dir, recursive = TRUE, showWarnings = FALSE)
  }
  
  # Download files with progress feedback
  if (verbose) {
    cat("Found", nrow(files), "file(s) to download\n")
    cat("Download directory:", download_dir, "\n")
    cat("Starting downloads...\n")
  }
  
  downloaded <- 0
  skipped <- 0
  failed <- 0
  
  for (i in seq_len(nrow(files))) {
    file_path <- file.path(download_dir, files$name[i])
    
    if (!overwrite && file.exists(file_path)) {
      if (verbose) cat("  [", i, "/", nrow(files), "] Skipping (exists):", files$name[i], "\n")
      skipped <- skipped + 1
      next
    }
    
    tryCatch(
      {
        if (verbose) cat("  [", i, "/", nrow(files), "] Downloading:", files$name[i], "...")
        googledrive::drive_download(files[i, ], path = file_path, overwrite = overwrite)
        if (verbose) cat(" Done\n")
        downloaded <- downloaded + 1
      },
      error = function(e) {
        if (verbose) cat(" Failed -", e$message, "\n")
        failed <- failed + 1
      }
    )
  }
  
  if (verbose) {
    cat("\nDownload complete:\n")
    cat("  - Downloaded:", downloaded, "file(s)\n")
    if (skipped > 0) cat("  - Skipped:", skipped, "existing file(s)\n")
    if (failed > 0) cat("  - Failed:", failed, "file(s)\n")
  }
  
  return(download_dir)
}