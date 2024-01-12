#' @title Select smart setting for RStudio
#'
#' @description
#'
#' This function changes RStudio settings in order to make learning easier for
#' new users. These settings are stored in:
#' ~/.config/rstudio/rstudio-prefs.json. The most important changes are
#' `save_workspace` to `"never"`, `load_workspace` to `FALSE`,
#' `"insert_native_pipe_operator"` to `TRUE`, and
#' `"visual_markdown_editing_is_default"` to `FALSE`.
#'
#' @returns No return value, called for side effects.
#'
#' @export

set_rstudio_settings <- function(){

  # Change default settings in RStudio. Here all are settings:
  # https://docs.posit.co/ide/server-pro/reference/session_user_settings.html

  message("Changing RStudio settings to better defaults.")

  # These first four are definitely a good idea. Perhaps the function should, by
  # default, report all the changes it is making. If so, then we probably need
  # to write a loop which takes in a list of parameter/value pairs and then goes
  # through them all, reporting "Changing X from A to B."
  
  rstudioapi::writeRStudioPreference("save_workspace", "never")
  rstudioapi::writeRStudioPreference("load_workspace", FALSE)
  rstudioapi::writeRStudioPreference("insert_native_pipe_operator", TRUE)
  rstudioapi::writeRStudioPreference("visual_markdown_editing_is_default", FALSE)
  
  # The remaining changes are more debatable.
  
  rstudioapi::writeRStudioPreference("show_hidden_files", TRUE)
  rstudioapi::writeRStudioPreference("rmd_chunk_output_inline", FALSE)
  rstudioapi::writeRStudioPreference("show_hidden_files", TRUE)
  rstudioapi::writeRStudioPreference("source_with_echo", TRUE)
  rstudioapi::writeRStudioPreference("packages_pane_enabled", FALSE)
  rstudioapi::writeRStudioPreference("always_save_history", FALSE)
  rstudioapi::writeRStudioPreference("rainbow_parentheses", TRUE)
  rstudioapi::writeRStudioPreference("syntax_color_console", TRUE)
  rstudioapi::writeRStudioPreference("auto_append_newline", TRUE)
  
  # Other settings which might be looked at include: document_author,
  # show_invisibles, sync_files_pane_working_dir, and use_tiny_tex.

}
