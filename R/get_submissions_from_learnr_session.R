#' Get Submissions from a learnr Session
#'
#' @param sess session object from shiny with learnr
#'
#' @return exercise submissions of tutorial
#' @export

get_submissions_from_learnr_session <- function(sess){

  # This is an annoying link of the entire chain of building the submission
  # report because it has to communicate with the learnr session ENVIRONMENT,
  # not just the object.

  # Since we are using the session environment, we currently don't have a way to
  # save the environment and hence can't test this function.

  # So learnr:::get_all_state_objects() finds and returns ALL state objects
  # relating to the session environment and tutorial. This includes the tutorial
  # id, version, submissions, everything that defines the current "state".

  # learnr:::submissions_from_state_objects() then filters the results to only
  # submission-related state objects, which are the student answers.

  # objs <- learnr:::get_all_state_objects(sess)
  # learnr:::submissions_from_state_objects(objs)

  # In the commits on August 12th and 14th, the need to use any ::: have been
  # eliminated as we can read all the tutorial info and state from newly
  # provided functions:
  # learnr::get_tutorial_state()
  # learnr::get_tutorial_info()

  # Unfortunately, the answers in learnr::get_tutorial_state() are not provided
  # in order of appearance, so we still need get_label_list() to get the label
  # order

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
