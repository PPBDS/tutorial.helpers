#' Re-format a tutorial
#'
#' @description A function for formatting tutorial Rmd files. Used by
#'   check_current_tutorial() to re-format the currently open tutorial in
#'   RStudio. It renumbers the exercises so that they are in order. It ensures
#'   that chunk labels use this numbering, along with the section title.
#'
#' @param file_path Character string.
#'
#' @returns Formatted document with correct exercise, hint and test chunk labels.
#' @export

format_tutorial <- function(file_path){

  # Create function that will later be used to set the chunk label and code.

  change_chunk_function <- function(x, ...){
    opts <- list(...)
    x[[opts[[1]]]] <- opts[[2]]
    x
  }

  # Create function that will later be used to get the number of lines in an
  # exercise.

  get_chunk_lines <- function(x, ...){
    length(x$code)
  }

  # Parse Rmd of file path

  rmd <- parsermd::parse_rmd(file_path)

  tbl <- tibble::as_tibble(rmd)
  
  # parsermd 0.1.3 created a difficult to diagnose bug for me. It labels any
  # unlabelled R code chunk as "unnamed-chunk-n" with "n" incrementing. That is
  # very bad! You should not add labels which do not exist. So, I do a total
  # hack to just remove those labels from the final document. Of course, this
  # will hose any user who actually has a code chunk whose label matches
  # "unnamed-chunk-n" with "n" as any integer, but what are you going to do?
  # This hack was easier (?) than trying to work directly with objects of class
  # "rmd_ast" "list"
  
  for(i in seq_len(nrow(tbl))){
    if(grepl("^unnamed-chunk-\\d+$", tbl[i, "label"])){
      
      # Once we get the correct row, we do two things. First, we remove the
      # label from the tibble. Not sure why this is necessary. Is the label
      # really used later? Second, we need to change the ast itself.
      
      tbl$label[i] <- NA
      new_ast <- purrr::map(tbl$ast[i], change_chunk_function, "name", "")
      tbl$ast[i] <- new_ast
    }
  }
  
  # Set up tracker variables for the loop

  hint_count <- 0

  exercise_number <- 1

  curr_exercise <- ""

  curr_section <- ""

  has_exercise <- FALSE

  # The idea of this loop is to go through each element of the Rmd and change it
  # to its desired format.

  # Each code chunk will go through a series of conditions to determine what
  # type of code chunk it is and what the label should be.
  
  # This entire loop should be refactored. Not sure how! Should probably start
  # by creating the exercise code chunk name correctly. Once you have that, the
  # name for the hint and the test code chunks is simple enough. Note the
  # trickiness of keeping count of the hints. Maybe don't allow more than one
  # hint?

  for (i in seq_along(tbl$sec_h2)){

    # Check if the code chunk is in a level 3 heading.

    l <- tbl$sec_h2[i]

    e <- tbl$sec_h3[i]

    # Ignore all code chunks outside a level 3 heading.

    if (is.na(l) | is.na(e)){
      next
    }

    # Check if current exercise is a new exercise: If it is, then the hint and
    # exercise tracker is reset and the exercise number is updated.

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
    
    # DK: Would be nice if, instead of skipping labels which are null, it added
    # labels, at least in any hint or test chunk. Big annoyance right now is
    # that we have lots of test chunks with no labels.

    # Skip this loop if the current element fits any of the following:
    # 1. not a code chunk
    # 2. has NULL for its label
    # 3. has an empty string for its label

    if (tbl$type[i] != "rmd_chunk" | 
        is.na(tbl$label[i]) | 
        nchar(trimws(tbl$label[i])) == 0){
      next
    }

    # If "hint" is in the current element's label
    # but the element doesn't have the eval = FALSE option,
    # add that option to the element.
    
    # DK: Add similar testing/fixing for test chunks. Or, better, make this
    # hackery go away. If writers forget eval = FALSE, what can we do?

    if (stringr::str_detect(tbl$label[i], "hint") && 
        length(parsermd::rmd_get_options(tbl$ast[i])[[1]]) == 0){
      tbl$ast[i] <- parsermd::rmd_set_options(tbl$ast[i], eval = "FALSE")
    }

    # Create the standardized label of the current element. Hate that we need to
    # duplicate this code from determine_code_chunk_names.R. Can't we have it in
    # just one place?

    # Remove the pattern "{#...}" and non-alphanumeric characters except
    # spaces and slashes
    
    cleaned_l <- gsub("\\{#(.*)\\}", "", l)
    cleaned_l <- gsub("[^a-zA-Z0-9 /]", "", cleaned_l)
    
    # Convert to lowercase, replace spaces and slashes with hyphens, trim to 30
    # characters, and trim whitespace and hyphens at the start and beginning.
    
    section_id <- trimws(cleaned_l)
    section_id <- substr(gsub("[ /]", "-", tolower(section_id)), 1, 30)
    section_id <- gsub("-+$", "", section_id)
    section_id <- gsub("^-+", "", section_id)

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

    # If chunk label ends with "-setup", it is recognized as a setup code chunk,
    # so the name is exercise name and -setup Ex: ex-1-setup for ex-1

    if (grepl("-setup$", tbl$label[i])){
      new_label <- paste0(section_id, "-", exercise_number, "-setup")
      new_ast <- purrr::map(tbl$ast[i], change_chunk_function, "name", new_label)
      tbl$ast[i] <- new_ast
      next
    }
    
    # If chunk label ends with "-test", it is recognized as a test chunk,
    # so the name is exercise name and -test Ex: ex-1-test for ex-1
    
    if (grepl("-test$", tbl$label[i])){
      new_label <- paste0(section_id, "-", exercise_number, "-test")
      new_ast <- purrr::map(tbl$ast[i], change_chunk_function, "name", new_label)
      tbl$ast[i] <- new_ast
      next
    }

    # If this element is not a hint and the current level 3 heading already has
    # an exercise, skip to the next loop because it must be some kind of set up
    # code chunk.

    if (has_exercise){
      next
    }

    # After all the conditions above, the elements left MUST BE exercises, so
    # the appropriate labels are set and the exercise tracker is updated.

    new_label <- paste0(section_id, "-", exercise_number)

    new_ast <- purrr::map(tbl$ast[i], change_chunk_function, "name", new_label)

    tbl$ast[i] <- new_ast

    has_exercise <- TRUE
  }

  # This is quite interesting.
  #
  # The parsermd already has an as_document function that should've taken care
  # of turning the changed Rmd structure into raw text.
  #
  # However, there was a thing with Rmarkdown sections in the structure where
  # each time it is updated, it adds a newline to the section because while
  # parsing, newlines counted as part of the Rmarkdown section.
  #
  # This created a cycle where each time an Rmd is checked, it would be padded
  # with as many newlines as there are Rmarkdown sections.
  #
  # Therefore, I had to make my own way of transforming the Rmd back to plain
  # text.
  #
  # The only unique thing this part does is that it removes the last character
  # of every Rmarkdown section, which is always a newline before adding it to
  # the full document.

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
  
  # I don't really understand how the above code works. But I can see that it
  # always results in an output doc with a newline at the beginning, which I
  # don't think we want. At least, it looks weird for the test cases. (But might
  # be a good idea in interactive use. If so, add the newline when it is
  # interactive.)
  
  if(substr(new_doc, 1, 1) == "\n") {
    new_doc <- substring(new_doc, 2)
  }


  new_doc
}
