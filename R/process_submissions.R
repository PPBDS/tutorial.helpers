#' @title Process student submissions
#'
#' @description Creates a .csv file containing the tutorial name, student name, student email, and time spent for all .html files in the input folder. It is intended to be used by instructors.
#'
#' @details Uses rvest and tidyverse libraries.
#'
#' @param folder_path Input string. The path to a folder on your computer that contains all the .html files.
#'
#' @importFrom rvest read_html html_element html_table
#' 
#' @importFrom tidyverse read_csv str_glue add_row tibble
#'
#' @returns A .csv file with as many rows as .html files in the folder path.
#' 
#' @examples
#' process_submissions('C:/Users/Name/Documents/Student Responses')

process_submissions <- function(folder_path){
  
  # Listing the files in the folder path
  
  file_list <- list.files(folder_path, recursive = TRUE)
  
  # Selecting .html files
  
  html_file_list <- file_list[str_ends(file_list, ".html")]
  
  # Creating empty dataframe with four columns
  
  data <- read_csv("\n", col_names = c("tutorial_name", "student_name", "student_email", "time_spent"))
  
  # Looping over every file in the list of files
  
  for (file in html_file_list) {
    
    # Calling the read_submission on the file's path
    
    try(contents <- read_submission(str_glue(folder_path, file, .sep = '\\')), silent = TRUE)
    
    # Checking if the student typed their name, email and time spent
    
    if (!(contents$student_name == 'character(0)' | contents$student_email == 'character(0)' | contents$time_spent == 'character(0)')) {
      
      # Adding the extracted information to the tibble
      
      data <- data |>
        add_row(contents)
    }
  }
  
  # Creating a .csv file containing the extracted data
  
  write.csv(data, 'tutorial_info.csv', row.names = FALSE)
}

# read_submission takes a file path as input and extracts the tutorial name, student name, student email, and time spent from it

read_submission <- function(file_path){
  
  # Reading the html file as a table
  
  file <- read_html(file_path) |>
    html_element("table") |>
    html_table()
  
  # Extracting tutorial name, student name, student email, and time spent
  
  tutorial_name <- as.character(file[file$id == 'tutorial-id', "answer"])
  student_name <- as.character(file[file$id == 'information-name', "answer"])
  student_email <- as.character(file[file$id == 'information-email', "answer"])
  time_spent <- as.character(file[file$id == 'download-answers-1', "answer"])
  
  # Returning a tibble that contains the required information
  
  return(tibble(tutorial_name, student_name, student_email, time_spent))
}