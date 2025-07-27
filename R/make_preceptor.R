#' @title Insert Standard Preceptor Table Template into Active Document
#'
#' @description Inserts a standardized Preceptor table template with consistent
#'   titles, spanners, and placeholder content, ready to be customized.
#'
#' @details The Preceptor Table template includes spanners for "Units", "Potential Outcomes",
#'   and "Covariates". The title should specify the units and time relevant to the
#'   underlying question. Users should fill in the placeholder text and column labels.
#'
#' @importFrom rstudioapi getActiveDocumentContext insertText
#'
#' @export
make_preceptor <- function() {
  
  code <- '
tibble(
  ID = c("...", "...", "..."),                      # Replace with unique unit IDs
  outcome = c("...", "...", "..."),                 # Replace with predicted or potential outcomes
  covariate_1 = c("...", "...", "..."),             # Replace with first covariate values
  covariate_2 = c("...", "...", "..."),             # Replace with second covariate values
  covariate_3 = c("...", "...", "..."),             # Replace with third covariate values
  "..." = c("...", "...", "...")                    # Keep as placeholder for additional covariates
) |>
  gt() |>
  tab_header(
    title = "Preceptor Table: [Describe Units and Time Here]"  # Edit title to reflect your context
  ) |>
  cols_label(
    ID = md("Unit ID"),
    outcome = md("Outcome / Potential Outcome"),
    covariate_1 = md("[Covariate 1 Label]"),          # Edit label
    covariate_2 = md("[Covariate 2 Label]"),          # Edit label
    covariate_3 = md("[Covariate 3 Label]"),          # Edit label
    "..." = md("...")
  ) |>
  tab_spanner(label = "Units", columns = c(ID)) |>
  tab_spanner(label = "Potential Outcomes", columns = c(outcome)) |>
  tab_spanner(label = "Covariates", columns = c(covariate_1, covariate_2, covariate_3, "...")) |>
  cols_align(align = "center", columns = everything()) |>
  cols_align(align = "left", columns = c(ID)) |>
  fmt_markdown(columns = everything())
'
  
  rstudioapi::insertText(
    location = rstudioapi::getActiveDocumentContext()$selection[[1]]$range,
    text = code
  )
}
