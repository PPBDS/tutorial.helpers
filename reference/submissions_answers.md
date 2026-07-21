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
# Extract specific variables from submissions matching title pattern
path <- system.file("extdata", "answers_html", package = "tutorial.helpers")

result <- submissions_answers(
  path = path,
  title = c("stop"), 
  key_var = "email",
  membership = c("bluebird.jack.xu@gmail.com", "abdul.hannan20008@gmail.com"),
  vars = c("name", "email", "introduction-1"),
  verbose = TRUE
)
#> Found 3 submission(s) matching title pattern 'stop'
#> After membership filtering: 2 submission(s) retained

# Extract all variables from submissions
result_all <- submissions_answers(
  path = path,
  title = c("stop"), 
  key_var = "email",
  membership = c("bluebird.jack.xu@gmail.com", "abdul.hannan20008@gmail.com"),
  vars = "*",
  verbose = TRUE
)
#> Found 3 submission(s) matching title pattern 'stop'
#> After membership filtering: 2 submission(s) retained
#> Extracting all available variables: tutorial-id, name, email, introduction-1, the-question-1, the-question-2, the-question-3, the-question-4, the-question-5, the-question-6, the-question-7, the-question-8, the-question-9, the-question-10, wisdom-1, wisdom-2, wisdom-3, wisdom-4, wisdom-5, wisdom-6, wisdom-7, wisdom-8, wisdom-9, wisdom-10, wisdom-11, wisdom-12, wisdom-13, wisdom-14, wisdom-15, wisdom-16, wisdom-17, wisdom-18, justice-1, justice-2, justice-3, justice-4, justice-5, justice-6, justice-7, justice-8, justice-9, courage-1, courage-2, courage-3, courage-5, courage-6, courage-7, courage-8, courage-9, courage-10, courage-11, courage-12, courage-13, courage-15, courage-17, courage-18, courage-19, courage-20, courage-21, courage-22, courage-23, temperance-1, temperance-2, temperance-3, temperance-4, temperance-5, temperance-6, temperance-7, temperance-8, temperance-9, temperance-10, temperance-11, temperance-12, temperance-13, temperance-14, temperance-15, minutes, courage-4

if (FALSE) { # \dontrun{
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
