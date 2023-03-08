#' Gmail Access and Submission Processing
#'
#' @param query used to filter mails to find submissions
#' @param tut_id tutorial id for filtering submissions
#' @param key client id obtained from oauth credentials
#' @param secret client secret obtained from oauth credentials
#'
#' @return rds_paths paths of locally saved rds files from gmail
#' @export

gmail_access <- function(query, tut_id, key, secret){

  # In order to get the full Gmail authentication needed to read emails and
  # download attachments, we have to manually configure and call authentication
  # for Gmailr.

  gmailr::gm_auth_configure(key = key,
                            secret = secret)

  gmailr::gm_auth()

  # We don't want to download all the attachments ever received, so we filter
  # the gmail messages with the query we received.

  temp_path <- tempdir()

  messages <- gmailr::gm_messages(query)[[1]][[1]]

  rds_paths <- list()

  for (message_id in purrr::map_chr(messages, "id")){

    # We had a couple of errors in which we downloaded all kinds of attachments,
    # so we also need to only keep rds files. If a message doesn't have an
    # attachment on the starting message of the thread, it's also skipped.

    tryCatch({
      msg <- gmailr::gm_message(message_id)

      fn <- paste0("submission_", message_id, ".rds")

      print(gmailr::gm_attachments(msg))

      attached <- gmailr::gm_attachments(msg)

      if (length(attached) < 1){
        next
      }

      if (!stringr::str_detect(attached$filename[[1]], "\\.rds$")){
        next
      }
      
      if (!stringr::str_detect(attached$filename[[1]], tut_id)){
        next
      }

      attach_id <- gmailr::gm_attachments(msg)$id[[1]]

      attach_obj <- gmailr::gm_attachment(attach_id, message_id)

      new_path <- file.path(temp_path, fn)

      gmailr::gm_save_attachment(attach_obj, new_path)

      print(paste0("Saved attachment in tempdir:\n", new_path))

      rds_paths <- append(rds_paths, new_path)
    },
    error = function(cond){
      # Leave this empty for skipping errors
    })

  }

  rds_paths
}


# Access Gmail with gmailr::gm_auth_configure(key = "", secret = "") and
# gm_auth()
#
# where should we save the key and secret? Maybe environment variables?



# Use gmailr::gm_messages() to search for email based on gmail searchbar filters
#
# "has:attachment" searches for all emails received with an attachment
#
# "before:2004/04/16" searches for all emails before a certain date
#
# "after:2004/04/16" searches for all emails after a certain date
#
# "older_than:2d" or "newer_than:2m" (d is day, m is month, y is year) search
# for all emails older/newer than a time period.
#
# "filename:homework.txt" or "filename:pdf" searches for all emails with certain
# name or file type
#
# More information about gmail operator details:
#
# https://support.google.com/mail/answer/7190?hl=en

# Get message with gmailr::gm_message(message_id)

# Get attachment id with gmailr::gm_attachments(message)$id[[1]]

# Get attachment object with gmailr::gm_attachment(id, message_id)

# Save attachment with gmailr::gm_save_attachment(attachment, filename)

# Full pipeline:
#
# gmailr::gm_auth_configure(key = "KEY", secret = "SECRET_KEY")
#
# gmailr::gm_auth()
#
# for each message_id in gmailr::gm_messages("some filter options"):
#
#   msg = gmailr::gm_message(message_id)
#
#   attachment_id = gmailr::gm_attachments(msg)$id[[1]]
#
#   attachment_obj = gmailr::gm_attachment(attachment_id, message_id)
#
#   gmailr::gm_save_attachment(attachment_obj, filename)
#
#
# gmailr::gm_deauth()



