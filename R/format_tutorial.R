#' Format RMarkdown tutorial code chunks
#'
#' This function processes an R Markdown tutorial file to standardize code chunk labels
#' based on section names and exercise numbers. It also renumbers exercises sequentially
#' within each section and fixes spacing in topic headers.
#'
#' @param file_path Character string. Path to the R Markdown file to process.
#'
#' @details
#' The function applies the following formatting rules:
#' \itemize{
#'   \item Topic headers (# headers) have their spacing standardized
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
  in_verbatim <- FALSE
  in_section <- FALSE
  verbatim_count <- 0
  hint_counters <- list()
  force_exercise_chunk <- FALSE
  
  # First pass: Fix topic header spacing and identify/renumber exercises
  i <- 1
  while (i <= length(lines)) {
    current_line <- lines[i]
    
    # Check for quadruple backticks - toggles verbatim mode
    if (grepl("^````\\s*$", trimws(current_line))) {
      verbatim_count <- verbatim_count + 1
      in_verbatim <- verbatim_count %% 2 != 0
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
    
    # Fix topic headers (# headers) - standardize spacing
    if (grepl("^#\\s+", current_line)) {
      topic_title <- sub("^#\\s+", "", current_line)
      topic_title <- gsub("\\s+", " ", trimws(topic_title))
      lines[i] <- paste0("# ", topic_title)
      i <- i + 1
      next
    }
    
    # Detect sections (## headers)
    if (grepl("^##\\s+", current_line)) {
      section_title <- sub("^##\\s+", "", current_line)
      section_title <- gsub("\\s+", " ", trimws(section_title))
      lines[i] <- paste0("## ", section_title)
      
      section_name <- tolower(section_title)
      section_name <- gsub("\\s+", "-", section_name)
      section_name <- gsub("[^a-z0-9-]", "", section_name)
      section_name <- gsub("-+", "-", section_name)
      
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
      lines[i] <- paste0("### Exercise ", exercise_counter)
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
  verbatim_count <- 0
  hint_counters <- list()
  force_exercise_chunk <- FALSE
  
  # Second pass: Update code chunk labels
  i <- 1
  while (i <= length(lines)) {
    current_line <- lines[i]
    
    # Check for quadruple backticks
    if (grepl("^````\\s*$", trimws(current_line))) {
      verbatim_count <- verbatim_count + 1
      in_verbatim <- verbatim_count %% 2 != 0
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
    
    # Skip topic headers in second pass
    if (grepl("^#\\s+", current_line)) {
      i <- i + 1
      next
    }
    
    # Detect sections (## headers)
    if (grepl("^##\\s+", current_line)) {
      section_title <- sub("^##\\s+", "", current_line)
      section_title <- gsub("\\s+", " ", trimws(section_title))
      
      section_name <- tolower(section_title)
      section_name <- gsub("\\s+", "-", section_name)
      section_name <- gsub("[^a-z0-9-]", "", section_name)
      
      if (grepl("-$", section_name)) {
        section_name <- sub("-$", "", section_name)
      }
      
      exercise_counter <- 0
      i <- i + 1
      next
    }
    
    # Detect exercise sections and increment counter
    if (grepl("^### Exercise", current_line)) {
      exercise_counter <- exercise_counter + 1
      hint_key <- paste0(section_name, "-", exercise_counter)
      hint_counters[[hint_key]] <- 0
      force_exercise_chunk <- TRUE
      i <- i + 1
      next
    }
    
    # Process code chunks
    if (grepl("^```\\{r", current_line)) {
      # Handle forced relabeling after Exercise header
      if (force_exercise_chunk) {
        new_base_label <- paste0(section_name, "-", exercise_counter)
        chunk_options <- sub("^```\\{r\\s*([^,}]*)\\s*(,.*|\\}.*)?$", "\\2", current_line)
        if (chunk_options != "" && !grepl("^,", chunk_options)) {
          chunk_options <- paste0(",", chunk_options)
        }
        # Always close the chunk properly
        lines[i] <- paste0("```{r ", new_base_label, chunk_options, "}")
        force_exercise_chunk <- FALSE
        i <- i + 1
        next
      }
      
      # Extract label or first arg
      chunk_start <- sub("^```\\{r\\s*", "", current_line)
      first_arg <- sub(",.*|}.*", "", chunk_start)
      
      # If chunk is completely unlabeled (```{r}), do not relabel
      if (nchar(trimws(first_arg)) == 0) {
        i <- i + 1
        next
      }
      
      # If first arg is file = ..., do not relabel
      if (grepl("^file\\s*=", trimws(first_arg))) {
        i <- i + 1
        next
      }
      
      # Handle broken -test and -hint-* chunk labels
      chunk_line <- current_line
      label_match <- regexpr("^```\\{r\\s+([^,}]*)", chunk_line, perl = TRUE)
      chunk_label <- ifelse(label_match > 0, trimws(regmatches(chunk_line, label_match)[[1]]), "")
      
      if (chunk_label != "") {
        new_base_label <- paste0(section_name, "-", exercise_counter)
        new_base_label <- gsub("-+", "-", new_base_label)
        
        # Fix -test chunks
        if (grepl("-test$", chunk_label)) {
          lines[i] <- sub(
            "^```\\{r\\s+([^,}]*)",
            paste0("```{r ", new_base_label, "-test"),
            lines[i]
          )
          i <- i + 1
          next
        }
        # Fix -hint-* chunks
        if (grepl("-hint-\\d+$", chunk_label)) {
          hint_key <- paste0(section_name, "-", exercise_counter)
          hint_counters[[hint_key]] <- hint_counters[[hint_key]] + 1
          hint_number <- hint_counters[[hint_key]]
          lines[i] <- sub(
            "^```\\{r\\s+([^,}]*)",
            paste0("```{r ", new_base_label, "-hint-", hint_number),
            lines[i]
          )
          i <- i + 1
          next
        }
      }
      
      # Skip if we're not in a section or exercise
      if (section_name == "" || exercise_counter == 0) {
        i <- i + 1
        next
      }
      
      # Skip "setup" chunks
      if (grepl("^```\\{r\\s+setup", current_line)) {
        i <- i + 1
        next
      }
      
      # First check if the chunk already has the correct label
      current_label_pattern <- paste0("^```\\{r\\s+", section_name, "-", exercise_counter, "(,|\\})")
      is_already_correct <- grepl(current_label_pattern, current_line)
      
      if (is_already_correct) {
        i <- i + 1
        next
      }
      
      # Create the new base label
      new_base_label <- paste0(section_name, "-", exercise_counter)
      
      # Handle special cases
      if (grepl("^```\\{r\\s+include\\s*=\\s*FALSE", current_line) || grepl("^```\\{r,\\s*include\\s*=\\s*FALSE", current_line)) {
        lines[i] <- gsub("^```\\{r\\s*(.*)$", paste0("```{r ", new_base_label, "-test, \\1"), current_line)
        i <- i + 1
        next
      }
      
      if (grepl("^```\\{r\\s+eval\\s*=\\s*FALSE", current_line) || grepl("^```\\{r,\\s*eval\\s*=\\s*FALSE", current_line)) {
        hint_key <- paste0(section_name, "-", exercise_counter)
        hint_counters[[hint_key]] <- hint_counters[[hint_key]] + 1
        hint_number <- hint_counters[[hint_key]]
        
        lines[i] <- gsub("^```\\{r\\s*(.*)$", paste0("```{r ", new_base_label, "-hint-", hint_number, ", \\1"), current_line)
        i <- i + 1
        next
      }
      
      if (grepl("^```\\{r\\s+exercise\\s*=\\s*TRUE", current_line) || grepl("^```\\{r,\\s*exercise\\s*=\\s*TRUE", current_line) || 
          grepl("^```\\{r\\s+[^,]+,\\s*exercise\\s*=\\s*TRUE", current_line)) {
        lines[i] <- gsub("^```\\{r(?:\\s+[^,]+)?\\s*,?\\s*(.*)$", paste0("```{r ", new_base_label, ", \\1"), current_line)
        i <- i + 1
        next
      }
      
      # Check if chunk has a label
      has_label <- grepl("^```\\{r\\s+[^,\\}]", current_line)
      
      # Check if chunk has one of the key options
      has_key_option <- grepl("exercise\\s*=", current_line) || 
                        grepl("eval\\s*=", current_line) || 
                        grepl("include\\s*=", current_line)
      
      # Check if the chunk has any options
      has_options <- grepl(",", current_line)
      
      # Determine if we should update this chunk
      should_update <- FALSE
      
      if (!has_label) {
        should_update <- has_key_option
      } else {
        if (has_options) {
          should_update <- has_key_option
        } else {
          should_update <- TRUE
        }
      }
      
      # Update the chunk if needed
      if (should_update) {
        if (grepl("eval\\s*=\\s*FALSE", current_line)) {
          hint_key <- paste0(section_name, "-", exercise_counter)
          hint_counters[[hint_key]] <- hint_counters[[hint_key]] + 1
          hint_number <- hint_counters[[hint_key]]
          
          if (has_label && has_options) {
            options <- sub("^```\\{r\\s+[^,]+,\\s*(.+)\\}$", "\\1", current_line)
            lines[i] <- paste0("```{r ", new_base_label, "-hint-", hint_number, ", ", options, "}")
          } else if (has_label && !has_options) {
            lines[i] <- paste0("```{r ", new_base_label, "-hint-", hint_number, "}")
          } else {
            options <- sub("^```\\{r\\s*,?\\s*(.+)\\}$", "\\1", current_line)
            lines[i] <- paste0("```{r ", new_base_label, "-hint-", hint_number, ", ", options, "}")
          }
        }
        else if (grepl("include\\s*=\\s*FALSE", current_line)) {
          if (has_label && has_options) {
            options <- sub("^```\\{r\\s+[^,]+,\\s*(.+)\\}$", "\\1", current_line)
            lines[i] <- paste0("```{r ", new_base_label, "-test, ", options, "}")
          } else if (has_label && !has_options) {
            lines[i] <- paste0("```{r ", new_base_label, "-test}")
          } else {
            options <- sub("^```\\{r\\s*,?\\s*(.+)\\}$", "\\1", current_line)
            lines[i] <- paste0("```{r ", new_base_label, "-test, ", options, "}")
          }
        }
        else if (grepl("exercise\\s*=\\s*TRUE", current_line)) {
          if (has_label && has_options) {
            options <- sub("^```\\{r\\s+[^,]+,\\s*(.+)\\}$", "\\1", current_line)
            lines[i] <- paste0("```{r ", new_base_label, ", ", options, "}")
          } else if (has_label && !has_options) {
            lines[i] <- paste0("```{r ", new_base_label, "}")
          } else {
            options <- sub("^```\\{r\\s*,?\\s*(.+)\\}$", "\\1", current_line)
            lines[i] <- paste0("```{r ", new_base_label, ", ", options, "}")
          }
        }
        else if (has_options && has_key_option) {
          if (has_label) {
            options <- sub("^```\\{r\\s+[^,]+,\\s*(.+)\\}$", "\\1", current_line)
            lines[i] <- paste0("```{r ", new_base_label, ", ", options, "}")
          } else {
            options <- sub("^```\\{r\\s*,?\\s*(.+)\\}$", "\\1", current_line)
            lines[i] <- paste0("```{r ", new_base_label, ", ", options, "}")
          }
        }
        else {
          lines[i] <- paste0("```{r ", new_base_label, "}")
        }
      }
      
      i <- i + 1
      next
    }
    
    i <- i + 1
  }
  
  # Return formatted content with exactly the same line endings
  return(paste(lines, collapse = "\n"))
}


