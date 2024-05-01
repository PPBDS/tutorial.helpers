#' @title Select smart setting for RStudio
#'
#' @description
#'
#' This function changes RStudio settings in order to make learning easier for
#' new users. These settings are stored in:
#' ~/.config/rstudio/rstudio-prefs.json. The most important changes are
#' `save_workspace` to `"never"`, `load_workspace` to `FALSE`, and
#' `"insert_native_pipe_operator"` to `TRUE`. All those changes are good for any
#' user, new or old.
#'
#' We also change `rmd_viewer_type` to `"pane"`, `show_hidden_files` to `TRUE`,
#' `rmd_chunk_output_inline` to `FALSE`, `source_with_echo` to `TRUE`, and
#' `packages_pane_enabled` to `FALSE`. These settings make RStudio less
#' confusing to new users. The `rmd_viewer_type` setting is especially useful to
#' students copy/pasting from the Console/Terminal to a tutorial.
#'
#' The last two changes are setting both `rainbow_parentheses` and
#' `syntax_color_console` to `TRUE`. We *think* that these settings make coding
#' errors less likely.
#'
#' @param set.binary Logical, set to `TRUE`, which indicates whether or not
#'   `set_binary_only_in_r_profile()` should be run at the end. 
#'
#' @returns No return value, called for side effects.
#'
#' @export

set_rstudio_settings <- function(set.binary = TRUE){
  
  # Change default settings in RStudio. Here are all the options:
  # https://docs.posit.co/ide/server-pro/reference/session_user_settings.html

  # Other settings which might be looked at include: initial_working_directory,
  # posix_terminal_shell, jobs_tab_visibility, default_project_location,
  # document_author, show_invisibles, sync_files_pane_working_dir, and
  # use_tiny_tex.
  
  settings <- list(
    list("save_workspace", "never"), 
    list("load_workspace", FALSE),
    list("insert_native_pipe_operator", TRUE),
    list("rmd_viewer_type", "pane"),
    list("show_hidden_files", TRUE),
    list("rmd_chunk_output_inline", FALSE),
    list("source_with_echo", TRUE),
    list("packages_pane_enabled", FALSE),
    list("rainbow_parentheses", TRUE),
    list("syntax_color_console", TRUE)
  )
  
  changes_made <- FALSE
  
  for(i in seq(length(settings))){
    setting <- settings[[i]][[1]]
    value <- settings[[i]][[2]]
    if(rstudioapi::readRStudioPreference(setting, NA) != value){
      changes_made <- TRUE
      message(paste0("Changing ",  setting, " to ", value, "."))
      rstudioapi::writeRStudioPreference(setting, value)
    }
  }
  
  if(isFALSE(changes_made)){
    message("RStudio settings are already sensible. No changes made.")
  } 
  
  if(isTRUE(set.binary)){
    set_binary_only_in_r_profile()
  }
}
