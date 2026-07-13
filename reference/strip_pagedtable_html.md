# Remove embedded pagedtable HTML artifacts from a vector of lines

VS Code's interactive chunk execution can cache a chunk's rendered
output directly back into the .qmd/.Rmd source file. When the chunk's
output is a tibble, that cached output is a pagedtable HTML widget (a
`<div data-pagedtable="false">` block wrapping a
`<script data-pagedtable-source>` JSON blob). Because this cached output
can end up inside the same fenced region as the code itself,
show_file()'s chunk extraction can otherwise return this HTML noise
instead of clean source code. This helper strips any such blocks out of
a character vector of lines before they are printed.

## Usage

``` r
strip_pagedtable_html(lines)
```

## Arguments

- lines:

  A character vector of lines (as returned by readLines()).

## Value

A character vector with any pagedtable HTML blocks removed.
