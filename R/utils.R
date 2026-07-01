# R/utils.R
#' Package build dependencies
#'
#' This function ensures renv detects quarto as a dependency
#' while keeping it in Suggests rather than Imports. It is deliberately
#' never called: its mere presence (referencing the quarto namespace) is
#' what makes renv record quarto. Do not delete it.
#' @keywords internal
.check_quarto <- function() {
  if (requireNamespace("quarto", quietly = TRUE)) {
    return(TRUE)
  }
  return(FALSE)
}