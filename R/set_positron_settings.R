#' @title Configure Positron Settings
#' 
#' @description
#' Locates or creates the Positron `settings.json` file on Windows or macOS,
#' then updates those settings based on the provided configuration list.
#' Users can specify settings like RStudio keyboard shortcuts. The function can 
#' also optionally configure R profile settings including binary package 
#' preferences and download timeout. Positron is an R-focused Integrated Development
#' Environment (IDE) based on Visual Studio Code, designed to enhance the R programming
#' experience with a modern interface and features.
#'
#' @details
#' This function uses the `jsonlite` package to handle JSON operations and
#' creates the necessary directory structure if it doesn't exist. It is
#' designed to work cross-platform by detecting the operating system and
#' constructing the appropriate file path to Positron's user settings. The
#' function applies the settings provided in the `positron_settings` parameter.
#' If the `positron_settings` list is empty, no changes are made to the `settings.json` file.
#' By default, seven settings are applied unless overridden: enabling word wrap for better
#' code readability, disabling startup editor for a clean interface, setting R as the 
#' default language for new files, disabling preview mode for predictable tab behavior,
#' setting Git Bash as the default terminal on Windows, enabling Git smart commit, 
#' and disabling Git sync confirmation dialogs.
#' 
#' Note: Windows file paths in settings should use forward slashes (/) or 
#' escaped backslashes (\\\\). The function will automatically handle path
#' normalization for Windows.
#'
#' @param home_dir Optional character string specifying the base directory to use
#'   as the user's home directory. Defaults to `path.expand("~")`. Useful for
#'   testing or custom setups.
#' @param set.rprofile Logical, defaults to `TRUE`. If `TRUE`, runs
#'   `set_rprofile_settings()` after applying settings to configure binary
#'   package installation and download timeout in the R profile.
#' @param positron_settings List of settings to apply. Can be structured as a list of 
#'   lists where each sub-list contains a setting name and value (e.g., 
#'   `list(list("rstudio.keymap.enable", TRUE))`), or as a named list 
#'   (e.g., `list("rstudio.keymap.enable" = TRUE)`). Defaults to a named list
#'   with seven settings: `list("editor.wordWrap" = "on", 
#'   "workbench.startupEditor" = "none", "files.defaultLanguage" = "r",
#'   "workbench.editor.enablePreview" = FALSE, 
#'   "terminal.integrated.defaultProfile.windows" = "Git Bash",
#'   "git.enableSmartCommit" = TRUE, "git.confirmSync" = FALSE)`, which enables
#'   word wrap for improved code readability, disables startup editor for a clean 
#'   interface, sets R as the default language for new files, disables preview mode 
#'   for predictable tab behavior, sets Git Bash as the default terminal on Windows, 
#'   enables auto-staging of Git changes, and disables confirmation dialogs for 
#'   Git push/pull, respectively.
#'
#' @return Invisible `NULL`. The function's purpose is its side effect: modifying
#'   or creating the `settings.json` file. It also prints messages to the console
#'   indicating actions taken.
#'
#' @examples
#' \dontrun{
#'   # Apply default settings (word wrap, clean startup, R language, 
#'   # no preview, Git Bash terminal, smart commit, no sync confirmation)
#'   set_positron_settings()
#'   
#'   # Enable RStudio keyboard shortcuts using list of lists structure
#'   set_positron_settings(
#'     positron_settings = list(list("rstudio.keymap.enable", TRUE))
#'   )
#'   
#'   # Enable RStudio keyboard shortcuts using named list structure
#'   set_positron_settings(
#'     positron_settings = list("rstudio.keymap.enable" = TRUE)
#'   )
#'   
#'   # Apply multiple settings using named list
#'   set_positron_settings(
#'     positron_settings = list(
#'       "rstudio.keymap.enable" = TRUE,
#'       "editor.wordWrap" = "on"
#'     )
#'   )
#'   
#'   # Set a Windows file path (use forward slashes)
#'   set_positron_settings(
#'     positron_settings = list(
#'       "files.dialog.defaultPath" = "C:/Users/username/projects"
#'     )
#'   )
#'   
#'   # Apply settings without modifying .Rprofile
#'   set_positron_settings(
#'     set.rprofile = FALSE,
#'     positron_settings = list("rstudio.keymap.enable" = TRUE)
#'   )
#'   
#'   # Handle case where settings directory does not exist
#'   set_positron_settings(
#'     home_dir = tempfile(),  # Simulate a non-existent directory
#'     positron_settings = list("rstudio.keymap.enable" = TRUE)
#'   )
#'   
#'   # Handle case with invalid JSON file
#'   # Create an invalid JSON file for testing
#'   dir.create(file.path(tempdir(), "Positron", "User"), recursive = TRUE)
#'   writeLines("invalid json", file.path(tempdir(), "Positron", "User", "settings.json"))
#'   set_positron_settings(
#'     home_dir = tempdir(),
#'     positron_settings = list("rstudio.keymap.enable" = TRUE)
#'   )
#' }
#'
#' @importFrom jsonlite read_json write_json toJSON
#' @export

set_positron_settings <- function(home_dir = path.expand("~"), 
                                 set.rprofile = TRUE, 
                                 positron_settings = list(
                                   "editor.wordWrap" = "on",
                                   "workbench.startupEditor" = "none",
                                   "files.defaultLanguage" = "r",
                                   "workbench.editor.enablePreview" = FALSE,
                                   "terminal.integrated.defaultProfile.windows" = "Git Bash",
                                   "git.enableSmartCommit" = TRUE,
                                   "git.confirmSync" = FALSE
                                 )) {
 
  # Use provided home_dir instead of calling path.expand("~") directly
  if (Sys.info()["sysname"] == "Windows") {
    settings_dir <- file.path(home_dir, "AppData", "Roaming", "Positron", "User")
  } else {  # macOS (or Linux, though Positron is primarily Win/macOS)
    settings_dir <- file.path(home_dir, "Library", "Application Support", "Positron", "User")
  }
  settings_file <- file.path(settings_dir, "settings.json")
  
  # Initialize settings as empty list
  settings <- list()
  
  # Display current settings first
  cat("\n=== Current Positron Settings ===\n")
  
  # Create directory if it doesn't exist
  if (!dir.exists(settings_dir)) {
    dir.create(settings_dir, recursive = TRUE)
    cat("Created directory:", settings_dir, "\n")
  }
  
  # Check if settings.json exists AND is valid
  file_exists <- FALSE
  if (file.exists(settings_file)) {
    # Try to read the file, but if there's an error, we'll treat it as non-existent
    tryCatch({
      # First check if the file is empty
      file_info <- file.info(settings_file)
      if (file_info$size == 0) {
        cat("Settings file exists but is empty.\n")
        file_exists <- FALSE
      } else {
        # Read with simplifyVector = FALSE and simplifyDataFrame = FALSE to preserve structure
        settings <- jsonlite::read_json(settings_file, simplifyVector = FALSE, simplifyDataFrame = FALSE)
        file_exists <- TRUE
      }
    }, error = function(e) {
      cat("Error reading settings file:", e$message, "\n")
      file_exists <- FALSE
    })
  }
  
  # Helper function to format values for display
  format_value_for_display <- function(value, indent = "  ") {
    if (is.null(value)) {
      return("null")
    } else if (is.logical(value)) {
      return(tolower(as.character(value)))
    } else if (is.character(value) && length(value) == 1) {
      return(paste0('"', value, '"'))
    } else if (is.numeric(value) && length(value) == 1) {
      return(as.character(value))
    } else if (is.list(value)) {
      # Handle nested objects
      if (length(value) == 0) {
        return("{}")
      } else if (!is.null(names(value))) {
        # It's a named list (object)
        result <- "{\n"
        items <- names(value)
        for (i in seq_along(items)) {
          key <- items[i]
          val <- value[[key]]
          result <- paste0(result, indent, "    \"", key, "\": ")
          if (is.character(val)) {
            result <- paste0(result, "\"", val, "\"")
          } else {
            result <- paste0(result, tolower(as.character(val)))
          }
          if (i < length(items)) {
            result <- paste0(result, ",")
          }
          result <- paste0(result, "\n")
        }
        result <- paste0(result, indent, "  }")
        return(result)
      } else {
        # It's an array
        return(jsonlite::toJSON(value, auto_unbox = TRUE, pretty = FALSE))
      }
    } else {
      return(as.character(value))
    }
  }
  
  # Display current settings
  if (file_exists && length(settings) > 0) {
    cat("Settings file:", settings_file, "\n\n")
    for (setting_name in names(settings)) {
      value <- settings[[setting_name]]
      cat("  ", setting_name, ": ", format_value_for_display(value), "\n", sep = "")
    }
  } else if (!file.exists(settings_file)) {
    cat("No settings file exists yet at:", settings_file, "\n")
  } else {
    cat("Settings file exists but is empty:", settings_file, "\n")
  }
  
  cat("\n")
  
  # Create a new file with valid JSON if needed
  if (!file_exists) {
    tryCatch({
      jsonlite::write_json(list(), settings_file, pretty = TRUE, auto_unbox = TRUE)
      cat("=== Creating New Settings File ===\n")
      cat("Created new empty settings.json at:", settings_file, "\n\n")
    }, error = function(e) {
      cat("Error creating settings file:", e$message, "\n")
      # If we can't create the file, we should stop
      stop("Unable to create settings file. Please check directory permissions.")
    })
    
    # Re-read the newly created file to make sure it's valid
    tryCatch({
      settings <- jsonlite::read_json(settings_file, simplifyVector = FALSE, simplifyDataFrame = FALSE)
      file_exists <- TRUE
    }, error = function(e) {
      cat("Error reading newly created settings file:", e$message, "\n")
      stop("Unable to read settings file after creation. Please check file permissions.")
    })
  }
  
  # Handle empty settings list
  if (length(positron_settings) == 0) {
    cat("=== No Changes Requested ===\n")
    cat("No new Positron settings provided.\n")
    
    # Apply R profile settings if requested
    if (isTRUE(set.rprofile)) {
      cat("\nConfiguring R profile settings...\n")
      set_rprofile_settings()
    }
    
    return(invisible(NULL))
  }
  
  # Report changes to be made
  cat("=== Applying Settings Changes ===\n")
  
  # Helper function to normalize Windows paths for JSON
  normalize_path_for_json <- function(value) {
    if (is.character(value) && length(value) == 1) {
      # Check if this looks like a Windows path
      if (grepl("^[A-Za-z]:[/\\\\]", value)) {
        # Convert backslashes to forward slashes for JSON compatibility
        # This is the format Positron/VS Code expects
        value <- gsub("\\\\", "/", value)
      }
    }
    return(value)
  }
  
  # Apply settings
  changes_made <- FALSE
  
  # Check if we have a list of lists or a named list
  if (is.null(names(positron_settings))) {
    # List of lists format: list(list("setting", value), ...)
    for (i in seq_along(positron_settings)) {
      if (length(positron_settings[[i]]) >= 2) {
        setting <- positron_settings[[i]][[1]]
        value <- positron_settings[[i]][[2]]
        
        # Normalize paths for Windows
        value <- normalize_path_for_json(value)
        
        # Check if the setting needs to be updated
        if (is.null(settings[[setting]]) || !identical(settings[[setting]], value)) {
          old_value <- settings[[setting]]
          settings[[setting]] <- value
          changes_made <- TRUE
          cat("  ", setting, ": ", sep = "")
          
          if (is.null(old_value)) {
            cat("(new) ", format_value_for_display(value, ""), "\n", sep = "")
          } else {
            cat(format_value_for_display(old_value, ""), " -> ", 
                format_value_for_display(value, ""), "\n", sep = "")
          }
        } else {
          cat("  ", setting, ": already set to ", 
              format_value_for_display(value, ""), " (no change)\n", sep = "")
        }
      } else {
        warning("Skipping invalid setting at position ", i, " - requires both name and value")
      }
    }
  } else {
    # Named list format: list("setting" = value, ...)
    for (setting in names(positron_settings)) {
      value <- positron_settings[[setting]]
      
      # Normalize paths for Windows
      value <- normalize_path_for_json(value)
      
      # Check if the setting needs to be updated
      if (is.null(settings[[setting]]) || !identical(settings[[setting]], value)) {
        old_value <- settings[[setting]]
        settings[[setting]] <- value
        changes_made <- TRUE
        cat("  ", setting, ": ", sep = "")
        
        if (is.null(old_value)) {
          cat("(new) ", format_value_for_display(value, ""), "\n", sep = "")
        } else {
          cat(format_value_for_display(old_value, ""), " -> ", 
              format_value_for_display(value, ""), "\n", sep = "")
        }
      } else {
        cat("  ", setting, ": already set to ", 
            format_value_for_display(value, ""), " (no change)\n", sep = "")
      }
    }
  }
  
  # Write to file if changes were made
  if (changes_made) {
    tryCatch({
      cat("\n")
      jsonlite::write_json(settings, settings_file, pretty = TRUE, auto_unbox = TRUE)
      cat("Successfully updated settings.json\n")
      
      # Verify the file was written correctly
      test_read <- jsonlite::read_json(settings_file, simplifyVector = FALSE, simplifyDataFrame = FALSE)
      
    }, error = function(e) {
      cat("Error writing settings file:", e$message, "\n")
      stop("Failed to write settings to file. Please check file permissions.")
    })
  } else {
    cat("\nNo changes needed - all requested settings already have the correct values.\n")
  }
  
  # Apply R profile settings if requested
  if (isTRUE(set.rprofile)) {
    cat("\nConfiguring R profile settings...\n")
    set_rprofile_settings()
  }
  
  invisible(NULL)
}