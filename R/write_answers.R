#' Write Tutorial Answers
#'
#' @param file location to render answers to. Output file type determined by
#'  file suffix.
#' @param session session object from shiny with learnr
#' @param is_test check if testing function
#'
#' @return NULL
#' @export

write_answers <- function(file, session, is_test = FALSE){
  
  type <- tools::file_ext(file)
  
  stopifnot(type %in% c("html", "rds"))

  # Get submissions from learnr. Is it worthwhile to learn more about the
  # variables we can get from a submission object and then give the user some
  # choice about what to include?

  # Data Structure of a learnr submission object

  # obj$data$answer[[1]] question answer
  # obj$data$code[[1]] "exercise answer"
  # obj$type[[1]] "exercise_submission"
  # obj$id[[1]] "id"

  if(is_test){
    objs <- readRDS("test-data/submission_test_outputs/learnr_submissions_output.rds")
    tutorial_id <- "data-webscraping"
  }
  else{
    objs <- get_submissions_from_learnr_session(session)
    tutorial_id <- learnr::get_tutorial_info()$tutorial_id
  }

  # Create tibble for saving.

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

  # It is unclear what is the best format for providing this information.

  if(type == "html"){
    z <- knitr::kable(out, format = "html")
    write(as.character(z), file = file)
  }
  if(type == "rds"){
    saveRDS(out, file)
  }

  NULL
}
