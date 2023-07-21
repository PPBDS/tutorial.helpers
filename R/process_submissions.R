#' @title Process Submissions
#'
#' @description Creates a .csv file containing the tutorial name, student name, student email, and time spent for all .html files in the input folder.
#'
#' @details Uses tidyverse, stringr, and dplyr libraries.
#'
#' @param folder_path Input string. The path to a folder on your computer that contains all the .html files.
#'
#' @returns A .csv file with as many rows as .html files in the folder path.
#' 
#' @examples
#' process_submissions('C:/Users/Name/Documents/Student Responses')

# Loading libraries
library(tidyverse)
library(stringr)
library(dplyr)

process_submissions <- function(folder_path){
  file_list <- list.files(folder_path, recursive = TRUE)
  html_file_list <- file_list[str_ends(file_list, ".html")]
  tbl_colnames <- c("tutorial_name", "student_name", "student_email", "time_spent")
  data <- read_csv("\n", col_names = tbl_colnames)
  
  for (file in html_file_list) {
    file_path <- str_glue(folder_path, file, .sep = '\\')
    contents <- readLines(file_path)
    
    file_tutorial_name <- gsub(".*<td style=\"text-align:left;\"> (.+) </td>*", "\\1", contents[13])
    file_student_name <- gsub(".*<td style=\"text-align:left;\"> (.+) </td>*", "\\1", contents[18])
    file_student_email <- gsub(".*<td style=\"text-align:left;\"> (.+) </td>*", "\\1", contents[23])
    file_time_spent <- gsub(".*<td style=\"text-align:left;\"> (.+) </td>*", "\\1", contents[sum(str_count(contents, "\n") + 1) - 3])
    
    data <- data %>% add_row(tutorial_name = file_tutorial_name, 
                             student_name = file_student_name, 
                             student_email = file_student_email,
                             time_spent = file_time_spent)
  }
  
  # Removing long values in student_name, student_email, time_spent
  data <- data[which(nchar(data$student_name) <= 32), ]
  data <- data[which(nchar(data$student_email) <= 32), ]
  data <- data[which(nchar(data$time_spent) <= 5), ]
  
  # Removing special characters
  data$tutorial_name <- str_replace_all(data$tutorial_name, "[^a-z-]", "")
  data$student_name <- str_replace_all(data$student_name, "[^a-zA-Z ]", "")
  data <- data[grepl("@", data$student_email), ]
  
  # Last line of defense for time_spent
  data$time_spent <- str_replace_all(data$time_spent, "[^0-9]", "")
  data$time_spent <- as.numeric(data$time_spent)
  data <- data[!is.na(data$time_spent), ]
  data <- data |>
    filter(time_spent <= 600)
  
  # Last line of defense for student_name
  data <- data[!str_detect(data$student_name, "^   td styletext"), ]
  data <- data[!str_detect(data$student_name, "^httpscommunity"), ]
  data <- data[!str_detect(data$student_name, "^library"), ]
  data <- data[!str_detect(data$student_name, "^df"), ]
  data <- data[!str_detect(data$student_name, "mailcom$"), ]
  data <- data[!str_detect(data$student_name, "^student_name"), ]
  data <- data[!str_detect(data$student_name, "^substack"), ]
  data <- data[!str_detect(data$student_name, "analysisgt$"), ]
  
  # Last line of defense for student_email
  data <- data[!str_detect(data$student_name, "^   td styletext"), ]
  data <- data[!str_detect(data$student_name, "^httpscommunity"), ]
  data <- data[!str_detect(data$student_name, "^help"), ]
  
  # Writing csv file
  write.csv(data, 'tutorial_info.csv', row.names = FALSE)
}

process_submissions('C:\\Users\\Rajarshi\\OneDrive\\Documents\\New Laptop March 2021\\Rishi\\Data Science (R)\\Internship\\Student Responses')
