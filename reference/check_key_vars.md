# Check Key Variables in List of Tibbles

This function checks if specified key variables are present in each
tibble's "id" column and returns only tibbles that contain all required
key variables.

## Usage

``` r
check_key_vars(tibble_list, key_vars, verbose = FALSE)
```

## Arguments

- tibble_list:

  A named list of tibbles, each containing an "id" column with question
  identifiers

- key_vars:

  A character vector of key variables to check for

- verbose:

  A logical value (TRUE or FALSE) specifying verbosity level. If TRUE,
  reports tibbles that are removed and why.

## Value

A list of tibbles that contain all required key variables

## Examples

``` r
if (FALSE) { # \dontrun{
# Create sample data
path <- file.path(find.package("tutorial.helpers"), "tests/testthat/fixtures/answers_html")

tibble_list <- gather_submissions(path, "stop")

result <- check_key_vars(tibble_list, 
                         key_vars = c("name", "email"))

} # }
```
