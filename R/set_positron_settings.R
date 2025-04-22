#' @title Configure Positron Settings
#' 
#' @description
#' Locates or creates the Positron `settings.json` file on Windows or macOS,
#' then updates those settings based on the provided configuration list.
#' Users can specify settings like RStudio keyboard shortcuts. The function can 
#' also optionally configure binary package preferences in the `.Rprofile`.
#'
#' @details
#' This function uses the `jsonlite` package to handle JSON operations and
#' creates the necessary directory structure if it doesn't exist. It is
#' designed to work cross-platform by detecting the operating system and
#' constructing the appropriate file path to Positron's user settings. The
#' function applies the settings provided in the `positron_settings` parameter.
#' By default, no settings are changed unless explicitly specified.
#'
#' @param home_dir Optional character string specifying the base directory to use
#'   as the user's home directory. Defaults to `path.expand("~")`. Useful for
#'   testing or custom setups.
#' @param set.binary Logical, defaults to `TRUE`. If `TRUE`, runs
#'   `set_binary_only_in_r_profile()` after applying settings to configure binary
#'   options in the R profile.
#' @param positron_settings List of settings to apply. Can be structured as a list of 
#'   lists where each sub-list contains a setting name and value (e.g., 
#'   `list(list("rstudio.keymap.enable", TRUE))`), or as a named list 
#'   (e.g., `list("rstudio.keymap.enable" = TRUE)`). Defaults to an empty list,
#'   which means no settings will be changed.
#'
#' @return Invisible `NULL`. The function's purpose is its side effect: modifying
#'   or creating the `settings.json` file. It also prints messages to the console
#'   indicating actions taken.
#'
#' @examples
#' \dontrun{
#'   # Apply no settings changes, but ensure settings.json exists
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
#'   # Apply settings with a custom home directory and disable binary setting
#'   set_positron_settings(
#'     home_dir = tempdir(), 
#'     set.binary = FALSE,
#'     positron_settings = list("rstudio.keymap.enable" = TRUE)
#'   )
#' }
#'
#' @importFrom jsonlite read_json write_json
#' @export

set_positron_settings <- function(home_dir = path.expand("~"), set.binary = TRUE, 
                                 positron_settings = list()) {
 
  # Use provided home_dir instead of calling path.expand("~") directly
  if (Sys.info()["sysname"] == "Windows") {
    settings_dir <- file.path(home_dir, "AppData", "Roaming", "Positron", "User")
  } else {  # macOS (or Linux, though Positron is primarily Win/macOS)
    settings_dir <- file.path(home_dir, "Library", "Application Support", "Positron", "User")
  }
  settings_file <- file.path(settings_dir, "settings.json")
  
  # Initialize settings as empty list
  settings <- list()
  
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
        cat("Settings file exists but is empty. Will create new file.\n")
        file_exists <- FALSE
      } else {
        settings <- jsonlite::read_json(settings_file, simplifyVector = TRUE)
        cat("Found existing settings file:", settings_file, "\n")
        file_exists <- TRUE
      }
    }, error = function(e) {
      cat("Error reading settings file:", e$message, "\n")
      cat("Will create a new settings file\n")
      file_exists <- FALSE
    })
  }
  
  # Create a new file with valid JSON if needed
  if (!file_exists) {
    tryCatch({
      jsonlite::write_json(list(), settings_file, pretty = TRUE, auto_unbox = TRUE)
      cat("Created new empty settings.json at:", settings_file, "\n")
    }, error = function(e) {
      cat("Error creating settings file:", e$message, "\n")
      # If we can't create the file, we should stop
      stop("Unable to create settings file. Please check directory permissions.")
    })
    
    # Re-read the newly created file to make sure it's valid
    tryCatch({
      settings <- jsonlite::read_json(settings_file, simplifyVector = TRUE)
      file_exists <- TRUE
    }, error = function(e) {
      cat("Error reading newly created settings file:", e$message, "\n")
      stop("Unable to read settings file after creation. Please check file permissions.")
    })
  }
  
  # Handle empty settings list
  if (length(positron_settings) == 0) {
    cat("No settings provided. No changes made to", settings_file, "\n")
    
    # Apply binary settings if requested
    if (isTRUE(set.binary)) {
      cat("Running set_binary_only_in_r_profile() to configure binary options.\n")
      set_binary_only_in_r_profile()
    }
    
    return(invisible(NULL))
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
        
        # Check if the setting needs to be updated
        if (is.null(settings[[setting]]) || !identical(settings[[setting]], value)) {
          settings[[setting]] <- value
          changes_made <- TRUE
          cat("Setting", setting, "to", 
              if (is.logical(value)) as.character(value) else paste0('"', value, '"'), "\n")
        }
      } else {
        warning("Skipping invalid setting at position ", i, " - requires both name and value")
      }
    }
  } else {
    # Named list format: list("setting" = value, ...)
    for (setting in names(positron_settings)) {
      value <- positron_settings[[setting]]
      
      # Check if the setting needs to be updated
      if (is.null(settings[[setting]]) || !identical(settings[[setting]], value)) {
        settings[[setting]] <- value
        changes_made <- TRUE
        cat("Setting", setting, "to", 
            if (is.logical(value)) as.character(value) else paste0('"', value, '"'), "\n")
      }
    }
  }
  
  # Write to file if changes were made
  if (changes_made) {
    tryCatch({
      jsonlite::write_json(settings, settings_file, pretty = TRUE, auto_unbox = TRUE)
      cat("Updated settings in", settings_file, "\n")
    }, error = function(e) {
      cat("Error writing settings file:", e$message, "\n")
      stop("Failed to write settings to file. Please check file permissions.")
    })
  } else {
    cat("No settings changes needed in", settings_file, "\n")
  }
  
  # Apply binary settings if requested
  if (isTRUE(set.binary)) {
    cat("Running set_binary_only_in_r_profile() to configure binary options.\n")
    set_binary_only_in_r_profile()
  }
  
  invisible(NULL)
}
