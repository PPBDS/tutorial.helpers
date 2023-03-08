#' Tutorial Written Exercise (With Answer)
#'
#' @description
#'
#' An add-in for writing all.primer.tutorials.
#'
#' It reads the latest exercise and section name
#' and then adds a question skeleton (with answers and no retries).
#'
#' This should make things easier for tutorial-writers
#' because now a fast click can create most of the exercise for you.
#'
#' There is also no need to keep track of the exercise numbers
#' because it is done for you in the add-in.
#'
#' Keyboard shortcut should be Cmd + SHIFT + E (MAC)
#'
#' @return question skeleton with appropriate labels and numbers
make_new_q_with_answer <- function(){

  # Steps:
  # 1. get destination of add-in
  # 2. find the correct label and exercise number
  # 3. format question skeleton with the found labels and numbers
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

  # Make new question skeleton by
  # inserting the appropriate label
  # and exercise number at the right places

  new_exercise <- sprintf("### Exercise %s\n\n\n```{r %s-%s}\nquestion_text(NULL,\n\tmessage = \"Place correct answer here.\",\n\tanswer(NULL, correct = TRUE),\n\tallow_retry = FALSE,\n\tincorrect = NULL,\n\trows = 6)\n```\n\n###\n\n",
                          exercise_number,
                          section_id,
                          exercise_number)

  # Insert the skeleton into the current active document

  rstudioapi::insertText(new_exercise)
}
