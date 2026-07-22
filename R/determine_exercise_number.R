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

  for (l in cut_content){

    # Find the latest exercise header. The match is anchored so that prose or
    # code merely mentioning "### Exercise" does not alter the numbering.

    if (grepl("^### Exercise\\b", l)){

      # Extract only the number immediately following "Exercise", so headers
      # like "### Exercise 2 (part 3)" yield 2, not 23. A bare "### Exercise"
      # header has no number; treat it as exercise 0 so we return 1.

      num <- sub("^### Exercise\\s*", "", l)
      num <- sub("^(\\d*).*$", "\\1", num)
      latest <- if (nzchar(num)) as.integer(num) else 0L

      return(latest + 1L)
    }

    # Find the latest section. A section header before any exercise means
    # the next exercise is the first one.

    if (grepl("^## ", l)){
      return(1L)
    }
  }

  # No exercise or section header found above this point in the file.

  return(1L)
}
