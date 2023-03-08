#' Check Current Tutorial
#'
#' @description
#'
#' An add-in for formatting all.primer.tutorials.
#'
#' It uses format_tutorial() to format the tutorial Rmd open
#' in the current editor
#'
#'
#' @return current document OVERWRITTEN and formatted with correct chunk labels

check_current_tutorial <- function(){

  file_path <- rstudioapi::getSourceEditorContext()$path

  new_doc <- format_tutorial(file_path)

  # This part just writes that reformatted document
  # to the file.

  out <- file(file_path, "w")
  write(trimws(new_doc), file = out)
  close(out)

}
