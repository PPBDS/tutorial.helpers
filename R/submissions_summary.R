#' Process Submissions Summary
#'
#' This function processes submissions from a local directory or Google Drive folder containing HTML/XML files.
#' It extracts tables from the files, filters them based on a pattern and key variables,
#' and returns either a summary tibble or a combined tibble with all the data.
#'
#' @param path The path to the local directory containing the HTML/XML files, or a Google Drive folder URL.
#'        If it's a Google Drive URL, the function will download individual files to a temporary directory.
#' @param title A character vector of patterns to match against the file names (default: ".").
#'        Each pattern is processed separately and results are combined.
#' @param emails A character vector of email addresses to filter results by, "*" to include all emails, or NULL to skip email filtering (default: NULL).
#' @param return_value The type of value to return. Allowed values are "Summary" (default) or "All".
#' @param vars A character vector of key variables to extract from the "id" column (default: NULL).
#' @param verbose A logical value (TRUE or FALSE) specifying verbosity level.
#'        If TRUE, reports files that are removed during processing.
#' @param keep_file_name Specifies whether to keep the file name in the summary tibble. Allowed values are NULL (default), "All" (keep entire file name), "Space" (keep up to first space), or "Underscore" (keep up to first underscore). Only used when `return_value` is "Summary".
#'
#' @return If `return_value` is "Summary", returns a tibble with one row for each file, columns corresponding to the `vars`,
#'         and an additional "answers" column indicating the number of rows in each tibble.
#'         If `return_value` is "All", returns a tibble with all the data combined from all the files.
#'
#' @examples
#' # Process submissions from local directory
#' path <- system.file("extdata", "answers_html", package = "tutorial.helpers")
#'
#' result <- submissions_summary(path = path,
#'                              vars = "email",
#'                              title = "stop")
#'
#' \dontrun{
#' drive_url <- "https://drive.google.com/drive/folders/10do12t0fZsfrIrKePxwjpH8IqBNVO86N"
#' x <- submissions_summary(
#'   path = drive_url, 
#'   title = c("positron"),
#'   vars = c("email", "name")
#' )
#' 
#' 
#' }
#' @export
submissions_summary <- function(path, 
                                title = ".", 
                                return_value = "Summary", 
                                vars = NULL, 
                                verbose = FALSE, 
                                keep_file_name = NULL,
                                emails = NULL) {
  
  # Validation: path must be provided
  if (missing(path) || is.null(path)) {
    stop("'path' must be provided.")
  }
  
  # Validate verbose parameter
  if (!is.logical(verbose) || length(verbose) != 1) {
    stop("'verbose' must be a single logical value (TRUE or FALSE).")
  }
  
  # Check if return_value is valid
  if (!(return_value %in% c("Summary", "All"))) {
    stop("Invalid return_value. Allowed values are 'Summary' or 'All'.")
  }
  
  # Check if vars is provided when return_value is "Summary"
  if (return_value == "Summary" && is.null(vars)) {
    stop("vars must be provided when return_value is 'Summary'.")
  }
  
  if (!is.null(keep_file_name) && return_value != "Summary") {
    stop("keep_file_name can only be used when return_value is 'Summary'.")
  }
  
  if (!is.null(keep_file_name) && !(keep_file_name %in% c("All", "Space", "Underscore"))) {
    stop("Invalid keep_file_name. Allowed values are NULL, 'All', 'Space', or 'Underscore'.")
  }
  
  # Call gather_submissions to get the list of tibbles. It has already
  # filtered by every pattern in `title` and deduplicated the files, so we
  # process each file exactly once; re-looping over the patterns here would
  # duplicate files matched by more than one pattern.
  tibble_list <- gather_submissions(path = path, title = title, verbose = verbose)

  filtered_tibble_list <- list()
  removed_files <- character()
  removal_reasons <- character()

  for (file_name in names(tibble_list)) {
    tibble_data <- tibble_list[[file_name]]

    # Answers are stored in an 'answer' column or, in older files, a 'data'
    # column.
    answer_col <- if ("answer" %in% colnames(tibble_data)) {
      "answer"
    } else if ("data" %in% colnames(tibble_data)) {
      "data"
    } else {
      NA_character_
    }

    if (!"id" %in% colnames(tibble_data) || is.na(answer_col)) {
      removed_files <- c(removed_files, file_name)
      removal_reasons <- c(removal_reasons, "no 'id' and 'answer' (or 'data') columns")
      next
    }

    if (!is.null(vars) && !all(vars %in% tibble_data$id)) {
      missing_vars <- setdiff(vars, tibble_data$id)
      removed_files <- c(removed_files, file_name)
      removal_reasons <- c(removal_reasons, paste("missing key variables:", paste(missing_vars, collapse = ", ")))
      next
    }

    if (!is.null(emails) && !identical(emails, "*")) {
      email_value <- tibble_data[[answer_col]][tibble_data$id == "email"][1]
      if (is.na(email_value) || !email_value %in% emails) {
        removed_files <- c(removed_files, file_name)
        removal_reasons <- c(removal_reasons, "email not in 'emails'")
        next
      }
    }

    for (key_var in vars) {
      key_var_value <- tibble_data[[answer_col]][tibble_data$id == key_var][1]
      tibble_data[[key_var]] <- key_var_value
    }
    filtered_tibble_list[[file_name]] <- tibble_data
  }

  # Report removed files if verbose
  if (verbose && length(removed_files) > 0) {
    for (i in seq_along(removed_files)) {
      message("Removed '", removed_files[i], "': ", removal_reasons[i])
    }
  }

  if (length(filtered_tibble_list) == 0) {
    return(tibble::tibble())
  }

  if (return_value == "Summary") {
    summary_rows <- lapply(names(filtered_tibble_list), function(file_name) {
      tibble_data <- filtered_tibble_list[[file_name]]
      answers <- nrow(tibble_data)

      if (!is.null(keep_file_name)) {
        if (keep_file_name == "All") {
          source_name <- file_name
        } else if (keep_file_name == "Space") {
          source_name <- sub("\\s.*", "", file_name)
        } else if (keep_file_name == "Underscore") {
          source_name <- sub("_.*", "", file_name)
        }
      } else {
        source_name <- NULL
      }

      # First row, keeping only the requested vars, plus an answers count.
      summary_row <- tibble_data[1, vars, drop = FALSE]
      summary_row[["answers"]] <- answers

      if (!is.null(source_name)) {
        summary_row <- tibble::add_column(summary_row, source = source_name, .before = 1)
      }

      summary_row
    })
    combined_results <- do.call(rbind, summary_rows)
  } else {
    combined_results <- do.call(rbind, filtered_tibble_list)
  }

  tibble::as_tibble(combined_results)
}