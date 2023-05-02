#' Get Submissions from a learnr Session
#'
#' @param sess session object from shiny with learnr
#' 
#' @return a list which includes the exercise submissions of tutorial

get_submissions_from_learnr_session <- function(sess){

  # This is an annoying link of the entire chain of building the submission
  # report because it has to communicate with the learnr session ENVIRONMENT,
  # not just the object.

  # Since we are using the session environment, we currently don't (?) have a
  # way to save the environment and hence can't test this function. (Not sure
  # this is true.)

  # Why not just make this a tibble, rather than a nested list? Certainly  would
  # make later code easier.

  curr_state <- learnr::get_tutorial_state(session = sess)

  label_names <- names(curr_state)

  obj_list <- list()

  for (n in label_names){
    obj_list[[n]] <- list(
      id = n,
      type = curr_state[[n]]$type,
      answer = curr_state[[n]]$answer
    )
  }

  obj_list
}
