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
  Source = c("Data", "Preceptor", "..."),           # Edit sources as needed
  Year = c("...", "...", "..."),                    # Replace with actual years or time points
  Location = c("...", "...", "..."),                # Replace with relevant locations/units
  ID = c("...", "...", "..."),                      # Replace with unique unit IDs
  outcome = c("...", "...", "..."),                 # Replace with observed or potential outcomes
  covariate_1 = c("...", "...", "..."),             # Replace with first covariate values
  covariate_2 = c("...", "...", "..."),             # Replace with second covariate values
  covariate_3 = c("...", "...", "..."),             # Replace with third covariate values
  "..." = c("...", "...", "...")                    # Keep as placeholder for additional covariates
) |>
  gt() |>
  tab_header(
    title = "Population Table: [Describe Units and Time Here]"  # Edit title for your context
  ) |>
  cols_label(
    Source = md("Source"),
    Year = md("Year"),
    Location = md("Location"),
    ID = md("Unit ID"),
    outcome = md("Outcome / Potential Outcome"),
    covariate_1 = md("[Covariate 1 Label]"),          # Edit label
    covariate_2 = md("[Covariate 2 Label]"),          # Edit label
    covariate_3 = md("[Covariate 3 Label]"),          # Edit label
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
