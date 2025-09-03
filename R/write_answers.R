#' Write tutorial answers to file
#'
#' @description
#'   Take a tutorial session (or a submission list), extract all submitted answers,
#'   and write out an HTML file with those answers.
#'
#' @param file Output file path (should end in .html).
#' @param obj Either a Shiny session object (from learnr) or a list of submissions
#'   (as returned by get_submissions_from_learnr_session()).
#' @returns NULL
#' @export

write_answers <- function(file, obj) {
  if (is.environment(obj)) {
    objs <- get_submissions_from_learnr_session(obj)
    tutorial_id <- learnr::get_tutorial_info()$tutorial_id
  } else if (is.list(obj) && !is.null(obj[[1]]$id)) {
    objs <- obj
    tutorial_id <- "test-tutorial"
  } else {
    stop("obj must be a Shiny session or a submissions list.")
  }

  out <- tibble::tibble(
    id = purrr::map_chr(objs, ~ if (is.null(.x$id) || length(.x$id) == 0) NA_character_ else as.character(.x$id)),
    submission_type = purrr::map_chr(objs, ~ if (is.null(.x$type) || length(.x$type) == 0) NA_character_ else as.character(.x$type)),
    answer = purrr::map_chr(objs, function(.x) {
      ans <- .x$answer
      if (is.null(ans) || length(ans) == 0) {
        NA_character_
      } else if (length(ans) > 1) {
        paste(as.character(ans), collapse = ", ")
      } else {
        as.character(ans)
      }
    })
  )

  out <- rbind(c(id = "tutorial-id", submission_type = "none", answer = tutorial_id), out)

  z <- knitr::kable(out, format = "html")
  write(as.character(z), file = file)
  invisible(NULL)
}

