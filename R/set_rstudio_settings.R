#' @title Select smart setting for RStudio
#'
#' @description
#'
#' This functions selects RStudio settings which make learning easier for new
#' users. These settings are stored in: ~/.config/rstudio/rstudio-prefs.json.
#' The most important changes are `save_workspace` to `"never"`,
#' `load_workspace` to `FALSE`, and `"insert_native_pipe_operator"` to `TRUE`.
#'
#' @returns No return value, called for side effects.
#'
#' @export

set_rstudio_settings <- function(){

  # Change default settings in RStudio. Here all are settings:
  # https://docs.posit.co/ide/server-pro/reference/session_user_settings.html

  message("Changing RStudio settings to better defaults.")

  rstudioapi::writeRStudioPreference("save_workspace", "never")
  rstudioapi::writeRStudioPreference("load_workspace", FALSE)
  rstudioapi::writeRStudioPreference("insert_native_pipe_operator", TRUE)
  rstudioapi::writeRStudioPreference("show_hidden_files", TRUE)
  rstudioapi::writeRStudioPreference("rmd_viewer_type", "pane")

  # The first three are definitely good. The last two are more debatable . . .
  
  # Other settings which might be looked at include: document_author,
  # packages_pane_enabled, always_write_history, rainbow_parantheses,
  # show_invisibles, show_rmd_render_commit, sync_files_pane_working_dir,
  # syntax_color_console and use_tiny_tex.

}
