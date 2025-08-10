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
#'   or "yes-answer". Abbreviations such as "no", "yes", and "co" are allowed.
#'
#' @param file_path Character path to a file. If NULL, the RStudio active
#'   document is used, which is the default behavior. An actual file path is
#'   used for testing.
#'
#' @importFrom rstudioapi getActiveDocumentContext insertText
#'
#' @returns Exercise skeleton corresponding to the `type` argument.
#'
#' @export

make_exercise <- function(type = "no-answer", file_path = NULL) {
  # To create the code chunks, we need to know the next exercise number and the section title.
  exercise_number <- determine_exercise_number(file_path)
  section_id <- determine_code_chunk_name(file_path)

  # Allow abbreviated type inputs (e.g., "no" for "no-answer", "ye" for "yes-answer")
  allowed_types <- c("no-answer", "yes-answer", "code")
  # Expand abbreviations
  if (!type %in% allowed_types) {
    match_idx <- pmatch(type, allowed_types)
    if (is.na(match_idx)) stop("Invalid type argument.")
    type <- allowed_types[match_idx]
  }

  # Compose the exercise skeleton
  new_exercise <-
    switch(type,
      "no-answer" = sprintf(
        "### Exercise %s\n\n\n```{r %s-%s}\nquestion_text(NULL,\n\tanswer(NULL, correct = TRUE),\n\tallow_retry = TRUE,\n\ttry_again_button = \"Edit Answer\",\n\tincorrect = NULL,\n\trows = 5)\n```\n\n###\n\n```{r %s-%s-test, echo = TRUE}\n\n```\n\n###\n\n",
        exercise_number,
        section_id,
        exercise_number,
        section_id,
        exercise_number
      ),
      "yes-answer" = sprintf(
        "### Exercise %s\n\n\n```{r %s-%s}\nquestion_text(NULL,\n\tmessage = \"Place correct answer here.\",\n\tanswer(NULL, correct = TRUE),\n\tallow_retry = FALSE,\n\tincorrect = NULL,\n\trows = 6)\n```\n\n###\n\n",
        exercise_number,
        section_id,
        exercise_number
      ),
      "code" = sprintf(
        "### Exercise %s\n\n\n```{r %s-%s, exercise = TRUE}\n\n```\n\n<button onclick = \"transfer_code(this)\">Copy previous code</button>\n\n```{r %s-%s-hint, eval = FALSE}\n\n```\n\n```{r %s-%s-test, include = FALSE}\n\n```\n\n###\n\n",
        exercise_number,
        section_id,
        exercise_number,
        section_id,
        exercise_number,
        section_id,
        exercise_number
      ),
      stop("Unknown type argument to make_exercise()")
    )

  # --- Insertion logic ---
  # If file_path is NULL, we are in RStudio and want to insert into the active document
  if (is.null(file_path)) {
    ctx <- rstudioapi::getActiveDocumentContext()
    if (is.null(ctx)) stop("No active RStudio document. Please open an Rmd file.")
    
    # Insert at current cursor position (this is the simplest approach)
    rstudioapi::insertText(text = new_exercise)
    
  } else {
    # If file_path is provided (for testing): write or append to file
    cat(new_exercise, file = file_path, append = TRUE)
    invisible(new_exercise)
  }
}

#' Make question skeleton without an answer
#'
#' @rdname exercise_creation
#' @export
make_no_answer <- function() {
  make_exercise(type = "no-answer")
}

#' Make question skeleton with an answer
#'
#' @rdname exercise_creation
#' @export
make_yes_answer <- function() {
  make_exercise(type = "yes-answer")
}
