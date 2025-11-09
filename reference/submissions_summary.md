# Process Submissions Summary

This function processes submissions from a local directory or Google
Drive folder containing HTML/XML files. It extracts tables from the
files, filters them based on a pattern and key variables, and returns
either a summary tibble or a combined tibble with all the data.

## Usage

``` r
submissions_summary(
  path,
  title = ".",
  return_value = "Summary",
  vars = NULL,
  verbose = FALSE,
  keep_file_name = NULL,
  emails = NULL
)
```

## Arguments

- path:

  The path to the local directory containing the HTML/XML files, or a
  Google Drive folder URL. If it's a Google Drive URL, the function will
  download individual files to a temporary directory.

- title:

  A character vector of patterns to match against the file names
  (default: "."). Each pattern is processed separately and results are
  combined.

- return_value:

  The type of value to return. Allowed values are "Summary" (default) or
  "All".

- vars:

  A character vector of key variables to extract from the "id" column
  (default: NULL).

- verbose:

  A logical value (TRUE or FALSE) specifying verbosity level. If TRUE,
  reports files that are removed during processing.

- keep_file_name:

  Specifies whether to keep the file name in the summary tibble. Allowed
  values are NULL (default), "All" (keep entire file name), "Space"
  (keep up to first space), or "Underscore" (keep up to first
  underscore). Only used when `return_value` is "Summary".

- emails:

  A character vector of email addresses to filter results by, "\*" to
  include all emails, or NULL to skip email filtering (default: NULL).

## Value

If `return_value` is "Summary", returns a tibble with one row for each
file, columns corresponding to the `vars`, and an additional "answers"
column indicating the number of rows in each tibble. If `return_value`
is "All", returns a tibble with all the data combined from all the
files.

## Examples

``` r
if (FALSE) { # \dontrun{
# Process submissions from local directory
path <- file.path(find.package("tutorial.helpers"), "tests/testthat/fixtures/answers_html")

result <- submissions_summary(path = path,
                             vars = "email",
                             title = "stop")

drive_url <- "https://drive.google.com/drive/folders/10do12t0fZsfrIrKePxwjpH8IqBNVO86N"
x <- submissions_summary(
  path = drive_url, 
  title = c("positron"),
  vars = c("email", "name")
)


} # }
```
