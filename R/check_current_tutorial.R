#' Check current tutorial
#'
#' @description
#'
#' An add-in for formatting tutorials.
#'
#' Uses format_tutorial() to format the tutorial Rmd open
#' in the current editor
#'
#' @export

check_current_tutorial <- function(){

  file_path <- rstudioapi::getSourceEditorContext()$path

  new_doc <- format_tutorial(file_path)

  # This part just writes that reformatted document
  # to the file.

  out <- file(file_path, "w")
  write(trimws(new_doc), file = out)
  close(out)
}
