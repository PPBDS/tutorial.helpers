#' Get Label Order (Deprecated with learnr version 0.10.1.9012)
#'
#' @param sess session object from shiny with learnr
#' @param is_test check if testing function
#'
#' @return list of labels in the correct order
#' @export

get_label_list <- function(sess, is_test = FALSE){

  # In order to keep same question order as in the exercise, use parsermd to
  # define factor level for exercise order and store it in label_list

  # information-name, information-email, download-answers-1 are questions that
  # are part of the child documents, which remain constant. Therefore, they are
  # added in manually.

  manual_list <- list("tutorial-id", "information-name", "information-email", "download-answers-1")

  rmd_path <- ifelse(is_test, "test-data/session_check_tutorial.Rmd",
                     file.path(sess$options$appDir, "tutorial.Rmd"))

  rmd <- parsermd::parse_rmd(rmd_path)

  rmd_tbl <- parsermd::as_tibble(rmd)

  rmd_chunk_labels <- dplyr::filter(rmd_tbl, rmd_tbl$type == "rmd_chunk")$label

  ls <- c(manual_list, rmd_chunk_labels)

  ls[ls != ""]
}
