# Format RMarkdown tutorial code chunks

This function processes an R Markdown tutorial file to standardize code
chunk labels based on section names and exercise numbers. It also
renumbers exercises sequentially within each section and fixes spacing
in topic headers.

## Usage

``` r
format_tutorial(file_path)
```

## Arguments

- file_path:

  Character string. Path to the R Markdown file to process.

## Value

Character string containing the formatted R Markdown content.

## Details

The function applies the following formatting rules:

- Topic headers (# headers) have their spacing standardized

- Exercises are renumbered sequentially within each section

- Code chunks are relabeled according to the pattern:
  section-name-exercise-number

- Chunks with `eval = FALSE` receive a `-hint-N` suffix

- Chunks with `include = FALSE` receive a `-test` suffix

- Chunks with label "setup" are not modified

- Chunks with the "file" option are not modified

- Unlabeled chunks without key options are not modified

- All formatted chunks preserve their original options

- Content between quadruple backticks (` `) is preserved untouched
