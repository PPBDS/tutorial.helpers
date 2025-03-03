#' @title Select Good Positron Settings
#' @description
#' Locates or creates the Positron `settings.json` file on Windows or macOS,
#' then ensures the `"rstudio.keymap.enable": true` setting is present to enable
#' RStudio keyboard shortcuts. If the setting already exists and is `true`, no
#' changes are made; otherwise, it is added or updated. `set.binary` argument 
#' determines if `options(pkgType = 'binary')` should be added to the `.Rprofile`.
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
#' @param set.binary Logical, defaults to `TRUE`. If `TRUE`, runs
#'   `set_binary_only_in_r_profile()` after applying settings to configure binary
#'   options in the R profile.
#'
#' @return Invisible `NULL`. The function’s purpose is its side effect: modifying
#'   or creating the `settings.json` file. It also prints messages to the console
#'   indicating actions taken.
#'
#' @examples
#' \dontrun{
#'   # Run the function with default settings
#'   set_positron_settings()
#'   # Run with a custom home directory and disable binary setting
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
  
  # Apply binary settings if requested
  if (isTRUE(set.binary)) {
    set_binary_only_in_r_profile()
    cat("Ran set_binary_only_in_r_profile() to configure binary options.\n")
  }
  
  invisible(NULL)
}
