#' @title Insert Standard Population Table Template into Active Document
#'
#' @description Inserts a standardized Population table template with consistent
#'   titles, spanners, and placeholder content, ready to be filled in.
#'
#' @details The Population Table template always includes a "Source" column,
#'   with spanners for "Units/Time", "Potential Outcomes", and "Covariates".
#'   The user should edit the placeholder values and column labels as needed.
#'
#' @importFrom rstudioapi getActiveDocumentContext insertText
#'
#' @export
make_population <- function() {
  
  code <- '
tibble(
  Source = c("Data", "Preceptor", "..."),           # First column always "Source"
  Year = c("...", "...", "..."),                    # Time variable
  Location = c("...", "...", "..."),                # Unit context (e.g., City)
  ID = c("...", "...", "..."),                      # Unique unit IDs
  outcome = c("...", "...", "..."),                 # Observed or missing outcome
  covariate_1 = c("...", "...", "..."),
  covariate_2 = c("...", "...", "..."),
  covariate_3 = c("...", "...", "..."),
  "..." = c("...", "...", "...")
) |>
  gt() |>
  tab_header(
    title = "Population Table: [Describe Units and Time Here]"
  ) |>
  cols_label(
    Source = md("Source"),
    Year = md("Year"),
    Location = md("Location"),
    ID = md("Unit ID"),
    outcome = md("Outcome / Potential Outcome"),
    covariate_1 = md("[Covariate 1 Label]"),
    covariate_2 = md("[Covariate 2 Label]"),
    covariate_3 = md("[Covariate 3 Label]"),
    "..." = md("...")
  ) |>
  tab_spanner(label = "Units/Time", columns = c(Year, Location, ID)) |>
  tab_spanner(label = "Potential Outcomes", columns = c(outcome)) |>
  tab_spanner(label = "Covariates", columns = c(covariate_1, covariate_2, covariate_3, "...")) |>
  cols_align(align = "center", columns = everything()) |>
  cols_align(align = "left", columns = c(Source)) |>
  fmt_markdown(columns = everything())
'
  
  rstudioapi::insertText(
    location = rstudioapi::getActiveDocumentContext()$selection[[1]]$range,
    text = code
  )
}
