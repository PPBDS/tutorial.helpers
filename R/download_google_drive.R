#' Download Files from Google Drive Folder
#'
#' Downloads all files or filtered files from a public Google Drive folder to a local directory.
#'
#' @param url Character string. The Google Drive folder URL from which to download files.
#'   The function will extract the folder ID from standard Google Drive folder URLs.
#' @param path Character string or NULL. The local directory path where files should be downloaded.
#'   If NULL (default), files are downloaded to the current working directory.
#'   The function will create the directory if it doesn't exist.
#' @param title Character vector or NULL. Patterns to match against file names for filtering.
#'   If provided, only files whose names contain any of these patterns will be downloaded.
#'   Pattern matching is case-insensitive. If NULL (default), all files are downloaded.
#'
#' @return Character string. The path to the directory where files were downloaded.
#'
#' @examples
#' \dontrun{
#' # Download all files from a Google Drive folder to current directory
#' download_google_drive("https://drive.google.com/drive/folders/1Rgxfiw")
#'
#' # Download to a specific directory
#' download_google_drive(
#'   url = "https://drive.google.com/drive/folders/1Rgxfiw",
#'   path = "/home/user/downloads"
#' )
#'
#' # Download only files matching specific patterns
#' download_google_drive(
#'   url = "https://drive.google.com/drive/folders/1Rgxfiw",
#'   title = c("report", "data", ".csv")
#' )
#'
#' # Download filtered files to specific directory
#' result_path <- download_google_drive(
#'   url = "https://drive.google.com/drive/folders/1Rgxfiw",
#'   path = "./my_data",
#'   title = c("analysis", "results")
#' )
#' }
#'
#' @importFrom googledrive drive_deauth drive_ls as_id drive_download
#' @export
download_google_drive <- function(url, path = NULL, title = NULL) {
  # Load required library
  library(googledrive)
  
  # Deauthorize for public access
  drive_deauth()
  
  # Extract folder ID from URL
  folder_id <- sub(".*folders/([a-zA-Z0-9_-]+).*", "\\1", url)
  
  # Get list of files in the folder
  files <- drive_ls(as_id(folder_id))
  
  # Filter files by title patterns if provided
  if (!is.null(title)) {
    # Create pattern to match any of the provided titles
    pattern <- paste(title, collapse = "|")
    files <- files[grepl(pattern, files$name, ignore.case = TRUE), ]
  }
  
  # Set download directory
  if (is.null(path)) {
    download_dir <- getwd()
  } else {
    download_dir <- path
    # Create directory if it doesn't exist
    if (!dir.exists(download_dir)) {
      dir.create(download_dir, recursive = TRUE)
    }
  }
  
  # Create subdirectory for organized downloads
  folder_name <- paste0("gdrive_download_", Sys.Date())
  final_dir <- file.path(download_dir, folder_name)
  if (!dir.exists(final_dir)) {
    dir.create(final_dir, recursive = TRUE)
  }
  
  # Download all filtered files
  if (nrow(files) > 0) {
    for (i in 1:nrow(files)) {
      file_path <- file.path(final_dir, files$name[i])
      drive_download(files[i, ], path = file_path, overwrite = TRUE)
    }
    cat("Downloaded", nrow(files), "files to:", final_dir, "\n")
  } else {
    cat("No files found matching the criteria.\n")
  }
  
  return(final_dir)
}