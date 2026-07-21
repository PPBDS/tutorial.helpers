# Match Questions by Pattern

This function takes a single HTML file or tibble and finds all
questions/answers that contain a specified pattern. It returns the
question IDs (from the 'id' column) for rows where the answer contains
the pattern.

## Usage

``` r
match_questions(x, pattern, ignore.case = TRUE)
```

## Arguments

- x:

  Either a file path to an HTML file or a tibble with 'id' and
  'answer'/'data' columns

- pattern:

  A character string to search for in the answers

- ignore.case:

  Logical; should the search be case-insensitive? (default: TRUE)

## Value

A character vector of question IDs where the answer contains the pattern

## Examples

``` r
# Search in a tibble
path <- system.file("extdata", "answers_html", package = "tutorial.helpers")

tibble <- gather_submissions(path, title = "stop")[[1]]

result <- match_questions(tibble, "http")

if (FALSE) { # \dontrun{
# Search in an HTML file
question_ids <- match_questions("path/to/submission.html", "temperance")
# Returns: c("temperance-16", "temperance-19")
} # }
```
