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
  
  # --- Step 1: Determine the Content Context ---
  
  # We need to determine what "text" we are analyzing to generate the numbers.
  # If file_path is provided, we use that file (Testing mode).
  # If file_path is NULL, we use the Active Document (Interactive mode).
  
  # Variable to track if we created a temp file that needs deletion
  temp_file_created <- NULL
  
  if (is.null(file_path)) {
    
    # Get the active document context
    ctx <- rstudioapi::getActiveDocumentContext()
    
    if (is.null(ctx)) {
      stop("No active document. Please open an Rmd file.")
    }
    
    # --- THE TRICK ---
    # Instead of using the file path on disk (which includes the WHOLE file),
    # we grab the content from the editor buffer and slice it at the cursor.
    # This ensures we only count exercises *before* the insertion point.
    
    # 1. Get all lines from the buffer
    all_contents <- ctx$contents
    
    # 2. Identify the cursor row (start of the selection range)
    if (length(ctx$selection) > 0 && !is.null(ctx$selection[[1]])) {
      cursor_row <- ctx$selection[[1]]$range$start["row"]
    } else {
      cursor_row <- length(all_contents) # Fallback to end if no cursor found
    }
    
    # 3. Slice content: Keep only lines 1 up to the cursor
    # We ensure we take at least one line to avoid errors
    if (cursor_row < 1) cursor_row <- 1
    preceding_content <- all_contents[1:cursor_row]
    
    # 4. Write this partial content to a temporary file.
    # We do this because determine_exercise_number() expects a file path argument.
    temp_file <- tempfile(fileext = ".Rmd")
    writeLines(preceding_content, temp_file)
    
    # Set the working path to this temp file for the calculation steps
    working_path <- temp_file
    temp_file_created <- temp_file
    
  } else {
    # Testing mode: Use the provided file path exactly as is
    working_path <- file_path
  }
  
  
  # --- Step 2: Calculate Numbers and IDs ---
  
  # Now we determine exercise number and section ID using the working path
  # (which is either the full test file or the partial temp file)
  
  exercise_number <- determine_exercise_number(working_path)
  section_id <- determine_code_chunk_name(working_path)
  
  # Clean up the temp file if we made one
  if (!is.null(temp_file_created) && file.exists(temp_file_created)) {
    unlink(temp_file_created)
  }
  
  
  # --- Step 3: Handle Defaults and Validation ---
  
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
  
  
  # --- Step 4: Compose the Exercise Skeleton ---
  
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
  
  
  # --- Step 5: Insertion Logic ---
  
  if (is.null(file_path)) {
    
    # Interactive Mode: Insert into the active document
    
    # Recalculate context to be safe (though usually unchanged)
    ctx <- rstudioapi::getActiveDocumentContext()
    
    if (length(ctx$selection) > 0 && !is.null(ctx$selection[[1]])) {
      
      # Extract the range from the current selection
      cursor_range <- ctx$selection[[1]]$range
      
      # Insert the text at the cursor position
      rstudioapi::insertText(location = cursor_range, text = new_exercise)
      
    } else {
      stop("Could not determine cursor position in the active document.")
    }
    
  } else {
    
    # Test Mode: Write or append to the provided file path
    cat(new_exercise, file = file_path, append = TRUE)
    invisible(new_exercise)
  }
}