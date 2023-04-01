#' Write Tutorial Answers
#'
#' @param file location to render answers to. Output file type determined by
#'  file suffix. Acceptable values are "html", "rds" and "pdf".
#' @param session session object from shiny with learnr
#' @param is_test check if testing function
#'
#' @return NULL
#' @export

write_answers <- function(file, session, is_test = FALSE){
  
  type <- tools::file_ext(file)
  
  stopifnot(type %in% c("html", "rds", "pdf"))

  # Get submissions from learnr. Is it worthwhile to learn more about the
  # variables we can get from a submission object and then give the user some
  # choice about what to include? Should we get/print more information? See 
  # https://github.com/mattblackwell/qsslearnr/blob/main/R/submission.R
  # for an example.

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
  if(type == "pdf"){
    rows_per_page <- 10
    
    # Calculate the number of pages required to display the entire table
    
    num_pages <- ceiling(nrow(out) / rows_per_page)
    
    grDevices::pdf(file, height = 11, width = 8.5) 
    
    for (i in 1:num_pages) {
      # Calculate the range of rows to display on this page
      start_row <- (i - 1) * rows_per_page + 1
      end_row <- min(i * rows_per_page, nrow(out))
      
      # Subset the table to the rows to display on this page
      x_page <- out[start_row:end_row, ]
      
      # Display the table on this page
      gridExtra::grid.table(x_page)
      
      # Add a page break unless this is the last page
      if (i < num_pages) {
        grid::grid.newpage()
      }
    }
    
    grDevices::dev.off()
  }

  NULL
}
