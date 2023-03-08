
#' Google Drive Submission Processing
#'
#' @param tutorial_id id of tutorial to save and process
#' @param year year from parsed_date
#' @param month month from parsed_date
#' @param day day from parsed_date
#' @param temp_path path of tempdir()
#' @param rds_paths paths of saved rds files from gmail
#'
#' @return folder name of submission results
#' @export
#'
gdrive_access <- function(tutorial_id, year, month, day, temp_path, rds_paths){

  # gmailr and googledrive use the same configurations, so we don't need to
  # configure again.

  googledrive::drive_auth()

  # For the best user experience, we try not to require the user to set up
  # anything for this other than the service account. Therefore, we check and
  # handle everything from if they have a submission_folder/ to if they have
  # already done this query, etc.

  new_sub <- paste0(tutorial_id,
                    "-",
                    year,
                    "-",
                    month,
                    "-",
                    day)

  new_dir <- file.path("submission_folder",
                       new_sub)


  if (!("submission_folder" %in% googledrive::drive_ls("~")$name)){
    message("submission_folder not detected in drive,\ncreating submission_folder:")

    googledrive::drive_mkdir("submission_folder")
  }

  if (new_sub %in% googledrive::drive_ls("submission_folder")$name){
    message(paste0("Replace results of previous query: ", new_sub))

    googledrive::drive_rm(new_dir)
  }

  googledrive::drive_mkdir(new_dir)

  # create_submission_aggregation() should return a tibble, we are iterating
  # over it to uplaod the relevant files onto Google Drive.

  submission_info <- create_submission_aggregation(rds_paths, tutorial_id, new_dir)

  for (i in seq_along(submission_info[[1]])){
    googledrive::drive_upload(
      submission_info$curr_path[[i]],
      path = new_dir,
      name = submission_info$filename[[i]]
    )
  }

  googledrive::drive_upload(
    file.path(temp_path, "submission_aggregation.csv"),
    path = new_dir,
    name = "submission_aggregation.csv",
    type = "spreadsheet"
  )

  new_sub
}


