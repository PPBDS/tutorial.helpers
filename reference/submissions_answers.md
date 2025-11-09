# Extract Answers from Submissions with Filtering

This function gathers submissions matching a title pattern, filters them
by membership, and extracts specified variables, returning a tibble with
one row per valid submission and one column per variable.

## Usage

``` r
submissions_answers(
  path,
  title,
  key_var = NULL,
  membership = NULL,
  vars,
  keep_file_name = NULL,
  verbose = FALSE
)
```

## Arguments

- path:

  The path to the local directory or Google Drive folder URL containing
  submissions

- title:

  A character vector of patterns to match against file names (passed to
  gather_submissions)

- key_var:

  A character string specifying the key variable to check for membership
  (e.g., "email"). If NULL (default), no membership filtering is
  applied.

- membership:

  A character vector of allowed values for the key variable, or "\*" to
  include all submissions. If NULL (default), no membership filtering is
  applied. Ignored if key_var is NULL.

- vars:

  A character vector of variables/questions to extract, or "\*" to
  extract all available variables

- keep_file_name:

  How to handle file names: NULL (don't include), "All" (full name),
  "Space" (up to first space), "Underscore" (up to first underscore)

- verbose:

  A logical value (TRUE or FALSE) specifying verbosity level. If TRUE,
  reports files that are removed during processing.

## Value

A tibble with one row per valid submission, columns for each variable,
and optionally a "source" column

## Examples

``` r
if (FALSE) { # \dontrun{
# Extract specific variables from submissions matching title pattern
path <- file.path(find.package("tutorial.helpers"), "tests/testthat/fixtures/answers_html")

result <- submissions_answers(
  path = path,
  title = c("stop"), 
  key_var = "email",
  membership = c("bluebird.jack.xu@gmail.com", "abdul.hannan20008@gmail.com"),
  vars = c("name", "email", "introduction-1"),
  verbose = TRUE
)

# Extract all variables from submissions
result_all <- submissions_answers(
  path = path,
  title = c("stop"), 
  key_var = "email",
  membership = c("bluebird.jack.xu@gmail.com", "abdul.hannan20008@gmail.com"),
  vars = "*",
  verbose = TRUE
)

drive_url <- "https://drive.google.com/drive/folders/10do12t0fZsfrIrKePxwjpH8IqBNVO86N"
x <- submissions_answers(
  path = drive_url, 
  title = c("introduction"),
  key_var = "email",
  membership = c("fmehmud325@gmail.com"),
  vars = c("email", "name", "what-you-will-learn-15")
)
} # }
```
