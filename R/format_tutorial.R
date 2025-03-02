#' Format RMarkdown tutorial code chunks
#'
#' This function processes an R Markdown tutorial file to standardize code chunk labels
#' based on section names and exercise numbers. It also renumbers exercises sequentially
#' within each section.
#'
#' @param file_path Character string. Path to the R Markdown file to process.
#'
#' @details
#' The function applies the following formatting rules:
#' \itemize{
#'   \item Exercises are renumbered sequentially within each section
#'   \item Code chunks are relabeled according to the pattern: section-name-exercise-number
#'   \item Chunks with `eval = FALSE` receive a `-hint-N` suffix
#'   \item Chunks with `include = FALSE` receive a `-test` suffix
#'   \item Chunks with label "setup" are not modified
#'   \item Chunks with the "file" option are not modified
#'   \item Unlabeled chunks without key options are not modified
#'   \item All formatted chunks preserve their original options
#'   \item Content between quadruple backticks (```` ````) is preserved untouched
#' }
#'
#' @return Character string containing the formatted R Markdown content.
#'
#' @examples
#' \dontrun{
#' # Format a tutorial file
#' new_content <- format_tutorial("path/to/tutorial.Rmd")
#' 
#' # Write the formatted content to a file
#' writeLines(new_content, "path/to/formatted_tutorial.Rmd")
#' }
#'
#' @export
format_tutorial <- function(file_path) {
  # Read the Rmd file
  lines <- readLines(file_path)
  
  # Initialize variables to track state
  section_name <- ""
  exercise_counter <- 0
  in_yaml <- FALSE
  in_verbatim <- FALSE  # New flag to track if we're inside quadruple backticks
  in_section <- FALSE
  
  # Add a variable to track hint counters per exercise
  hint_counters <- list()
  
  # First pass: Identify and renumber exercises
  i <- 1
  while (i <= length(lines)) {
    current_line <- lines[i]
    
    # Check for quadruple backticks - toggles verbatim mode
    if (grepl("^````$", current_line)) {
      in_verbatim <- !in_verbatim
      i <- i + 1
      next
    }
    
    # Skip processing while in verbatim mode
    if (in_verbatim) {
      i <- i + 1
      next
    }
    
    # Track YAML section
    if (grepl("^---$", current_line)) {
      in_yaml <- !in_yaml
      i <- i + 1
      next
    }
    
    # Skip processing within YAML
    if (in_yaml) {
      i <- i + 1
      next
    }
    
    # Detect sections (## headers)
    if (grepl("^## ", current_line)) {
      section_title <- sub("^## ", "", current_line)
      section_name <- tolower(section_title)
      section_name <- gsub(" ", "-", section_name)
      section_name <- gsub("[^a-z0-9-]", "", section_name)
      
      # Check if section_name already ends with a hyphen and remove it
      if (grepl("-$", section_name)) {
        section_name <- sub("-$", "", section_name)
      }
      
      exercise_counter <- 0
      in_section <- TRUE
      i <- i + 1
      next
    }
    
    # Detect and renumber exercise sections
    if (in_section && grepl("^### Exercise", current_line)) {
      exercise_counter <- exercise_counter + 1
      # Update the exercise number in the header
      lines[i] <- paste0("### Exercise ", exercise_counter)
      # Initialize hint counter for this exercise
      hint_key <- paste0(section_name, "-", exercise_counter)
      hint_counters[[hint_key]] <- 0
      i <- i + 1
      next
    }
    
    i <- i + 1
  }
  
  # Reset tracking variables for second pass
  section_name <- ""
  exercise_counter <- 0
  in_yaml <- FALSE
  in_verbatim <- FALSE
  hint_counters <- list()
  
  # Second pass: Update code chunk labels based on corrected exercise numbers
  for (i in seq_along(lines)) {
    current_line <- lines[i]
    
    # Check for quadruple backticks - toggles verbatim mode
    if (grepl("^````$", current_line)) {
      in_verbatim <- !in_verbatim
      next
    }
    
    # Skip processing while in verbatim mode
    if (in_verbatim) {
      next
    }
    
    # Track YAML section
    if (grepl("^---$", current_line)) {
      in_yaml <- !in_yaml
      next
    }
    
    # Skip processing within YAML
    if (in_yaml) {
      next
    }
    
    # Detect sections (## headers)
    if (grepl("^## ", current_line)) {
      section_title <- sub("^## ", "", current_line)
      section_name <- tolower(section_title)
      section_name <- gsub(" ", "-", section_name)
      section_name <- gsub("[^a-z0-9-]", "", section_name)
      
      # Check if section_name already ends with a hyphen and remove it
      if (grepl("-$", section_name)) {
        section_name <- sub("-$", "", section_name)
      }
      
      exercise_counter <- 0
      next
    }
    
    # Detect exercise sections and increment counter
    if (grepl("^### Exercise", current_line)) {
      exercise_counter <- exercise_counter + 1
      # Initialize hint counter for this exercise
      hint_key <- paste0(section_name, "-", exercise_counter)
      hint_counters[[hint_key]] <- 0
      next
    }
    
    # Process code chunks - match the start of an R code chunk 
    if (grepl("^```\\{r", current_line)) {
      # Skip if we're not in a section or exercise
      if (section_name == "" || exercise_counter == 0) {
        next
      }
      
      # LOGIC FOR UPDATING CODE CHUNKS:
      # 1. Label "setup" = no change
      # 2. Chunks with "file" option = no change
      # 3. No label without key options = no change
      # 4. Label with other options but without key options = no change
      # 5. Label without any options = change
      # 6. Any chunk with "exercise", "eval", or "include" = change (even if no label)
      
      # Skip "setup" chunks - they should not be changed
      if (grepl("^```\\{r\\s+setup", current_line)) {
        next
      }
      
      # Skip chunks with "file" option - they should not be changed
      if (grepl("file\\s*=", current_line)) {
        next
      }
      
      # First check if the chunk already has the correct label
      current_label_pattern <- paste0("^```\\{r\\s+", section_name, "-", exercise_counter, "(,|\\})")
      is_already_correct <- grepl(current_label_pattern, current_line)
      
      # Skip if the label is already correctly formatted
      if (is_already_correct) {
        next
      }
      
      # Create the new base label
      new_base_label <- paste0(section_name, "-", exercise_counter)
      
      # Handle the special case of unlabeled chunks with include=FALSE, eval=FALSE, or exercise=TRUE
      if (grepl("^```\\{r\\s+include\\s*=\\s*FALSE", current_line) || grepl("^```\\{r,\\s*include\\s*=\\s*FALSE", current_line)) {
        # Direct match for unlabeled chunk with include=FALSE
        lines[i] <- gsub("^```\\{r\\s*(.*)$", paste0("```{r ", new_base_label, "-test, \\1"), current_line)
        next
      }
      
      if (grepl("^```\\{r\\s+eval\\s*=\\s*FALSE", current_line) || grepl("^```\\{r,\\s*eval\\s*=\\s*FALSE", current_line)) {
        # Direct match for unlabeled chunk with eval=FALSE
        hint_key <- paste0(section_name, "-", exercise_counter)
        hint_counters[[hint_key]] <- hint_counters[[hint_key]] + 1
        hint_number <- hint_counters[[hint_key]]
        
        lines[i] <- gsub("^```\\{r\\s*(.*)$", paste0("```{r ", new_base_label, "-hint-", hint_number, ", \\1"), current_line)
        next
      }
      
      if (grepl("^```\\{r\\s+exercise\\s*=\\s*TRUE", current_line) || grepl("^```\\{r,\\s*exercise\\s*=\\s*TRUE", current_line)) {
        # Direct match for unlabeled chunk with exercise=TRUE
        lines[i] <- gsub("^```\\{r\\s*(.*)$", paste0("```{r ", new_base_label, ", \\1"), current_line)
        next
      }
      
      # Check if chunk has a label
      has_label <- grepl("^```\\{r\\s+[^,\\}]", current_line)
      
      # Check if chunk has one of the key options
      has_key_option <- grepl("exercise\\s*=", current_line) || 
                        grepl("eval\\s*=", current_line) || 
                        grepl("include\\s*=", current_line)
      
      # Check if the chunk has any options (indicated by a comma)
      has_options <- grepl(",", current_line)
      
      # Determine if we should update this chunk
      should_update <- FALSE
      
      # Logic for determining if a chunk should be updated
      if (!has_label) {
        # No label - only update if it has key options
        should_update <- has_key_option
      } else {
        if (has_options) {
          # Label with options - only update if it has a key option
          should_update <- has_key_option
        } else {
          # Label without options - always update
          should_update <- TRUE
        }
      }
      
      # Update the chunk if needed
      if (should_update) {
        # Handle specific cases based on options
        if (grepl("eval\\s*=\\s*FALSE", current_line)) {
          # Hint chunks with eval=FALSE
          hint_key <- paste0(section_name, "-", exercise_counter)
          hint_counters[[hint_key]] <- hint_counters[[hint_key]] + 1
          hint_number <- hint_counters[[hint_key]]
          
          if (has_label && has_options) {
            # Labeled chunk with options
            options <- sub("^```\\{r\\s+[^,]+,\\s*(.+)\\}$", "\\1", current_line)
            lines[i] <- paste0("```{r ", new_base_label, "-hint-", hint_number, ", ", options, "}")
          } else if (has_label && !has_options) {
            # Labeled chunk without other options
            lines[i] <- paste0("```{r ", new_base_label, "-hint-", hint_number, "}")
          } else {
            # Unlabeled chunk with eval=FALSE
            options <- sub("^```\\{r\\s*,?\\s*(.+)\\}$", "\\1", current_line)
            lines[i] <- paste0("```{r ", new_base_label, "-hint-", hint_number, ", ", options, "}")
          }
        }
        else if (grepl("include\\s*=\\s*FALSE", current_line)) {
          # Chunks with include=FALSE get -test suffix
          if (has_label && has_options) {
            options <- sub("^```\\{r\\s+[^,]+,\\s*(.+)\\}$", "\\1", current_line)
            lines[i] <- paste0("```{r ", new_base_label, "-test, ", options, "}")
          } else if (has_label && !has_options) {
            lines[i] <- paste0("```{r ", new_base_label, "-test}")
          } else {
            # Unlabeled chunk with include=FALSE
            options <- sub("^```\\{r\\s*,?\\s*(.+)\\}$", "\\1", current_line)
            lines[i] <- paste0("```{r ", new_base_label, "-test, ", options, "}")
          }
        }
        else if (grepl("-test", current_line)) {
          # Chunks with -test in their label
          if (has_options) {
            options <- sub("^```\\{r\\s+[^,]+,\\s*(.+)\\}$", "\\1", current_line)
            lines[i] <- paste0("```{r ", new_base_label, "-test, ", options, "}")
          } else {
            lines[i] <- paste0("```{r ", new_base_label, "-test}")
          }
        }
        else if (grepl("exercise\\s*=\\s*TRUE", current_line)) {
          # Exercise chunks
          if (has_label && has_options) {
            options <- sub("^```\\{r\\s+[^,]+,\\s*(.+)\\}$", "\\1", current_line)
            lines[i] <- paste0("```{r ", new_base_label, ", ", options, "}")
          } else if (has_label && !has_options) {
            lines[i] <- paste0("```{r ", new_base_label, "}")
          } else {
            # Unlabeled chunk with exercise=TRUE
            options <- sub("^```\\{r\\s*,?\\s*(.+)\\}$", "\\1", current_line)
            lines[i] <- paste0("```{r ", new_base_label, ", ", options, "}")
          }
        }
        else if (has_options && has_key_option) {
          # Other chunks with key options
          if (has_label) {
            options <- sub("^```\\{r\\s+[^,]+,\\s*(.+)\\}$", "\\1", current_line)
            lines[i] <- paste0("```{r ", new_base_label, ", ", options, "}")
          } else {
            options <- sub("^```\\{r\\s*,?\\s*(.+)\\}$", "\\1", current_line)
            lines[i] <- paste0("```{r ", new_base_label, ", ", options, "}")
          }
        }
        else {
          # Label without options
          lines[i] <- paste0("```{r ", new_base_label, "}")
        }
      }
    }
  }
  
  # Return formatted content with exactly the same line endings
  return(paste(lines, collapse = "\n"))
}
