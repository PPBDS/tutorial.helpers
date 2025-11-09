# Add a tutorial code exercise or question to the active document

When writing tutorials, it is handy to be able to insert the skeleton
for a new code exercise or question. Note that the function determines
the correct exercise number to use and also adds appropriate code chunk
labels, based on the exercise number and section title.

## Usage

``` r
make_exercise(type = "no-answer", file_path = NULL)
```

## Arguments

- type:

  Character of question type. Must be one of "code", "no-answer", or
  "yes-answer". Abbreviations such as "no", "yes", and "co" are allowed.

- file_path:

  Character path to a file. If NULL, the RStudio active document is
  used, which is the default behavior. An actual file path is used for
  testing.

## Value

Exercise skeleton corresponding to the `type` argument.
