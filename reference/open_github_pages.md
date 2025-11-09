# Open Multiple GitHub Pages in Browser Tabs

This function opens multiple GitHub.io pages in browser tabs, making it
easy for teaching fellows to quickly review student webpages. It can
accept either a vector of URLs or a tibble/data.frame containing URLs.

## Usage

``` r
open_github_pages(
  urls,
  url_var = NULL,
  label_var = NULL,
  delay_seconds = 0.5,
  browser = "default",
  verbose = FALSE
)
```

## Arguments

- urls:

  Either a character vector of URLs to open, OR a tibble/data.frame
  containing submission data with a URL column

- url_var:

  Character string specifying the column name containing URLs. Required
  when urls is a tibble/data.frame. Ignored when urls is a character
  vector.

- label_var:

  Character string specifying the column name to use for identifying
  each submission in verbose output (e.g., "name", "email"). Only used
  when urls is a tibble/data.frame.

- delay_seconds:

  Numeric value specifying delay between opening each URL (default is
  0.5 seconds to allow browser to process each request)

- browser:

  Character string specifying which browser to use. Options are
  "default" (system default), "chrome", "firefox", "safari", or "edge".
  On Windows, also supports "msedge". Default is "default".

- verbose:

  Logical value (TRUE or FALSE) specifying verbosity level. If TRUE,
  reports each URL as it's being opened.

## Value

Invisible NULL. Function is called for its side effect of opening
browser tabs.

## Details

The function uses the system's default method to open URLs, which
typically opens them in the default browser. Most modern browsers will
open multiple URLs as tabs in the same window when called in quick
succession.

The delay between opening URLs helps ensure the browser has time to
process each request properly. You may need to adjust this delay based
on your system performance and browser behavior.

## Examples

``` r
if (FALSE) { # \dontrun{
# Open multiple GitHub Pages from vector
student_sites <- c("https://github.com/Abdul-Hannan96/stops.git")

open_github_pages(student_sites, verbose = TRUE)

# Open from tibble/data.frame
path <- file.path(find.package("tutorial.helpers"), "tests/testthat/fixtures/answers_html")

result <- submissions_answers(
  path = path,
  title = c("stop"), 
  key_var = "email",
  membership = c("bluebird.jack.xu@gmail.com", "abdul.hannan20008@gmail.com"),
  vars = c("name","email","temperance-15"),
  verbose = TRUE
)

open_github_pages(result, 
                  url_var = "temperance-15",
                  verbose = TRUE)
} # }
```
