# Display the contents of a text file that match a pattern

This function reads the contents of a text file and either prints the
specified range of rows that match a given regular expression pattern,
prints the code lines within code chunks, or extracts the YAML header.
If start is a negative number, it prints the last abs(start) lines,
ignoring missing lines at the end of the file. If start is 0, it prints
the entire file.

## Usage

``` r
show_file(path, start = 1, end = NULL, pattern = NULL, chunk = "None")
```

## Arguments

- path:

  A character vector representing the path to the text file.

- start:

  An integer specifying the starting row number (inclusive) to consider.
  Default is 1. If negative, it represents the number of lines to print
  from the end of the file. If 0, prints the entire file.

- end:

  An integer specifying the ending row number (inclusive) to consider.
  Default is the last row.

- pattern:

  A regular expression pattern to match against each row. Default is
  NULL (no pattern matching). Applied to the whole-file (`start == 0`),
  last-lines (`start < 0`), and row-range cases; ignored when `chunk` is
  "All", "Last", or "YAML".

- chunk:

  A character string indicating what content to extract. Possible values
  are "None" (default - no chunk processing), "All" (print all code
  chunks), "Last" (print only the last code chunk), or "YAML" (extract
  the YAML header without delimiters). Code chunks of any language are
  recognized (e.g. `r`, `python`, `bash`), not just R.

## Value

The function prints the contents of the specified range of rows that
match the pattern (if provided), the code lines within R code chunks (if
chunk is "All" or "Last"), or the YAML header content (if chunk is
"YAML") to the console. If no rows match the pattern, nothing is
printed. If start is negative, the function prints the last abs(start)
lines, ignoring missing lines at the end of the file. If start is 0, the
function prints the entire file.

## Details

The arguments are resolved in a fixed order of precedence:
`chunk = "YAML"` is handled first, then `start == 0` (whole file), then
`start < 0` (last abs(start) lines), then `chunk %in% c("All", "Last")`
(code chunks), and finally the `start`/`end` row range. The `pattern`
filter is applied within the whole-file, last-lines, and row-range
cases, but is ignored when `chunk` selects code chunks or the YAML
header.

## Examples

``` r
if (FALSE) { # \dontrun{
# Display all rows of a text file
show_file("path/to/your/file.txt")

# Display the entire file
show_file("path/to/your/file.txt", start = 0)

# Display rows 5 to 10 of a text file
show_file("path/to/your/file.txt", start = 5, end = 10)

# Display all rows of a text file that contain the word "example"
show_file("path/to/your/file.txt", pattern = "example")

# Print all code lines within R code chunks
show_file("path/to/your/file.txt", chunk = "All")

# Print only the last R code chunk
show_file("path/to/your/file.txt", chunk = "Last")

# Extract the YAML header
show_file("path/to/your/file.Rmd", chunk = "YAML")

# Display the last 5 lines of a text file, ignoring missing lines at the end
show_file("path/to/your/file.txt", start = -5)
} # }
```
