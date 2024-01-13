#' @title Select smart setting for RStudio
#'
#' @description
#'
#' This function changes RStudio settings in order to make learning easier for
#' new users. These settings are stored in:
#' ~/.config/rstudio/rstudio-prefs.json. The most important changes are
#' `save_workspace` to `"never"`, `load_workspace` to `FALSE`, and
#' `"insert_native_pipe_operator"` to `TRUE`.
#'
#' @returns No return value, called for side effects.
#'
#' @export

set_rstudio_settings <- function(){

  # Change default settings in RStudio. Here all are settings:
  # https://docs.posit.co/ide/server-pro/reference/session_user_settings.html
  
  # Could have a better message which first checks to see if any changes need to
  # be made and then announces what changes it is making, if any.

  message("Changing RStudio settings to better defaults.")

  # These first three are definitely a good idea. Perhaps the function should, by
  # default, report all the changes it is making. If so, then we probably need
  # to write a loop which takes in a list of parameter/value pairs and then goes
  # through them all, reporting "Changing X from A to B."
  
  rstudioapi::writeRStudioPreference("save_workspace", "never")
  rstudioapi::writeRStudioPreference("load_workspace", FALSE)
  rstudioapi::writeRStudioPreference("insert_native_pipe_operator", TRUE)
  
  # The remaining changes are more debatable. I think that the next three
  # decrease student confusion.
  
  rstudioapi::writeRStudioPreference("show_hidden_files", TRUE)
  rstudioapi::writeRStudioPreference("rmd_chunk_output_inline", FALSE)
  rstudioapi::writeRStudioPreference("source_with_echo", TRUE)
  
  # The packages pane is nothing but distracting.
  
  rstudioapi::writeRStudioPreference("packages_pane_enabled", FALSE)
  
  # I think that these make code writing easier. Don't they?
  
  rstudioapi::writeRStudioPreference("rainbow_parentheses", TRUE)
  rstudioapi::writeRStudioPreference("syntax_color_console", TRUE)
  
  # Other settings which might be looked at include: initial_working_directory,
  # posix_terminal_shell, jobs_tab_visibility, default_project_location,
  # document_author, show_invisibles, sync_files_pane_working_dir, and
  # use_tiny_tex.

}
