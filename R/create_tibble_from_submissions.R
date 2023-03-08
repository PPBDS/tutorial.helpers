#' Create Ordered Tibble from Submissions
#'
#' @param objs learnr session submissions
#' @param tutorial_id id of tutorial
#' @param label_list order of code chunks (Optional with learnr version 0.10.1.9012)
#'
#' @return tibble with ordered answers based on label_list
#' @export

create_tibble_from_submissions <- function(objs, tutorial_id, label_list = NULL){


  # Format objs from learnr into a tibble
  #
  # We are creating a tibble with 3 columns: id, submission_type, answer
  #
  # purrr::map_chr() and purrr::map() iterates over each object in a list,
  # extracting the correct attribute from the objects and returning a list.

  if (is.null(label_list)){
    # With new version of learnr, exercises are automatically arranged by order
    # of appearance
    label_list <- purrr::map_chr(objs, "id", .default = NA)
    label_list <- label_list[label_list != "download-answers-1"]
    label_list <- append(label_list, "tutorial-id", 0)
    label_list <- append(label_list, "download-answers-1", 3)
  }

  out <- tibble::tibble(
    id = purrr::map_chr(objs, "id",
                        .default = NA),
    submission_type = purrr::map_chr(objs, "type",
                                     .default = NA),
    answer = purrr::map_chr(objs, "answer",
                        .default = NA)
  )

  out <- rbind(c(id = "tutorial-id", submission_type = "none", answer = tutorial_id), out)

  out$id <- factor(out$id, levels = label_list)

  dplyr::arrange(out, out$id)

}

