# Write tutorial answers to file

Take a tutorial session (or a submission list), extract all submitted
answers, and write out an HTML file with those answers.

## Usage

``` r
write_answers(file, obj)
```

## Arguments

- file:

  Output file path (should end in .html).

- obj:

  Either a Shiny session object (from learnr) or a list of submissions
  (as returned by get_submissions_from_learnr_session()).
