# R/utils.R
#' Package build dependencies
#' 
#' This function ensures renv detects quarto as a dependency
#' while keeping it in Suggests rather than Imports.
#' @keywords internal
.check_quarto <- function() {
  if (requireNamespace("quarto", quietly = TRUE)) {
    return(TRUE)
  }
  return(FALSE)
}