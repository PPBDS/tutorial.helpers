#' @title Configure Positron Settings for Optimal Experience
#' 
#' @description
#' Locates or creates the Positron `settings.json` file on Windows or macOS,
#' then updates those settings to enhance the Positron experience for R users.
#' Key setting is including enabling RStudio keyboard shortcuts. The function can 
#' also optionally configure binary package preferences in the `.Rprofile`.
#'
#' @details
#' This function uses the `jsonlite` package to handle JSON operations and
#' creates the necessary directory structure if it doesn't exist. It is
#' designed to work cross-platform by detecting the operating system and
#' constructing the appropriate file path to Positron's user settings. The
#' function applies a predefined list of settings rather than requiring the
#' user to specify which settings to change.
#'
#' @param home_dir Optional character string specifying the base directory to use
#'   as the user's home directory. Defaults to `path.expand("~")`. Useful for
#'   testing or custom setups.
#' @param set.binary Logical, defaults to `TRUE`. If `TRUE`, runs
#'   `set_binary_only_in_r_profile()` after applying settings to configure binary
#'   options in the R profile.
#'
#' @return Invisible `NULL`. The function's purpose is its side effect: modifying
#'   or creating the `settings.json` file. It also prints messages to the console
#'   indicating actions taken.
#'
#' @examples
#' \dontrun{
#'   # Apply all recommended Positron settings
#'   set_positron_settings()
#'   
#'   # Apply settings with a custom home directory and disable binary setting
#'   set_positron_settings(home_dir = tempdir(), set.binary = FALSE)
#' }
#'
#' @importFrom jsonlite read_json write_json
#' @export

set_positron_settings <- function(home_dir = path.expand("~"), set.binary = TRUE) {
 
  # Use provided home_dir instead of calling path.expand("~") directly
  if (Sys.info()["sysname"] == "Windows") {
    settings_dir <- file.path(home_dir, "AppData", "Roaming", "Positron", "User")
  } else {  # macOS (or Linux, though Positron is primarily Win/macOS)
    settings_dir <- file.path(home_dir, "Library", "Application Support", "Positron", "User")
  }
  settings_file <- file.path(settings_dir, "settings.json")
  
  # Create directory if it doesn't exist
  if (!dir.exists(settings_dir)) {
    dir.create(settings_dir, recursive = TRUE)
    cat("Created directory:", settings_dir, "\n")
  }
  
  # Check if settings.json exists, create it if not
  if (!file.exists(settings_file)) {
    # Write an empty JSON object
    write_json(list(), settings_file, pretty = TRUE, auto_unbox = TRUE)
    cat("Created new settings.json at:", settings_file, "\n")
  }
  
  # Read the current settings
  settings <- read_json(settings_file, simplifyVector = TRUE)
  
  # Define the settings we want to apply
  positron_settings <- list(
    list("rstudio.keymap.enable", TRUE)
  )
  
  # Apply all settings in the list
  changes_made <- FALSE
  
  for (i in seq_along(positron_settings)) {
    setting <- positron_settings[[i]][[1]]
    value <- positron_settings[[i]][[2]]
    
    # Check if the setting needs to be updated
    if (is.null(settings[[setting]]) || !identical(settings[[setting]], value)) {
      settings[[setting]] <- value
      changes_made <- TRUE
      cat("Setting", setting, "to", as.character(value), "\n")
    }
  }
  
  # Write back to file if changes were made
  if (changes_made) {
    write_json(settings, settings_file, pretty = TRUE, auto_unbox = TRUE)
    cat("Updated settings in", settings_file, "\n")
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
