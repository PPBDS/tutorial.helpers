#' @title Enable RStudio Keymap in Positron Settings
#' @description
#' Locates or creates the Positron `settings.json` file on Windows or macOS,
#' then ensures the `"rstudio.keymap.enable": true` setting is present to enable
#' RStudio keyboard shortcuts. If the setting already exists and is `true`, no
#' changes are made; otherwise, it is added or updated.
#'
#' @details
#' This function uses the `jsonlite` package to handle JSON operations and
#' creates the necessary directory structure if it doesn’t exist. It is
#' designed to work cross-platform by detecting the operating system and
#' constructing the appropriate file path to Positron’s user settings.
#'
#' @param home_dir Optional character string specifying the base directory to use
#'   as the user's home directory. Defaults to `path.expand("~")`. Useful for
#'   testing or custom setups.
#'
#' @return Invisible `NULL`. The function’s purpose is its side effect: modifying
#' or creating the `settings.json` file. It also prints messages to the console
#' indicating actions taken.
#'
#' @examples
#' \dontrun{
#'   # Run the function with default home directory
#'   set_positron_rstudio_keymap()
#'   # Run with a custom home directory for testing
#'   set_positron_rstudio_keymap(home_dir = tempdir())
#' }
#'
#' @importFrom jsonlite read_json write_json
#' @export

set_positron_rstudio_keymap <- function(home_dir = path.expand("~")) {
  
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
  
  # Check if "rstudio.keymap.enable" is already TRUE
  if (is.null(settings[["rstudio.keymap.enable"]]) || 
      settings[["rstudio.keymap.enable"]] != TRUE) {
    # Add or update the setting
    settings[["rstudio.keymap.enable"]] <- TRUE
    # Write back to file with proper formatting
    write_json(settings, settings_file, pretty = TRUE, auto_unbox = TRUE)
    cat("Added/updated 'rstudio.keymap.enable': true in", settings_file, "\n")
  } else {
    cat("'rstudio.keymap.enable' is already true in", settings_file, "\n")
  }
}