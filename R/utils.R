#' Check Quarto Availability
#' 
#' This function ensures quarto is available if needed for rendering.
#' @export
ensure_quarto <- function() {
  if (requireNamespace("quarto", quietly = TRUE)) {
    # Minimal call to satisfy R CMD check and renv
    invisible(quarto::quarto_version())
  } else {
    message("quarto is not installed. Install it with install.packages('quarto') if needed.")
  }
}
