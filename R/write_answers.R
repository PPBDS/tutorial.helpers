#' @title Write tutorial answers to file
#'
#' @description
#'   Take a tutorial session, extract all submitted answers,
#'   and write out an HTML file with those answers. 
#'
#' @details
#'   Currently only records questions/exercises the student has completed.
#'   It may be better to include all questions/exercises, with unanswered as NA.
#'
#'   Data structure of a learnr submission object:
#'     - `obj$data$answer[[1]]` question answer
#'     - `obj$data$code[[1]]` exercise answer
#'     - `obj$type[[1]]` "exercise_submission"
#'     - `obj$id[[1]]` "id"
#'
#' @param file Path to write HTML answers file.
#' @param session Session object from `Shiny` with `learnr`, or a list of submission objects (for testing).
#'
#' @returns NULL (side effect: writes file)
#'
#' @examples
#' \dontrun{
#'   write_answers("getting-started_answers.html", sess)
#' }
#'
#' @export

write_answers <- function(file, session){
  # Accept either a session object or a pre-extracted list of submissions (for tests).
  if (inherits(session, "ShinySession")) {
    objs <- get_submissions_from_learnr_session(session)
    tutorial_id <- learnr::get_tutorial_info()$tutorial_id
  } else {
    # Assume session is actually just a list of answer objects for testing
    objs <- session
    tutorial_id <- "test-tutorial"
  }

  out <- tibble::tibble(
    id = purrr::map_chr(objs, ~ {
      if (is.null(.x$id) || length(.x$id) == 0) NA_character_ else as.character(.x$id)
    }, .default = NA_character_),
    submission_type = purrr::map_chr(objs, ~ {
      if (is.null(.x$type) || length(.x$type) == 0) NA_character_ else as.character(.x$type)
    }, .default = NA_character_),
    answer = purrr::map_chr(
      objs,
      ~ {
        ans <- .x$answer
        if (is.null(ans) || length(ans) == 0) {
          return(NA_character_)
        } else if (length(ans) > 1) {
          return(paste(as.character(ans), collapse = ", "))
        } else {
          return(as.character(ans))
        }
      },
      .default = NA_character_
    )
  )

  # Optionally, prepend tutorial metadata as a header row (currently just tutorial id)
  out <- rbind(c(id = "tutorial-id", submission_type = "none", answer = tutorial_id), out)

  z <- knitr::kable(out, format = "html")
  write(as.character(z), file = file)

  NULL
}
