#' Download files from Google Drive folder
#'
#' This function retrieves a list of files from a specified Google Drive folder
#' and downloads files that match the provided title patterns. If no title
#' patterns are provided, all files in the folder will be downloaded.
#' Files are downloaded to a temporary directory.
#'
#' @param folder_link Character string. The Google Drive folder URL or ID.
#' @param title Character vector of patterns to match against file names.
#'   Uses regex pattern matching. If NULL (default), all files are downloaded.
#' @param overwrite Logical. Whether to overwrite existing files. Default is FALSE.
#' @param case_sensitive Logical. Whether pattern matching should be case sensitive.
#'   Default is FALSE.
#' @param verbose Logical. Whether to print progress messages. Default is TRUE.
#'
#' @return A list containing:
#'   \itemize{
#'     \item temp_dir: The temporary directory path where files were downloaded
#'     \item files: A data frame with information about downloaded files, including:
#'       \itemize{
#'         \item name: Original file name
#'         \item local_path: Local path where file was saved
#'         \item downloaded: Logical indicating if download was successful
#'         \item error_message: Error message if download failed
#'       }
#'   }
#'
#' @examples
#' \dontrun{
#' # Download all files from a folder using URL
#' result <- download_google_drive("https://drive.google.com/drive/folders/1ABC123def456GHI789jkl?usp=sharing")
#' 
#' # Download all files from a folder using ID
#' result <- download_google_drive("1ABC123def456GHI789jkl")
#' 
#' # Download files matching specific patterns
#' result <- download_google_drive(
#'   folder_link = "https://drive.google.com/drive/folders/1ABC123def456GHI789jkl",
#'   title = c("report_", "\\.csv$", "data_2024")
#' )
#' 
#' # Access the temporary directory and files
#' print(result$temp_dir)
#' print(result$files)
#' 
#' # List downloaded files
#' list.files(result$temp_dir)
#' }
#'
#' @export
#' @importFrom googledrive drive_find drive_download as_id drive_reveal drive_get drive_auth drive_deauth drive_has_token
#' @importFrom utils file_test
download_google_drive <- function(folder_link,
                                 title = NULL,
                                 overwrite = FALSE,
                                 case_sensitive = FALSE,
                                 verbose = TRUE) {
  
  # Check if required packages are available
  if (!requireNamespace("googledrive", quietly = TRUE)) {
    stop("Package 'googledrive' is required but not installed. Please install it with: install.packages('googledrive')")
  }
  
  # Validate inputs
  if (missing(folder_link) || is.null(folder_link) || !is.character(folder_link)) {
    stop("folder_link must be provided as a character string (Google Drive URL or folder ID)")
  }
  
  if (!is.null(title) && !is.character(title)) {
    stop("title must be a character vector or NULL")
  }
  
  # Extract folder ID from URL if a full Google Drive URL is provided
  original_input <- folder_link
  folder_id <- folder_link
  
  if (grepl("^https://drive\\.google\\.com", folder_link)) {
    if (grepl("folders/", folder_link)) {
      id_match <- regmatches(folder_link, regexpr("folders/([a-zA-Z0-9_-]+)", folder_link))
      if (length(id_match) > 0) {
        folder_id <- gsub("folders/", "", id_match)
      } else {
        stop("Could not extract folder ID from the provided Google Drive URL.")
      }
    } else if (grepl("id=", folder_link)) {
      id_match <- regmatches(folder_link, regexpr("id=([a-zA-Z0-9_-]+)", folder_link))
      if (length(id_match) > 0) {
        folder_id <- gsub("id=", "", id_match)
      } else {
        stop("Could not extract folder ID from the provided Google Drive URL.")
      }
    } else {
      stop("Unsupported Google Drive URL format. Please use a standard folder sharing URL or just the folder ID.")
    }
  }
  
  # Create temporary directory for downloads
  temp_dir <- tempdir()
  download_dir <- file.path(temp_dir, paste0("gdrive_download_", Sys.Date(), "_", format(Sys.time(), "%H%M%S")))
  
  if (!dir.exists(download_dir)) {
    dir.create(download_dir, recursive = TRUE, showWarnings = FALSE)
    if (verbose) {
      message("Created temporary download directory: ", download_dir)
    }
  }
  
  if (verbose) {
    message("Using folder ID: ", folder_id)
    message("Attempting to access shared folder...")
  }
  
  files_list <- NULL
  auth_was_active <- googledrive::drive_has_token()
  
  # Method 1: Try with current authentication
  tryCatch({
    if (verbose) {
      message("Searching for files in folder using drive_find()...")
    }
    
    search_query <- paste0("'", folder_id, "' in parents and trashed=false")
    files_list <- googledrive::drive_find(q = search_query, n_max = 1000)
    
    if (verbose && !is.null(files_list) && nrow(files_list) > 0) {
      message("Found ", nrow(files_list), " files using drive_find()")
    }
    
  }, error = function(e) {
    if (verbose) {
      message("drive_find() failed: ", e$message)
    }
    files_list <<- NULL
  })
  
  # Method 2: Try with deauth (public access) - this worked in your original attempt
  if (is.null(files_list) || nrow(files_list) == 0) {
    tryCatch({
      if (verbose) {
        message("Trying public access method (deauth)...")
      }
      
      # Temporarily disable auth for public access
      googledrive::drive_deauth()
      
      search_query <- paste0("'", folder_id, "' in parents and trashed=false")
      files_list <- googledrive::drive_find(q = search_query, n_max = 1000)
      
      if (verbose && !is.null(files_list) && nrow(files_list) > 0) {
        message("Found ", nrow(files_list), " files using public access")
      }
      
      # Re-authenticate if it was active before
      if (auth_was_active) {
        googledrive::drive_auth()
      }
      
    }, error = function(e) {
      # Make sure to re-authenticate even if there's an error
      if (auth_was_active) {
        tryCatch(googledrive::drive_auth(), error = function(e) NULL)
      }
      if (verbose) {
        message("Public access attempt failed: ", e$message)
      }
    })
  }
  
  # Method 3: Try alternative search methods
  if (is.null(files_list) || nrow(files_list) == 0) {
    tryCatch({
      if (verbose) {
        message("Trying alternative search method...")
      }
      
      # Try searching for all files and then filter by parents
      all_files <- googledrive::drive_find(n_max = 1000)
      
      # Get detailed info for files to check parents
      files_with_parents <- googledrive::drive_reveal(all_files, "parents")
      
      # Filter files that belong to our folder
      if ("parents" %in% names(files_with_parents)) {
        matching_files <- files_with_parents[
          sapply(files_with_parents$parents, function(x) folder_id %in% x), 
        ]
        
        if (nrow(matching_files) > 0) {
          files_list <- matching_files
          if (verbose) {
            message("Found ", nrow(files_list), " files using alternative method")
          }
        }
      }
      
    }, error = function(e) {
      if (verbose) {
        message("Alternative search failed: ", e$message)
      }
    })
  }
  
  # Method 4: Direct folder access
  if (is.null(files_list) || nrow(files_list) == 0) {
    tryCatch({
      if (verbose) {
        message("Trying direct folder access...")
      }
      
      # Try to get the folder itself first
      folder_info <- googledrive::drive_get(googledrive::as_id(folder_id))
      
      if (nrow(folder_info) > 0) {
        if (verbose) {
          message("Folder found: ", folder_info$name)
          message("Attempting to list contents...")
        }
        
        # Now try to list its contents
        files_list <- googledrive::drive_find(
          q = paste0("'", folder_id, "' in parents"),
          n_max = 1000
        )
        
        if (verbose && !is.null(files_list) && nrow(files_list) > 0) {
          message("Found ", nrow(files_list), " files in folder")
        }
      }
      
    }, error = function(e) {
      if (verbose) {
        message("Direct folder access failed: ", e$message)
      }
    })
  }
  
  # Final check - if we still have no files, provide detailed error
  if (is.null(files_list) || nrow(files_list) == 0) {
    
    # Try one final diagnostic
    diagnostic_msg <- ""
    tryCatch({
      folder_check <- googledrive::drive_get(googledrive::as_id(folder_id))
      if (nrow(folder_check) > 0) {
        diagnostic_msg <- paste0("\nFolder '", folder_check$name, "' exists but appears to be empty or inaccessible.")
      } else {
        diagnostic_msg <- "\nFolder not found or not accessible."
      }
    }, error = function(e) {
      diagnostic_msg <<- paste0("\nCannot access folder: ", e$message)
    })
    
    stop("Cannot access files in the Google Drive folder.", diagnostic_msg, "\n\n",
         "TROUBLESHOOTING STEPS:\n\n",
         "1. VERIFY FOLDER ACCESS:\n",
         "   Open this URL in your browser: https://drive.google.com/drive/folders/", folder_id, "\n",
         "   Can you see the files? If not, the folder may not be shared properly.\n\n",
         "2. CHECK SHARING SETTINGS:\n",
         "   - Ask the folder owner to share it with your email address\n",
         "   - Ensure you have at least 'Viewer' permissions\n",
         "   - Try making the folder 'Anyone with the link can view'\n\n",
         "3. AUTHENTICATION:\n",
         "   Run: googledrive::drive_auth()\n",
         "   Make sure you authenticate with the same account that has folder access\n\n",
         "4. TRY MANUAL APPROACH:\n",
         "   # Check what files you can see\n",
         "   googledrive::drive_find(n_max = 20)\n",
         "   \n",
         "   # Search for files in the folder\n",
         "   googledrive::drive_find(q = \"'", folder_id, "' in parents\")\n\n",
         "Original input: ", original_input, "\n",
         "Folder ID used: ", folder_id)
  }
  
  if (verbose) {
    message("Successfully found ", nrow(files_list), " files")
  }
  
  # Filter files based on title patterns if provided
  if (!is.null(title)) {
    pattern_flags <- if (case_sensitive) "" else "(?i)"
    combined_pattern <- paste0(pattern_flags, "(", paste(title, collapse = "|"), ")")
    
    matching_files <- files_list[grepl(combined_pattern, files_list$name, perl = TRUE), ]
    
    if (nrow(matching_files) == 0) {
      if (verbose) {
        message("No files matched the provided title patterns: ", paste(title, collapse = ", "))
        message("Available files: ", paste(files_list$name, collapse = ", "))
      }
      
      return(list(
        temp_dir = download_dir,
        files = data.frame(
          name = character(0),
          local_path = character(0),
          downloaded = logical(0),
          error_message = character(0)
        )
      ))
    }
    
    files_to_download <- matching_files
    if (verbose) {
      message("Found ", nrow(files_to_download), " files matching title patterns")
    }
  } else {
    files_to_download <- files_list
    if (verbose) {
      message("No title patterns provided - will download all files")
    }
  }
  
  # Initialize results data frame
  results <- data.frame(
    name = files_to_download$name,
    local_path = character(nrow(files_to_download)),
    downloaded = logical(nrow(files_to_download)),
    error_message = character(nrow(files_to_download)),
    stringsAsFactors = FALSE
  )
  
  # Download files one at a time
  if (verbose) {
    message("Starting downloads to temporary directory...")
  }
  
  for (i in seq_len(nrow(files_to_download))) {
    file_info <- files_to_download[i, ]
    # Use original file name in temporary directory
    local_file_path <- file.path(download_dir, file_info$name)
    
    # Check if file already exists and overwrite setting
    if (file.exists(local_file_path) && !overwrite) {
      if (verbose) {
        message("Skipping '", file_info$name, "' - file already exists (use overwrite=TRUE to replace)")
      }
      results$local_path[i] <- local_file_path
      results$downloaded[i] <- FALSE
      results$error_message[i] <- "File already exists, overwrite=FALSE"
      next
    }
    
    if (verbose) {
      message("Downloading file ", i, " of ", nrow(files_to_download), ": ", file_info$name)
    }
    
    # Try multiple download methods
    download_success <- FALSE
    
    # Method 1: Standard download with current auth
    if (!download_success) {
      tryCatch({
        if (verbose) {
          message("  Attempting standard download...")
        }
        
        download_result <- googledrive::drive_download(
          file = googledrive::as_id(file_info$id),
          path = local_file_path,
          overwrite = overwrite,
          verbose = FALSE
        )
        
        if (file.exists(local_file_path)) {
          results$local_path[i] <- local_file_path
          results$downloaded[i] <- TRUE
          results$error_message[i] <- ""
          download_success <- TRUE
          
          if (verbose) {
            message("✓ Successfully downloaded: ", file_info$name)
          }
        }
        
      }, error = function(e) {
        if (verbose) {
          message("  Standard download failed: ", e$message)
        }
      })
    }
    
    # Method 2: Try with deauth (public access)
    if (!download_success) {
      tryCatch({
        if (verbose) {
          message("  Trying public access download...")
        }
        
        current_auth <- googledrive::drive_has_token()
        
        # Temporarily disable auth
        googledrive::drive_deauth()
        
        download_result <- googledrive::drive_download(
          file = googledrive::as_id(file_info$id),
          path = local_file_path,
          overwrite = overwrite,
          verbose = FALSE
        )
        
        # Re-authenticate if it was active
        if (current_auth) {
          googledrive::drive_auth()
        }
        
        if (file.exists(local_file_path)) {
          results$local_path[i] <- local_file_path
          results$downloaded[i] <- TRUE
          results$error_message[i] <- "Downloaded via public access"
          download_success <- TRUE
          
          if (verbose) {
            message("✓ Public access download succeeded: ", file_info$name)
          }
        }
        
      }, error = function(e) {
        # Make sure to re-authenticate
        tryCatch({
          if (googledrive::drive_has_token() != current_auth) {
            if (current_auth) {
              googledrive::drive_auth()
            }
          }
        }, error = function(e2) NULL)
        
        if (verbose) {
          message("  Public access download failed: ", e$message)
        }
      })
    }
    
    # Method 3: Try downloading to temp file first, then copy
    if (!download_success) {
      tryCatch({
        if (verbose) {
          message("  Trying temp file method...")
        }
        
        temp_file <- tempfile(fileext = paste0(".", tools::file_ext(file_info$name)))
        
        googledrive::drive_download(
          file = file_info,
          path = temp_file,
          overwrite = TRUE,
          verbose = FALSE
        )
        
        if (file.exists(temp_file)) {
          file.copy(temp_file, local_file_path, overwrite = overwrite)
          file.remove(temp_file)
          
          if (file.exists(local_file_path)) {
            results$local_path[i] <- local_file_path
            results$downloaded[i] <- TRUE
            results$error_message[i] <- "Downloaded via temp file method"
            download_success <- TRUE
            
            if (verbose) {
              message("✓ Temp file method succeeded: ", file_info$name)
            }
          }
        }
        
      }, error = function(e) {
        if (verbose) {
          message("  Temp file method failed: ", e$message)
        }
      })
    }
    
    # Method 4: Try with different file reference
    if (!download_success) {
      tryCatch({
        if (verbose) {
          message("  Trying with file object reference...")
        }
        
        # Get fresh file info
        fresh_file <- googledrive::drive_get(googledrive::as_id(file_info$id))
        
        download_result <- googledrive::drive_download(
          file = fresh_file,
          path = local_file_path,
          overwrite = overwrite,
          verbose = FALSE
        )
        
        if (file.exists(local_file_path)) {
          results$local_path[i] <- local_file_path
          results$downloaded[i] <- TRUE
          results$error_message[i] <- "Downloaded via fresh file reference"
          download_success <- TRUE
          
          if (verbose) {
            message("✓ Fresh file reference succeeded: ", file_info$name)
          }
        }
        
      }, error = function(e) {
        if (verbose) {
          message("  Fresh file reference failed: ", e$message)
        }
      })
    }
    
    # If all methods failed, record the failure
    if (!download_success) {
      results$local_path[i] <- NA_character_
      results$downloaded[i] <- FALSE
      results$error_message[i] <- "All download methods failed"
      
      if (verbose) {
        message("✗ All download methods failed for: ", file_info$name)
      }
    }
    
    # Add longer delay between downloads and after failures to avoid rate limits
    if (i < nrow(files_to_download)) {
      if (download_success) {
        Sys.sleep(0.5)  # Short delay for successful downloads
      } else {
        Sys.sleep(2.0)  # Longer delay after failures
      }
    }
  }
  
  # Summary message
  successful_downloads <- sum(results$downloaded)
  if (verbose) {
    message("\n=== DOWNLOAD SUMMARY ===")
    message("Temporary directory: ", download_dir)
    message("Successfully downloaded: ", successful_downloads, " out of ", nrow(results), " files")
    
    if (successful_downloads > 0) {
      message("Downloaded files:")
      successful_files <- results[results$downloaded, ]
      for (j in seq_len(nrow(successful_files))) {
        message("  ✓ ", successful_files$name[j])
      }
    }
    
    if (successful_downloads < nrow(results)) {
      failed_files <- results[!results$downloaded, ]
      message("Failed downloads:")
      for (j in seq_len(nrow(failed_files))) {
        message("  ✗ ", failed_files$name[j], ": ", failed_files$error_message[j])
      }
    }
  }
  
  return(list(
    temp_dir = download_dir,
    files = results
  ))
}