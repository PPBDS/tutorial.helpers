#' Check current tutorial
#'
#' @description
#'
#' A function which formats the exercise numbers and code chunk
#' labels correctly. `check_current_tutorial()` reads in the tutorial
#' which is in the active editor window in Positron. It determines what 
#' the number of each exercise should be and fixes any mistakes. It
#' ensures that all code chunk labels are the correct function of the 
#' section title and exercise number.
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
