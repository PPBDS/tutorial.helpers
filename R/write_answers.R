#' Write tutorial answers to file
#'
#' @description Take a tutorial session, extract out all the submitted answers,
#'   and write out a file --- either as html, rds or pdf --- with all of those
#'   answers.
#'
#' @details We only keep track of the questions/exercises that the student has
#'   completed. So, if she only answers three questions, the resulting output
#'   will only have 6 rows (the three answers plus the header row plus the first
#'   row with tutorial info plus the last row with the time taken). The other
#'   obvious approach is to keep all the questions/exercises and leave
#'   unanswered ones as NA. Not sure if that approach is better, or even
#'   possible.
#'
#' @param file Location to render answers to. Output file type determined by
#'   file suffix. Acceptable values are "html", "rds" and "pdf".
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
#'   write_answers("outfile.pdf", sess)
#' }
#'   
#' @export


write_answers <- function(file, session, is_test = FALSE){
  
  suffix <- tools::file_ext(file)
  
  stopifnot(suffix %in% c("html", "rds", "pdf"))

  # Get submissions from learnr session. Is it worthwhile to learn more about
  # the variables we can get from a submission object and then give the user
  # some choice about what to include? Should we get/print more information? See
  # https://github.com/mattblackwell/qsslearnr/blob/main/R/submission.R for an
  # example.
  


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
  
  # Long answers to the written exercises mess up the formatting. So, we need
  # to insert our own newline characters. (This will mess up things for any
  # student who uses their own carriage returns. Could clean this up in the
  # future.) No need to do this for the rds output.
  
  # if(suffix %in% c("html", "pdf")){
  #   out$answer <- gsub("(.{1,80})(\\s+|$)", "\\1\n", out$answer)
  # }

  # It is unclear what is the best format for providing this information.

  if(suffix == "html"){
    z <- knitr::kable(out, format = "html")
    write(as.character(z), file = file)
  }
  if(suffix == "rds"){
    saveRDS(out, file)
  }
  if(suffix == "pdf"){
    
    # There are several problems with pdf output. First, there is no simple
    # approach (that I can find) like the ones above for html and RDS. So, we
    # need to hack it up. Second, we need to do the pagination by hand. 
    
    # Key code: gsub("(.{1,80})(\\s+|$)", "\\1\n", x)
    
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
