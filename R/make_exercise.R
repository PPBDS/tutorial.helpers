#' @title Add a tutorial code exercise or question to the active document
#'
#' @rdname exercise_creation
#'
#' @description When writing tutorials, it is handy to be able to insert the
#'   skeleton for a new code exercise or question. Note that the
#'   function determines the correct exercise number to use and also adds
#'   appropriate code chunk labels, based on the exercise number and section
#'   title.
#'
#' @param type Character of question type. Must be one of "code", "no-answer",
#'   or "yes-answer". Abbreviations such as "no", "yes", and "co" are allowed.
#'
#' @param file_path Character path to a file. If NULL, the RStudio active
#'   document is used, which is the default behavior. An actual file path is
#'   used for testing.
#'
#' @importFrom rstudioapi getActiveDocumentContext insertText
#'
#' @returns Exercise skeleton corresponding to the `type` argument.
#'
#' @export

make_exercise <- function(type = "no-answer", file_path = NULL) {
  
  # Determine the actual file path to use
  
  if (is.null(file_path)) {
    
    # Get the active document context to find its path
    
    ctx <- rstudioapi::getActiveDocumentContext()
    if (is.null(ctx)) {
      stop("No active document. Please open an Rmd file.")
    }
    
    # Get the path of the active document
    
    active_doc_path <- ctx$path
    if (is.null(active_doc_path) || active_doc_path == "") {
      stop("Active document has not been saved. Please save the document first.")
    }
    
    working_path <- active_doc_path
  } else {
    working_path <- file_path
  }
  
  
  # Now we can properly determine exercise number and section ID from the actual document
  
  exercise_number <- determine_exercise_number(working_path)
  section_id <- determine_code_chunk_name(working_path)
  
  
  # Handle empty section_id - use a default if it's empty
  
  if (is.null(section_id) || section_id == "" || is.na(section_id)) {
    section_id <- "exercise"
  }
  
  
  # Ensure exercise_number is valid
  
  if (is.null(exercise_number) || is.na(exercise_number)) {
    exercise_number <- 1
  }
  
  
  # Allow abbreviated type inputs (e.g., "no" for "no-answer", "ye" for "yes-answer")
  
  allowed_types <- c("no-answer", "yes-answer", "code")
  
  
  # Expand abbreviations
  
  if (!type %in% allowed_types) {
    match_idx <- pmatch(type, allowed_types)
    if (is.na(match_idx)) stop("Invalid type argument.")
    type <- allowed_types[match_idx]
  }
  
  
  # Compose the exercise skeleton
  
  new_exercise <- switch(type,
    "no-answer" = sprintf(
      "### Exercise %s\n\n\n```{r %s-%s}\nquestion_text(NULL,\n\tanswer(NULL, correct = TRUE),\n\tallow_retry = TRUE,\n\ttry_again_button = \"Edit Answer\",\n\tincorrect = NULL,\n\trows = 5)\n```\n\n###\n\n```{r %s-%s-test, echo = TRUE}\n\n```\n\n###\n\n",
      exercise_number,
      section_id,
      exercise_number,
      section_id,
      exercise_number
    ),
    "yes-answer" = sprintf(
      "### Exercise %s\n\n\n```{r %s-%s}\nquestion_text(NULL,\n\tmessage = \"Place correct answer here.\",\n\tanswer(NULL, correct = TRUE),\n\tallow_retry = FALSE,\n\tincorrect = NULL,\n\trows = 6)\n```\n\n###\n\n",
      exercise_number,
      section_id,
      exercise_number
    ),
    "code" = sprintf(
      "### Exercise %s\n\n\n```{r %s-%s, exercise = TRUE}\n\n```\n\n<button onclick = \"transfer_code(this)\">Copy previous code</button>\n\n```{r %s-%s-hint, eval = FALSE}\n\n```\n\n```{r %s-%s-test, include = FALSE}\n\n```\n\n###\n\n",
      exercise_number,
      section_id,
      exercise_number,
      section_id,
      exercise_number,
      section_id,
      exercise_number
    ),
    stop("Unknown type argument to make_exercise()")
  )
  
  
  # --- Insertion logic ---
  # If file_path is NULL, we are in Positron/RStudio and want to insert into the active document
  
  if (is.null(file_path)) {
    
    # Get the current cursor position/selection
    
    if (length(ctx$selection) > 0 && !is.null(ctx$selection[[1]])) {
      
      # Extract the range from the current selection
      
      cursor_range <- ctx$selection[[1]]$range
      
      
      # Insert the text at the cursor position
      
      rstudioapi::insertText(location = cursor_range, text = new_exercise)
      
    } else {
      stop("Could not determine cursor position in the active document.")
    }
    
  } else {
    
    # If file_path is provided (for testing): write or append to file
    
    cat(new_exercise, file = file_path, append = TRUE)
    invisible(new_exercise)
  }
}