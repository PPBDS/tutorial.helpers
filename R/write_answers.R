#' Write tutorial answers to file
#'
#' @description Take a tutorial session, extract out all the submitted answers,
#'   and write out an html file with all of those answers.
#'
#' @details We only keep track of the questions/exercises that the student has
#'   completed. The other obvious approach is to keep all the
#'   questions/exercises and leave unanswered ones as NA. Not sure if that
#'   approach is better, or even possible.
#'
#' @param file Location to render answers to. Output file type determined by
#'   file suffix. Only "html" is acceptable.
#'
#' @param session Session object from `Shiny` with `learnr`.
#'
#' @param is_test `TRUE`/`FALSE` depending on whether or not we are just testing
#'   the function. Default is `TRUE`.
#'
#' @returns NULL
#'
#' @examples
#' if(interactive()){
#'   write_answers("getting-started_answers.html", sess)
#' }
#'
#' @export


write_answers <- function(file, session, is_test = FALSE){
  
  # Seems like there are much easier ways of handling this problem. See:
  # https://mastering-shiny.org/action-transfer.html#downloading-reports
  
  # Get submissions from learnr session. Is it worthwhile to learn more about
  # the variables we can get from a submission object and then give the user
  # some choice about what to include? Should we get/print more information? See
  # https://github.com/mattblackwell/qsslearnr/blob/main/R/submission.R for an
  # example.
  
  # For example, get_tutorial_state()$tutorial_version seems useful, as does
  # $user_id.

  # Data Structure of a learnr submission object

  # obj$data$answer[[1]] question answer
  # obj$data$code[[1]] "exercise answer"
  # obj$type[[1]] "exercise_submission"
  # obj$id[[1]] "id"

  if(is_test){
    objs <- readRDS("fixtures/submission_test_outputs/learnr_submissions_output.rds")
    tutorial_id <- "data-webscraping"
  }
  else{
    objs <- get_submissions_from_learnr_session(session)
    tutorial_id <- learnr::get_tutorial_info()$tutorial_id
  }

  # Create tibble for saving. Should this be re-organized? Are there better
  # variable names? Better ways to include tutorial information?

  out <- tibble::tibble(
    id = purrr::map_chr(objs, "id",
                        .default = NA),
    submission_type = purrr::map_chr(objs, "type",
                                     .default = NA),
    answer = purrr::map_chr(objs, "answer",
                            .default = NA)
  )

  # Hacky

  out <- rbind(c(id = "tutorial-id", submission_type = "none", answer = tutorial_id), out)
  
  z <- knitr::kable(out, format = "html")
  write(as.character(z), file = file)

  NULL
}
