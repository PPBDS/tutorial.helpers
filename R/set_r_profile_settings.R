#' @title Configure R Profile Settings for Better User Experience
#'
#' @description
#' Configures important settings in your `.Rprofile` to improve the R 
#' experience, especially for new users. This includes:
#' - Setting package installation to use binaries (non-Linux systems)
#' - Increasing the timeout for downloads to prevent installation failures
#'
#' These settings help avoid common issues like source compilation failures
#' on Windows and timeout errors when downloading large packages.
#'
#' You can examine your `.Rprofile` to confirm changes with
#' `usethis::edit_r_profile()`
#' 
#' @param set_for_session Logical, defaults to `TRUE`. If `TRUE`, also applies
#'   these settings to the current R session.
#' @param backup Logical, defaults to `TRUE`. If `TRUE`, creates a backup of
#'   existing `.Rprofile` before modifying it.
#'
#' @returns Invisible `NULL`. Called for side effects.
#' 
#' @examples
#' \dontrun{
#'   # Apply settings to .Rprofile and current session
#'   set_rprofile_settings()
#'   
#'   # Only modify .Rprofile, don't change current session
#'   set_rprofile_settings(set_for_session = FALSE)
#'   
#'   # Modify without creating backup
#'   set_rprofile_settings(backup = FALSE)
#' }
#'
#' @export

set_rprofile_settings <- function(set_for_session = TRUE, backup = TRUE){
  
  # Get path to user .Rprofile
  home <- Sys.getenv("HOME")
  rprof <- file.path(home, ".Rprofile")
  
  # Define settings to add
  settings_to_add <- list()
  
  # Only add binary setting for non-Linux systems
  if(Sys.info()["sysname"] != "Linux"){
    settings_to_add[["binary"]] <- "options(pkgType = 'binary')"
  }
  
  # Add timeout setting for all systems
  settings_to_add[["timeout"]] <- "options(timeout = max(300, getOption('timeout')))"
  
  # If no settings to add (unlikely but possible), exit early
  if(length(settings_to_add) == 0){
    message("No settings to add.")
    return(invisible(NULL))
  }
  
  # Track what was added/found
  added <- character()
  already_present <- character()
  
  # Check if .Rprofile exists and read it
  if(file.exists(rprof)){
    # Read the file line by line to preserve structure
    curr_lines <- readLines(rprof, warn = FALSE)
    original_lines <- curr_lines  # Keep original for comparison
    
    # Create backup if requested and we're going to make changes
    if(backup){
      backup_file <- paste0(rprof, ".backup_", format(Sys.time(), "%Y%m%d_%H%M%S"))
      file.copy(rprof, backup_file)
      message("Created backup at: ", backup_file)
    }
    
    # Check each setting
    for(name in names(settings_to_add)){
      line_to_add <- settings_to_add[[name]]
      
      # Normalize for comparison (remove all whitespace)
      curr_content_normalized <- gsub("\\s", "", paste(curr_lines, collapse = ""))
      target_normalized <- gsub("\\s", "", line_to_add)
      
      if(grepl(target_normalized, curr_content_normalized, fixed = TRUE)){
        already_present <- c(already_present, name)
      } else {
        curr_lines <- c(curr_lines, line_to_add)
        added <- c(added, name)
      }
    }
    
    # Only write if we added something new
    if(length(added) > 0){
      # Ensure there's a blank line before our additions for readability
      if(length(original_lines) > 0 && nzchar(original_lines[length(original_lines)])){
        # Find where original content ends
        orig_length <- length(original_lines)
        new_lines <- c(original_lines, "", curr_lines[(orig_length + 1):length(curr_lines)])
        curr_lines <- new_lines
      }
      
      # Write back to file
      tryCatch({
        writeLines(curr_lines, rprof)
        message("Successfully updated .Rprofile")
        
        # Clean up backup if successful and we created one
        if(backup && file.exists(backup_file)){
          file.remove(backup_file)
          message("Removed backup file (update successful)")
        }
      }, error = function(e){
        message("Error writing to .Rprofile: ", e$message)
        if(backup && exists("backup_file")){
          message("Backup preserved at: ", backup_file)
        }
        stop("Failed to update .Rprofile")
      })
    }
    
  } else {
    # Create new .Rprofile
    message("Creating .Rprofile in your home directory")
    
    # Add header comment for clarity
    lines_to_write <- c(
      "# R Profile Settings",
      "# Created by tutorial.helpers::set_rprofile_settings()",
      paste0("# Date: ", Sys.Date()),
      "",
      unlist(settings_to_add, use.names = FALSE)
    )
    
    tryCatch({
      writeLines(lines_to_write, rprof)
      message("Successfully created .Rprofile with settings")
      added <- names(settings_to_add)
    }, error = function(e){
      stop("Failed to create .Rprofile: ", e$message)
    })
  }
  
  # Report what was done
  if(length(added) > 0){
    message("\nAdded the following settings to .Rprofile:")
    for(name in added){
      message("  - ", name, ": ", settings_to_add[[name]])
    }
  }
  
  if(length(already_present) > 0){
    message("\nThe following settings were already present:")
    for(name in already_present){
      message("  - ", name, ": ", settings_to_add[[name]])
    }
  }
  
  # Apply settings to current session if requested
  if(set_for_session){
    message("\nApplying settings to current R session...")
    
    if(Sys.info()["sysname"] != "Linux"){
      options(pkgType = 'binary')
      message("  - Set pkgType to 'binary'")
    }
    
    # Set timeout, preserving higher value if one exists
    current_timeout <- getOption("timeout")
    new_timeout <- max(300, current_timeout)
    options(timeout = new_timeout)
    # Construct the timeout message conditionally
    timeout_msg <- paste("  - Set timeout to", new_timeout, "seconds")
    if (current_timeout < 300) {
      timeout_msg <- paste0(timeout_msg, " (increased from ", current_timeout, ")")
    }
    message(timeout_msg)
  }
  
  invisible(NULL)
}