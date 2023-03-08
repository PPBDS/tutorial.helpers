#' Google Submission Collection
#'
#' @param key client id obtained from oauth credentials
#' @param secret client secret obtained from oauth credentials
#' @param tutorial_id id of tutorial to save and process
#' @param after_date keep only mails after this date: use YYYY-MM-DD
#' @param before_date (Optional) keep only mails before this date: use YYYY-MM-DD
#'
#' @description Always answer `0` when gmailr asks you: "Select a pre-authorised
#' account or enter '0' to obtain a new token." Hope to fix this hack in the future.
#'
#' @export

google_submission_collection <- function(key,
                                         secret,
                                         tutorial_id,
                                         after_date,
                                         before_date = NULL){
  gmail.filter <- paste0("in:inbox has:attachment after:", after_date)

  if (!is.null(before_date)){
    gmail.filter <- paste0(gmail.filter , " before:", before_date)
  }

  message("Clearing tempory directory")

  # Note that tempdir() produces the same directory string however many times
  # you call it with a single R session. So, there is nothing wrong with making
  # sure that it is empty at the start of this script.

  unlink(file.path(normalizePath(tempdir()), dir(tempdir())), recursive = TRUE)

  message("Accessing Gmail")

  rds_paths <- gmail_access(gmail.filter, tutorial_id, key, secret)

  message("Finished downloading files from Gmail")

  # The format used in readr::parse_date() works with any separator between the
  # digits, which allows this function to handle possible weird inputs. This
  # separation of dates is used solely to create the folder name in Google Drive
  # in gdrive_access().

  parsed_date <- readr::parse_date(after_date, "%Y%.%m%.%d")

  year <- format(parsed_date, "%Y")

  month <- format(parsed_date, "%m")

  day <- format(parsed_date, "%d")

  message("Accessing Google Drive")

  new_sub <- gdrive_access(tutorial_id, year, month, day, tempdir(), rds_paths)

  message("Submissions of query ", new_sub, " successfully collected!")
}
