#' Build RDS Submission Object
#'
#' @param file location to save RDS file
#' @param session session object from shiny with learnr
#' @param is_test check if testing function
#'
#' @return location of the rds file
#' @export

build_rds <- function(file, session, is_test = FALSE){

  # Get submissions from learnr

  # Data Structure of a learnr submission object

  # obj$answer[[1]] "answer"
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


  # save tibble object in destination

  saveRDS(out, file)

}
