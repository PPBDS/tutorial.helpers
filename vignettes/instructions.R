## ----file = "example-code-exercise.txt", echo = TRUE, eval = FALSE------------
#  ### Exercise 2
#  
#  Start your code with `cces`. Use the pipe operator `|>` to add the
#  function `filter()`, selecting the  rows where `state` is equal to
#  "Massachusetts". To set something equal to a value in `filter()`
#  use two equal signs: `==`.
#  
#  ```{r filter-2, exercise = TRUE}
#  ```
#  
#  ```{r filter-2-hint-1, eval = FALSE}
#  cces |>
#    filter(state == "...")
#  ```
#  
#  ```{r filter-2-test, include = FALSE}
#  cces |>
#    filter(state == "Massachusetts")
#  ```
#  ###
#  
#  `==` is used because it is **checking** whether the value of the
#  variable on the left is equal to the value on the left. See
#  [here](https://stat.ethz.ch/R-manual/R-devel/library/base/html/Comparison.html)
#  for discussion of other relational operators in R.
#  A single equation symbol, `=`, is used to set something equal to
#  something else.

## ----file = "example-hint-1.txt", echo = TRUE, eval = FALSE-------------------
#  ```{r ex-1-hint-1, eval = FALSE}
#  This is an example hint. Normally sentences like these
#  would cause an error in R because it is not proper code.
#  However, since we include eval = FALSE in the r-chunk,
#  R ignores all errors!
#  ```

## ----file = "example-hint-2.txt", echo = TRUE, eval = FALSE-------------------
#  ```{r ex-1-hint-2, eval = FALSE}
#  ... |>
#    filter(year = ...) |>
#    ...(flights)
#  ```

## ----file = "example-written-1.txt", echo = TRUE, eval = FALSE----------------
#  ### Exercise 6
#  
#  Explain potential outcomes in about two sentences.
#  
#  ```{r definitions-6}
#  question_text(NULL,
#      message = "This is where we place the correct answer. It will appear only after
#      students have submitted their own answers. Note that we do not need to wrap the
#      answer text by hand.",
#      answer(NULL,
#             correct = TRUE),
#      allow_retry = FALSE,
#      incorrect = NULL,
#      rows = 6)
#  ```

## ----file = "example-written-2.txt", echo = TRUE, eval = FALSE----------------
#  ### Exercise 7
#  
#  From the Console, run `list.files()`. CP/CR.
#  
#  ```{r file-creation-7}
#    question_text(NULL,
#      answer(NULL, correct = TRUE),
#      allow_retry = TRUE,
#      try_again_button = "Edit Answer",
#      incorrect = NULL,
#      rows = 3)
#  ```

## ----eval = FALSE-------------------------------------------------------------
#  x <- read_csv("data/myfile.csv")

## ----file = "example-graphic.txt", echo = TRUE, eval = FALSE------------------
#  ```{r}
#  include_graphics("images/example.png")
#  ```

## ----file = "example-file.txt", echo = TRUE, eval = FALSE---------------------
#  ```{r file = "example.txt", echo = TRUE, eval = FALSE}
#  ```

## ----eval = FALSE-------------------------------------------------------------
#  rmarkdown::render("inst/tutorials/02-terminal/tutorial.Rmd")

