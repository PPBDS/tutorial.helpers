# Return all the paths to the tutorials in a package

Takes a package name and returns a character vector of all the paths to
tutorials in the installed package. This function looks for all R
Markdown files (.Rmd) in the inst/tutorials/ subdirectories of the
specified package. It uses learnr::available_tutorials() to identify
tutorial directories, with a fallback to directory scanning if that
fails.

## Usage

``` r
return_tutorial_paths(package)
```

## Arguments

- package:

  Character string of the package name to be tested.

## Value

Character vector of the full paths to all installed tutorials in
`package`. Returns character(0) if no tutorials are found or if the
package doesn't exist.

## Details

The function first checks if the package is installed and has a
tutorials directory. It then attempts to use
learnr::available_tutorials() to get the official list of tutorial
directories. If that fails (e.g., if the package doesn't properly
register its tutorials with learnr), it falls back to scanning all
subdirectories under inst/tutorials/. Finally, it collects all .Rmd
files from these directories.

Returns an empty character vector if the package has no tutorials or
doesn't exist, rather than throwing an error.

## Examples

``` r
if (FALSE) { # \dontrun{
  # Get all learnr tutorial paths
  return_tutorial_paths('learnr')
  
  # Get tutorial paths from your own package
  return_tutorial_paths('tutorial.helpers')
  
  # Returns empty vector for packages without tutorials
  return_tutorial_paths('base')
} # }
  
```
