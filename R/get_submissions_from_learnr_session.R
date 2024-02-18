#' Return a list of tutorial answers
#'
#' @description Grabs information from the `learnr` session environment, not
#'   directly from the session object itself. Since we are using the session
#'   environment, we currently don't (?) have a way to save the environment and
#'   hence can't test this function.
#'
#' @param sess session object from shiny with learnr
#'
#' @returns a list which includes the exercise submissions of tutorial

get_submissions_from_learnr_session <- function(sess){

  # Why not just make this a tibble, rather than a nested list? Certainly  would
  # make later code easier.
  
  # Note that get_tutorial_state(), with its `label` argument, allows you to
  # grab the answer to a single question. Also, the returned object has a
  # `timestamp` entry. Perhaps these would be of use somehow?
  
  # As best I can tell, get_tutorial_state() can only return questions which
  # students have answered. You need to do something else, get_tutorial_info(),
  # to get a list of all the questions.
  
  # get_tutorial_info() returns a list, one element of which is `items`

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
