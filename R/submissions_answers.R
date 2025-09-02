#' Extract Answers from Submissions with Filtering
#'
#' This function gathers submissions matching a title pattern, filters them by membership,
#' and extracts specified variables, returning a tibble with one row per valid submission
#' and one column per variable.
#'
#' @param path The path to the local directory or Google Drive folder URL containing submissions
#' @param title A character vector of patterns to match against file names (passed to gather_submissions)
#' @param key_var A character string specifying the key variable to check for membership (e.g., "email").
#'        If NULL (default), no membership filtering is applied.
#' @param membership A character vector of allowed values for the key variable, or "*" to include all submissions.
#'        If NULL (default), no membership filtering is applied. Ignored if key_var is NULL.
#' @param vars A character vector of variables/questions to extract, or "*" to extract all available variables
#' @param keep_file_name How to handle file names: NULL (don't include), "All" (full name),
#'        "Space" (up to first space), "Underscore" (up to first underscore)
#' @param verbose A logical value (TRUE or FALSE) specifying verbosity level.
#'        If TRUE, reports files that are removed during processing.
#'
#' @return A tibble with one row per valid submission, columns for each variable,
#'         and optionally a "source" column
#'
#' @importFrom dplyr mutate select
#' @importFrom tibble tibble as_tibble add_column
#' @importFrom purrr map_dfr
#'
#' @examples
#' \dontrun{
#' # Extract specific variables from submissions matching title pattern
#' path <- file.path(find.package("tutorial.helpers"), "tests/testthat/fixtures/answers_html")
#' 
#' result <- submissions_answers(
#'   path = path,
#'   title = c("stop"), 
#'   key_var = "email",
#'   membership = c("bluebird.jack.xu@gmail.com", "abdul.hannan20008@gmail.com"),
#'   vars = c("name", "email", "introduction-1"),
#'   verbose = TRUE
#' )
#' 
#' # Extract all variables from submissions
#' result_all <- submissions_answers(
#'   path = path,
#'   title = c("stop"), 
#'   key_var = "email",
#'   membership = c("bluebird.jack.xu@gmail.com", "abdul.hannan20008@gmail.com"),
#'   vars = "*",
#'   verbose = TRUE
#' )
#' 
#' drive_url <- "https://drive.google.com/drive/folders/10do12t0fZsfrIrKePxwjpH8IqBNVO86N"
#' x <- submissions_answers(
#'   path = drive_url, 
#'   title = c("introduction"),
#'   key_var = "email",
#'   membership = c("fmehmud325@gmail.com"),
#'   vars = c("email", "name", "what-you-will-learn-15")
#' )
#' }
#' @export

submissions_answers <- function(path, title, key_var = NULL, membership = NULL, vars, 
                               keep_file_name = NULL, verbose = FALSE) {
  
  # Input validation
  if (missing(path) || is.null(path)) {
    stop("'path' must be provided.")
  }
  
  if (missing(title) || is.null(title)) {
    stop("'title' must be provided.")
  }
  
  if (missing(vars) || is.null(vars)) {
    stop("'vars' must be provided.")
  }
  
  # Validate key_var and membership consistency
  if (!is.null(key_var) && is.null(membership)) {
    stop("'membership' must be provided when 'key_var' is specified.")
  }
  
  if (is.null(key_var) && !is.null(membership)) {
    stop("'key_var' must be provided when 'membership' is specified.")
  }
  
  # Validate verbose parameter
  if (!is.logical(verbose) || length(verbose) != 1) {
    stop("'verbose' must be a single logical value (TRUE or FALSE).")
  }
  
  # Validate keep_file_name parameter
  if (!is.null(keep_file_name) && !(keep_file_name %in% c("All", "Space", "Underscore"))) {
    stop("Invalid keep_file_name. Allowed values are NULL, 'All', 'Space', or 'Underscore'.")
  }
  
  # Step 1: Gather submissions matching the title pattern
  tibble_list <- gather_submissions(path = path, title = title, verbose = FALSE)
  
  if (verbose && length(tibble_list) > 0) {
    message("Found ", length(tibble_list), " submission(s) matching title pattern '", paste(title, collapse = "|"), "'")
  }
  
  if (length(tibble_list) == 0) {
    if (verbose) {
      message("No submissions found matching the title pattern.")
    }
    return(tibble::tibble())
  }
  
  # Step 2: Filter by membership using check_membership, or skip if no filtering requested
  if (is.null(key_var) || is.null(membership)) {
    # No membership filtering - include all submissions
    valid_tibbles <- tibble_list
    if (verbose) {
      message("No membership filtering applied - including all ", length(tibble_list), " submission(s)")
    }
  } else if (length(membership) == 1 && membership == "*") {
    # Include all submissions - no membership filtering
    valid_tibbles <- tibble_list
    if (verbose) {
      message("Membership set to '*' - including all ", length(tibble_list), " submission(s)")
    }
  } else {
    # Apply membership filtering
    valid_tibbles <- check_membership(tibble_list, key_var, membership, verbose = FALSE)
    
    if (verbose) {
      message("After membership filtering: ", length(valid_tibbles), " submission(s) retained")
    }
  }
  
  if (length(valid_tibbles) == 0) {
    if (verbose) {
      message("No submissions passed the membership check.")
    }
    return(tibble::tibble())
  }
  
  # Step 2.5: Determine which variables to extract
  if (length(vars) == 1 && vars == "*") {
    # Extract all available variables from all submissions
    all_vars <- character(0)
    for (tibble_data in valid_tibbles) {
      if ("id" %in% colnames(tibble_data)) {
        all_vars <- unique(c(all_vars, tibble_data$id))
      }
    }
    vars_to_extract <- all_vars
    
    if (verbose) {
      message("Extracting all available variables: ", paste(vars_to_extract, collapse = ", "))
    }
  } else {
    vars_to_extract <- vars
  }
  
  # Step 3: Extract answers and create final tibble
  result <- purrr::map_dfr(names(valid_tibbles), function(file_name) {
    tibble_data <- valid_tibbles[[file_name]]
    
    # Create base row with source information if requested
    if (!is.null(keep_file_name)) {
      if (keep_file_name == "All") {
        source_name <- file_name
      } else if (keep_file_name == "Space") {
        source_name <- sub("\\s.*", "", file_name)
      } else if (keep_file_name == "Underscore") {
        source_name <- sub("_.*", "", file_name)
      }
    }
    
    # Initialize result row
    row_data <- list()
    
    # Add source column if requested
    if (!is.null(keep_file_name)) {
      row_data[["source"]] <- source_name
    }
    
    # Extract each variable
    for (var in vars_to_extract) {
      if ("id" %in% colnames(tibble_data) && var %in% tibble_data$id) {
        # Get the answer for this variable - check for both 'answer' and 'data' columns
        if ("answer" %in% colnames(tibble_data)) {
          answer_value <- tibble_data$answer[tibble_data$id == var]
        } else if ("data" %in% colnames(tibble_data)) {
          answer_value <- tibble_data$data[tibble_data$id == var]
        } else {
          answer_value <- character(0)
        }
        # Take first answer if multiple exist
        row_data[[var]] <- if (length(answer_value) > 0) answer_value[1] else NA
      } else {
        # Variable not found, set to NA
        row_data[[var]] <- NA
      }
    }
    
    # Convert to tibble
    tibble::as_tibble(row_data)
  })
  
  return(result)
}