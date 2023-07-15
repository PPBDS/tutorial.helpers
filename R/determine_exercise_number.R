#' Finds the number of the next exercise in a tutorial
#'
#' @param file_path Character string of the file path to the tutorial
#'
#' @return The next exercise number based on the file argument or the active document.
#' @export
determine_exercise_number <- function(file_path = NULL){

  # Similar to determine_code_chunk_name(), getActiveDocumentContext() is not currently tested and uses file_path as
  # an alternative. There are issues to this due to cursor placement. Currently, the function returns an integer
  # explore perhaps the typing of the return object, and note that cut_content represents the tutorial's text but reversed.

  if (is.null(file_path))
  {

    ctx <- rstudioapi::getActiveDocumentContext()
    row <- ctx$selection[[1]]$range$end[["row"]]

    cut_content <- rev(ctx$contents[1:row])

  }
  else
  {
    cut_content <- rev(readLines(file_path))

  }

  exercise_number <- "1"

  for (l in cut_content){

    # Find the latest exercise and make sure we have not already set the exercise number

    if (stringr::str_detect(l, "### Exercise") & !stringr::str_detect(l, "str_detect")){

      # Set the exercise number to 1 + the latest exercise number

      exercise_number <- strtoi(readr::parse_integer(gsub("[^0-9]", "", l)) + 1)
      return(exercise_number)
    }

    # Find the latest section

    if (stringr::str_detect(l, "^## ")){

      # After finding a section, stop looping immediately

      return(strtoi(exercise_number))
    }
  }


}
