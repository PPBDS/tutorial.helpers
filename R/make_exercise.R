#' @title Add a tutorial code exercise or question to the active document
#'
#' @rdname exercise_creation
#'
#' @description When writing tutorials, it is handy to be able to insert the
#'   skeleton for a new code exercise or question. We bind `make_exercise()` and
#'   friends as an RStudio add-in to provide this functionality. Note that the
#'   function determines the correct exercise number to use and also adds
#'   appropriate code chunk names, based on the exercise number and section
#'   title.
#'
#' @details It appears that the RStudio addins must have function names only as
#'   the Binding value. In other words, you can't have `make_exercise(type =
#'   'no-answer')` as the value. So, we need two extra functions ---
#'   `make_no_answer()` and `make_yes_answer()` ---which just call
#'   `make_exercise()` while passing in the correct argument.
#'
#' @param type Character of question type. Must be one of "code", "no-answer",
#'   or "yes-answer".
#'
#' @param file_path Character path to a file. If NULL, the RStudio active
#'   document is used, which is the default behavior. An actual file path is
#'   used for testing.
#'
#' @importFrom rstudioapi getActiveDocumentContext
#'
#' @returns Exercise skeleton corresponding to the `type` argument.
#'
#' @export

make_exercise <- function(type = "code", file_path = NULL){

  # Need to fix behavior when it is called outside an Rmd with Section
  # headings.
  
  # Function should first, check all the section names, confirming that they are
  # all unique, and reporting an error if not. Add this!
  
  # To create the code chunks, we need to know the next exercise number and the
  # section title.

  exercise_number <- determine_exercise_number(file_path)
  section_id <- determine_code_chunk_name(file_path)

  # Make new exercise skeleton by inserting the appropriate label and exercise
  # number at the right places.
  
  # Both this function and format_tutorial() encode the information about the
  # correct code chunk labels for exercises. That is bad! We should encode that
  # stuff in just one location.
  
  new_exercise <-
    dplyr::case_match(
      type,
      "code"       ~ sprintf("### Exercise %s\n\n\n```{r %s-%s-ex, exercise = TRUE}\n\n```\n\n<button onclick = \"transfer_code(this)\">Copy previous code</button>\n\n```{r %s-%s-hint, eval = FALSE}\n\n```\n\n```{r %s-%s-test, include = FALSE}\n\n```\n\n###\n\n",
                             exercise_number,
                             section_id,
                             exercise_number,
                             section_id,
                             exercise_number,
                             section_id,
                             exercise_number),
      "no-answer"  ~ sprintf("### Exercise %s\n\n\n```{r %s-%s-ex}\nquestion_text(NULL,\n\tanswer(NULL, correct = TRUE),\n\tallow_retry = TRUE,\n\ttry_again_button = \"Edit Answer\",\n\tincorrect = NULL,\n\trows = 3)\n```\n\n###\n\n",
                             exercise_number,
                             section_id,
                             exercise_number),
      "yes-answer" ~ sprintf("### Exercise %s\n\n\n```{r %s-%s-ex}\nquestion_text(NULL,\n\tmessage = \"Place correct answer here.\",\n\tanswer(NULL, correct = TRUE),\n\tallow_retry = FALSE,\n\tincorrect = NULL,\n\trows = 6)\n```\n\n###\n\n",
                             exercise_number,
                             section_id,
                             exercise_number))

  # Insert the skeleton into the current active document. Still need to figure out how to test this.

  rstudioapi::insertText(text = new_exercise)
}

#' Make question skeleton without an answer
#'
#' @rdname exercise_creation


make_no_answer <- function(){
  make_exercise(type = 'no-answer')
}

#' Make question skeleton with an answer
#'
#' @rdname exercise_creation


make_yes_answer <- function(){
  make_exercise(type = 'yes-answer')
}

