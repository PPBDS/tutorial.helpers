# Gather Submissions

This function finds and reads HTML/XML files from a local directory or
Google Drive folder that match specified patterns. It extracts tables
from the files and returns a list of tibbles containing the submission
data.

## Usage

``` r
gather_submissions(path, title, keep_loc = NULL, verbose = FALSE)
```

## Arguments

- path:

  The path to the local directory containing the HTML/XML files, or a
  Google Drive folder URL. If it's a Google Drive URL, the function will
  download the entire folder to a temporary directory.

- title:

  A character vector of patterns to match against the file names. Each
  pattern is processed separately and results are combined.

- keep_loc:

  A character string specifying where to save downloaded files (only for
  Google Drive URLs). If NULL (default), files are downloaded to a
  temporary directory and deleted after processing. If specified, files
  are downloaded to this location and kept.

- verbose:

  A logical value (TRUE or FALSE) specifying verbosity level. If TRUE,
  reports files that are removed during processing.

## Value

A named list of tibbles, where each tibble contains the data from one
HTML/XML file that matches any of the specified patterns and has valid
table structure.

## Details

Google Drive allows for more than one file with the exact same name. If
you download files manually ("by hand"), you will get both files but
with one of them automatically renamed by your browser. However, if you
use the Google Drive functionality in this function, the second file
will overwrite the first, potentially resulting in data loss.

## Examples

``` r
if (FALSE) { # \dontrun{
# Find submissions from local directory

path <- file.path(find.package("tutorial.helpers"), "tests/testthat/fixtures/answers_html")

tibble_list <- gather_submissions(path = path, title = "stop", verbose = TRUE)

# Find submissions from Google Drive folder (temporary download)
drive_url <- "https://drive.google.com/drive/folders/10do12t0fZsfrIrKePxwjpH8IqBNVO86N"
tibble_list <- gather_submissions(
  path = drive_url, 
  title = c("positron")
)

# Find submissions from Google Drive folder (keep files)
tibble_list <- gather_submissions(
  path = drive_url, 
  title = c("introduction"),
  keep_loc = "temp_file"
)
} # }
```
