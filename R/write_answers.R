#' Write tutorial answers to file
#'
#' @description
#'   Take a tutorial session, extract all questions (including those not answered),
#'   and write out an HTML file with the student's answers (or NA if unanswered). 
#'
#' @details
#'   This function now outputs every question/exercise in the tutorial, showing NA for any unanswered.
#'   Also includes a header with tutorial metadata (tutorial id, version).
#'
#'   See also: https://mastering-shiny.org/action-transfer.html#downloading-reports
#'
#'   Consider allowing more metadata: user_id, tutorial_version, etc.
#'   Example for more info: https://github.com/mattblackwell/qsslearnr/blob/main/R/submission.R
#'
#'   Data structure of a learnr submission object:
#'     - obj$data$answer[[1]] question answer
#'     - obj$data$code[[1]] exercise answer
#'     - obj$type[[1]] "exercise_submission"
#'     - obj$id[[1]] "id"
#'
#' @param file Path to write HTML answers file.
#' @param session Session object from `Shiny` with `learnr` (for live use) or a list of submission objects (for testing).
#'
#' @returns NULL (side effect: writes file)
#'
#' @examples
#' if(interactive()){
#'   write_answers("getting-started_answers.html", sess)
#' }
#'
#' @export

write_answers <- function(file, session) {
  # Helper: Get all possible question/exercise IDs for the current tutorial
  get_all_question_ids <- function(session) {
    # Safely try both learnr 0.10.x and 0.11.x+ API
    state <- tryCatch(learnr::get_tutorial_state(session), error = function(e) NULL)
    if (is.null(state)) return(character(0))
    ex_ids <- if (!is.null(state$exercises)) names(state$exercises) else character(0)
    question_ids <- if (!is.null(state$questions)) names(state$questions) else character(0)
    unique(c(ex_ids, question_ids))
  }

  # Accept either a session object or a pre-extracted list of submissions (for tests).
  if (inherits(session, "ShinySession")) {
    objs <- get_submissions_from_learnr_session(session)
    tutorial_id <- learnr::get_tutorial_info()$tutorial_id
    tutorial_version <- learnr::get_tutorial_info()$tutorial_version
    all_ids <- get_all_question_ids(session)
  } else {
    # For testing, session is just a list of answer objects and all_ids must be provided
    objs <- session
    tutorial_id <- "test-tutorial"
    tutorial_version <- NA_character_
    # For tests, assume all IDs in the list plus some extras (for test coverage)
    all_ids <- unique(vapply(objs, function(x) x$id, character(1)))
  }

  # Build a lookup for submitted answers
  objs_by_id <- setNames(objs, vapply(objs, function(x) x$id, character(1)))

  out <- tibble::tibble(
    id = all_ids,
    submission_type = purrr::map_chr(all_ids, function(qid) {
      if (!is.null(objs_by_id[[qid]])) objs_by_id[[qid]]$type else NA_character_
    }),
    answer = purrr::map_chr(all_ids, function(qid) {
      if (!is.null(objs_by_id[[qid]]) && !is.null(objs_by_id[[qid]]$answer)) {
        ans <- objs_by_id[[qid]]$answer
        if (length(ans) > 1) paste(as.character(ans), collapse = ", ") else as.character(ans)
      } else {
        NA_character_
      }
    })
  )

  # Prepend tutorial metadata as a header row (id and version)
  header <- tibble::tibble(
    id = "tutorial-id",
    submission_type = tutorial_version,
    answer = tutorial_id
  )
  out <- dplyr::bind_rows(header, out)

  z <- knitr::kable(out, format = "html")
  write(as.character(z), file = file)

  invisible(NULL)
}
