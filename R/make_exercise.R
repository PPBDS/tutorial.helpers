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
#' @importFrom rstudioapi getActiveDocumentContext
#'
#' @returns Exercise skeleton corresponding to the `type` argument.

make_exercise <- function(type = "code"){

  # DK: Need to fix behavior when it is called outside an Rmd with Section
  # headings.

  stopifnot(type %in% c("code", "no-answer", "yes-answer"))

  # Steps:
  # 1. get destination of add-in
  # 2. find the correct label and exercise number
  # 3. format exercise skeleton with the found labels and numbers
  # 4. insert skeleton into active document

  # Get current active document and position

  ctx <- rstudioapi::getActiveDocumentContext()
  row <- ctx$selection[[1]]$range$end[["row"]]

  # Get everything until the current row as a list of lines
  # and reverse that list

  cut_content <- rev(ctx$contents[1:row])

  exercise_number <- "1"

  section_id <- "NONE_SET"

  # Cycle through the reversed lines (essentially going from down up)
  # and find the latest exercise as well as section.

  # If a section is found first, the loop is stopped immediately
  # because that means the exercise to be inserted is exercise 1.

  # If an exercise is found first, continue the loop until finding a section,
  # so we can get both the section label and the latest exercise number.

  exercise_set <- FALSE

  for (l in cut_content){

    # Find the latest exercise and make sure we have not already set the exercise number

    if (stringr::str_detect(l, "### Exercise") & !stringr::str_detect(l, "str_detect")& !exercise_set){

      # Set the exercise number to 1 + the latest exercise number

      exercise_number <- readr::parse_integer(gsub("[^0-9]", "", l)) + 1

      # Set exercise_set to TRUE
      # so we don't set the exercise number more than once

      exercise_set <- TRUE

    }

    # Find the latest section

    if (stringr::str_detect(l, "^## ")){

      # clean up id

      possible_id_removed_prev <- gsub("\\{#(.*)\\}", "", l)

      possible_id_removed <- gsub("[^a-zA-Z0-9 ]", "", possible_id_removed_prev)

      lowercase_id <- tolower(trimws(possible_id_removed))

      section_id <- trimws(substr(gsub(" ", "-", lowercase_id), 0, 20))

      # After finding a section, stop looping immediately

      break
    }
  }

  # Make new exercise skeleton by
  # inserting the appropriate label
  # and exercise number at the right places

  if(type == "code"){
  new_exercise <- sprintf("### Exercise %s\n\n\n```{r %s-%s, exercise = TRUE}\n\n```\n\n<button onclick = \"transfer_code(this)\">Copy previous code</button>\n\n```{r %s-%s-hint, eval = FALSE}\n\n```\n\n###\n\n",
                         exercise_number,
                         section_id,
                         exercise_number,
                         section_id,
                         exercise_number)
  }

  new_exercise <-
    dplyr::case_match(
      type,
      "code"       ~ sprintf("### Exercise %s\n\n\n```{r %s-%s, exercise = TRUE}\n\n```\n\n<button onclick = \"transfer_code(this)\">Copy previous code</button>\n\n```{r %s-%s-hint, eval = FALSE}\n\n```\n\n###\n\n",
                             exercise_number,
                             section_id,
                             exercise_number,
                             section_id,
                             exercise_number),
      "no-answer"  ~ sprintf("### Exercise %s\n\n\n```{r %s-%s}\nquestion_text(NULL,\n\tanswer(NULL, correct = TRUE),\n\tallow_retry = TRUE,\n\ttry_again_button = \"Edit Answer\",\n\tincorrect = NULL,\n\trows = 3)\n```\n\n###\n\n",
                             exercise_number,
                             section_id,
                             exercise_number),
      "yes-answer" ~ sprintf("### Exercise %s\n\n\n```{r %s-%s}\nquestion_text(NULL,\n\tmessage = \"Place correct answer here.\",\n\tanswer(NULL, correct = TRUE),\n\tallow_retry = FALSE,\n\tincorrect = NULL,\n\trows = 6)\n```\n\n###\n\n",
                             exercise_number,
                             section_id,
                             exercise_number))

  # Insert the skeleton into the current active document

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

