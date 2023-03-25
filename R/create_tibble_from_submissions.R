#' Create Ordered Tibble from Submissions
#'
#' @param objs learnr session submissions
#' @param tutorial_id id of tutorial
#'
#' @return tibble with ordered answers based on label_list
#' @export

create_tibble_from_submissions <- function(objs, tutorial_id){

  # We are creating a tibble with 3 columns: id, submission_type, answer
  #
  # purrr::map_chr() and purrr::map() iterates over each object in a list,
  # extracting the correct attribute from the objects and returning a list.

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


}

