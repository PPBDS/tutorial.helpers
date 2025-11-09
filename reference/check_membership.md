# Check Membership in List of Tibbles

This function filters a list of tibbles based on whether a key
variable's value is among the membership values. It first uses
check_key_vars() to ensure the key variable exists, then checks
membership. Useful for keeping only specific students or participants.

## Usage

``` r
check_membership(tibble_list, key_var, membership, verbose = FALSE)
```

## Arguments

- tibble_list:

  A named list of tibbles, each containing an "id" column and an
  "answer" column

- key_var:

  A character string specifying the key variable to check

- membership:

  A character vector of allowed values for the key variable

- verbose:

  Logical indicating whether to report removed items (default: FALSE)

## Value

A list of tibbles where the key variable exists and its value is in the
membership list

## Examples

``` r
if (FALSE) { # \dontrun{
# Create sample data with student emails
path <- file.path(find.package("tutorial.helpers"), "tests/testthat/fixtures/answers_html")

tibble_list <- gather_submissions(path, "stop")

result <- check_membership(tibble_list, 
                           key_var = "email", 
                           membership = c("bluebird.jack.xu@gmail.com", 
                                          "hassan.alisoni007@gmail.com"))

} # }
```
