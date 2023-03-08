#' Format Tutorial
#'
#' @description
#'
#' A function for formatting primer tutorials.
#'
#' It adjusts the code and hint chunk labels correctly.
#'
#' This should make things easier for tutorial-writers
#' because it will allow fast chunk label updating and quick formatting
#' and checking
#'
#' There is also no need to keep track of the exercise numbers
#' because it is done for you in the add-in.
#'
#' @param file_path Character string
#'
#' @return formatted document with correct code and hint chunk labels
#'
#' @export


format_tutorial <- function(file_path){

  # Create function that will later be used
  # to set the chunk label and code in the ast.

  change_chunk_function <- function(x, ...){
    opts <- list(...)
    x[[opts[[1]]]] <- opts[[2]]
    x
  }

  # Create function that will later be used
  # to get the number of lines in an exercise.

  get_chunk_lines <- function(x, ...){
    length(x$code)
  }

  # Parse Rmd of file path

  rmd <- parsermd::parse_rmd(file_path)

  tbl <- tibble::as_tibble(rmd)

  # Set up tracker variables for the loop

  hint_count <- 0

  exercise_number <- 1

  curr_exercise <- ""

  curr_section <- ""

  has_exercise <- FALSE

  # The idea of this loop is to go through
  # each element of the Rmd and change it to its desired format.

  # Each code chunk will go through a series of conditions to
  # determine what type of code chunk it is and what the label
  # should be.

  for (i in seq_along(tbl$sec_h2)){

    # Check if the code chunk is in a level 3 heading.

    l <- tbl$sec_h2[i]

    e <- tbl$sec_h3[i]

    # Ignore all code chunks outside a level 3 heading.

    if (is.na(l) | is.na(e)){
      next
    }

    # Check if current exercise is a new exercise:
    # If it is, then the hint and exercise tracker is reset
    # and the exercise number is updated.

    if (l != curr_section && nchar(trimws(l)) != 0 && tbl$type[i] == "rmd_heading"){
      curr_section <- l

      exercise_number <- 0
    }


    if (nchar(trimws(e)) != 0 && tbl$type[i] == "rmd_heading"){
      exercise_number <- exercise_number + 1

      curr_exercise <- paste0("Exercise ", exercise_number)

      new_heading_ast <- purrr::map(tbl$ast[i], change_chunk_function, "name", curr_exercise)

      tbl$ast[i] <- new_heading_ast

      hint_count <- 0

      has_exercise <- FALSE
    }

    # Skip this loop if the current element fits any of the following:
    # 1. not a code chunk
    # 2. has NULL for its label
    # 3. has an empty string for its label

    if (tbl$type[i] != "rmd_chunk" | is.na(tbl$label[i]) | nchar(trimws(tbl$label[i])) == 0){
      next
    }

    # If "hint" is in the current element's label
    # but the element doesn't have the eval = FALSE option,
    # add that option to the element.

    if (stringr::str_detect(tbl$label[i], "hint") && length(parsermd::rmd_get_options(tbl$ast[i])[[1]]) == 0){
      tbl$ast[i] <- parsermd::rmd_set_options(tbl$ast[i], eval = "FALSE")
    }

    # Create the standardized label of the current element

    possible_id_removed_prev <- gsub("\\{#(.*)\\}", "", l)

    possible_id_removed <- gsub("[^a-zA-Z0-9 ]", "", possible_id_removed_prev)

    lowercase_id <- tolower(trimws(possible_id_removed))

    section_id <- trimws(substr(gsub(" ", "-", lowercase_id), 0, 20))

    # Read the options of the element

    filt_options <- parsermd::rmd_get_options(tbl$ast[i])[[1]]

    # If the element has options, then check for the following:
    #
    # 1) If the element is a hint, set its label
    #   to the hint format and increment the hint tracker
    #   then skip to next loop
    #
    # 2) If the element is a child document, skip to next loop.
    #
    # 3) If the element is an exercise and does not have an empty line,
    #   add an empty line.

    if (length(filt_options) > 0){
      if (names(filt_options)[[1]] == "eval" && filt_options[[1]] == "FALSE"){
        hint_count <- hint_count + 1

        new_label <- paste0(section_id, "-", exercise_number, "-hint-", hint_count)

        new_ast <- purrr::map(tbl$ast[i], change_chunk_function, "name", new_label)

        tbl$ast[i] <- new_ast

        next
      }

      if (names(filt_options)[[1]] == "child"){
        next
      }

      if (names(filt_options)[[1]] == "exercise" && filt_options[[1]] == "TRUE"){
        if (purrr::map(tbl$ast[i], get_chunk_lines)[[1]] == 0){
          new_ast <- purrr::map(tbl$ast[i], change_chunk_function, "code", "")
          tbl$ast[i] <- new_ast
        }
      }
    }

    # If chunk label ends with "-setup",
    # it is recognized as a setup code chunk,
    # so the name is exercise name and -setup
    # Ex: ex-1-setup for ex-1

    if (grepl("-setup$", tbl$label[i])){
      new_label <- paste0(section_id, "-", exercise_number, "-setup")
      new_ast <- purrr::map(tbl$ast[i], change_chunk_function, "name", new_label)
      tbl$ast[i] <- new_ast
      next
    }

    # If this element is not a hint and the current level 3 heading
    # already has an exercise, skip to the next loop because
    # it must be some kind of set up code chunk.

    if (has_exercise){
      next
    }

    # After all the conditions above, the elements left
    # MUST BE exercises, so the appropriate labels are set
    # and the exercise tracker is updated.

    new_label <- paste0(section_id, "-", exercise_number)

    new_ast <- purrr::map(tbl$ast[i], change_chunk_function, "name", new_label)

    tbl$ast[i] <- new_ast

    has_exercise <- TRUE
  }

  # This is quite interesting.
  #
  # The parsermd already has a as_document function
  # that should've taken care of turning the changed Rmd structure
  # into raw text.
  #
  # However, there was a thing with Rmarkdown sections in the structure
  # where each time it is updated, it adds a newline to the section because
  # while parsing, newlines counted as part of the Rmarkdown section.
  #
  # This created a cycle where each time an Rmd is checked, it would be
  # padded with as many newlines as there are Rmarkdown sections.
  #
  # Therefore, I had to make my own way of transforming the Rmd back
  # to plain text

  # The only unique thing this part does is that it removes
  # the last character of every Rmarkdown section, which is always
  # a newline before adding it to the full document.

  new_doc <- ""
  for (i in seq_along(tbl$sec_h2)){
    new_txt <- parsermd::as_document(tbl$ast[i], collapse = "\n")
    if (tbl$type[i] == "rmd_markdown"){
      new_txt <- substr(new_txt, 0, nchar(new_txt)-1)
    }

    if (tbl$type[i] == "rmd_heading" & is.na(tbl$sec_h3[i])){
      new_txt <- substr(new_txt, 0, nchar(new_txt)-1)
    }

    new_doc <- paste(new_doc, new_txt, sep = "\n")
  }

  new_doc
}
