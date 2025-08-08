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
#' @export
format_tutorial <- function(file_path) {
  # Helper to always format chunk header with clean spaces and exactly one closing }
  format_chunk_header <- function(label, opts) {
    opts <- trimws(opts)
    opts <- sub("\\}+$", "", opts)               # Remove all closing }
    opts <- gsub("^\\s*,\\s*", "", opts)
    opts <- gsub("\\s+", " ", opts)
    opts <- gsub(",\\s+", ", ", opts)
    opts <- trimws(opts)
    if (nchar(opts) > 0) {
      line <- paste0("```{r ", label, ", ", opts, "}")
    } else {
      line <- paste0("```{r ", label, "}")
    }
    # Guarantee one closing }
    line <- sub("\\}+$", "}", line)
    return(line)
  }
  
  lines <- readLines(file_path)
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
    if (grepl("^````\\s*$", trimws(current_line))) {
      verbatim_count <- verbatim_count + 1
      in_verbatim <- verbatim_count %% 2 != 0
      i <- i + 1; next
    }
    if (in_verbatim) { i <- i + 1; next }
    if (grepl("^---$", current_line)) {
      in_yaml <- !in_yaml; i <- i + 1; next
    }
    if (in_yaml) { i <- i + 1; next }
    if (grepl("^#\\s+", current_line)) {
      topic_title <- sub("^#\\s+", "", current_line)
      topic_title <- gsub("\\s+", " ", trimws(topic_title))
      lines[i] <- paste0("# ", topic_title)
      i <- i + 1; next
    }
    if (grepl("^##\\s+", current_line)) {
      section_title <- sub("^##\\s+", "", current_line)
      section_title <- gsub("\\s+", " ", trimws(section_title))
      lines[i] <- paste0("## ", section_title)
      section_name <- tolower(section_title)
      section_name <- gsub("\\s+", "-", section_name)
      section_name <- gsub("[^a-z0-9-]", "", section_name)
      section_name <- gsub("-+", "-", section_name)
      if (grepl("-$", section_name)) section_name <- sub("-$", "", section_name)
      exercise_counter <- 0
      in_section <- TRUE
      i <- i + 1; next
    }
    if (in_section && grepl("^### Exercise", current_line)) {
      exercise_counter <- exercise_counter + 1
      lines[i] <- paste0("### Exercise ", exercise_counter)
      hint_key <- paste0(section_name, "-", exercise_counter)
      hint_counters[[hint_key]] <- 0
      i <- i + 1; next
    }
    i <- i + 1
  }

  # Second pass: Update code chunk labels
  section_name <- ""
  exercise_counter <- 0
  in_yaml <- FALSE
  in_verbatim <- FALSE
  verbatim_count <- 0
  hint_counters <- list()
  force_exercise_chunk <- FALSE
  i <- 1
  while (i <= length(lines)) {
    current_line <- lines[i]
    if (grepl("^````\\s*$", trimws(current_line))) {
      verbatim_count <- verbatim_count + 1
      in_verbatim <- verbatim_count %% 2 != 0
      i <- i + 1; next
    }
    if (in_verbatim) { i <- i + 1; next }
    if (grepl("^---$", current_line)) {
      in_yaml <- !in_yaml; i <- i + 1; next
    }
    if (in_yaml) { i <- i + 1; next }
    if (grepl("^#\\s+", current_line)) { i <- i + 1; next }
    if (grepl("^##\\s+", current_line)) {
      section_title <- sub("^##\\s+", "", current_line)
      section_title <- gsub("\\s+", " ", trimws(section_title))
      section_name <- tolower(section_title)
      section_name <- gsub("\\s+", "-", section_name)
      section_name <- gsub("[^a-z0-9-]", "", section_name)
      if (grepl("-$", section_name)) section_name <- sub("-$", "", section_name)
      exercise_counter <- 0
      i <- i + 1; next
    }
    if (grepl("^### Exercise", current_line)) {
      exercise_counter <- exercise_counter + 1
      hint_key <- paste0(section_name, "-", exercise_counter)
      hint_counters[[hint_key]] <- 0
      force_exercise_chunk <- TRUE
      i <- i + 1; next
    }

    # ---- Code chunk logic starts here ----
    if (grepl("^```\\{r", current_line)) {
      # (1) SKIP completely unlabeled chunks {r}
      if (grepl("^```\\{r\\s*\\}$", current_line) || grepl("^```\\{r\\s*$", current_line)) {
        i <- i + 1; next
      }
      # (2) SKIP any chunk with file = ... (anywhere in the header)
      header_only <- gsub("\\}.*$", "", current_line)
      if (grepl("file\\s*=", header_only)) {
        i <- i + 1; next
      }
      # (3) SKIP "setup" chunks
      if (grepl("^```\\{r\\s+setup", current_line)) {
        i <- i + 1; next
      }

      # Forced relabel after Exercise header
      if (force_exercise_chunk) {
        new_base_label <- paste0(section_name, "-", exercise_counter)
        chunk_options <- sub("^```\\{r\\s*[^,}]*\\s*(,.*)?\\s*\\}?\\s*$", "\\1", current_line)
        lines[i] <- format_chunk_header(new_base_label, chunk_options)
        force_exercise_chunk <- FALSE
        i <- i + 1; next
      }

      # -test and -hint labels (fix only label, preserve all options)
      if (grepl("-test(\\}|,|$)", current_line)) {
        new_base_label <- paste0(section_name, "-", exercise_counter, "-test")
        chunk_options <- sub("^```\\{r\\s*[^,}]*\\s*(,.*)?\\s*\\}?\\s*$", "\\1", current_line)
        lines[i] <- format_chunk_header(new_base_label, chunk_options)
        i <- i + 1; next
      }
      if (grepl("-hint-\\d+(\\}|,|$)", current_line)) {
        hint_key <- paste0(section_name, "-", exercise_counter)
        hint_counters[[hint_key]] <- hint_counters[[hint_key]] + 1
        hint_number <- hint_counters[[hint_key]]
        new_base_label <- paste0(section_name, "-", exercise_counter, "-hint-", hint_number)
        chunk_options <- sub("^```\\{r\\s*[^,}]*\\s*(,.*)?\\s*\\}?\\s*$", "\\1", current_line)
        lines[i] <- format_chunk_header(new_base_label, chunk_options)
        i <- i + 1; next
      }

      # (4) Skip if not in a section or exercise
      if (section_name == "" || exercise_counter == 0) {
        i <- i + 1; next
      }

      # (5) If already has the correct label, skip
      current_label_pattern <- paste0("^```\\{r\\s+", section_name, "-", exercise_counter, "(,|\\})")
      if (grepl(current_label_pattern, current_line)) {
        i <- i + 1; next
      }

      # --- Decide label type ---
      new_base_label <- paste0(section_name, "-", exercise_counter)
      # Special suffixes
      if (grepl("include\\s*=\\s*FALSE", current_line)) {
        new_base_label <- paste0(new_base_label, "-test")
      } else if (grepl("eval\\s*=\\s*FALSE", current_line)) {
        hint_key <- paste0(section_name, "-", exercise_counter)
        hint_counters[[hint_key]] <- hint_counters[[hint_key]] + 1
        hint_number <- hint_counters[[hint_key]]
        new_base_label <- paste0(new_base_label, "-hint-", hint_number)
      } else if (grepl("exercise\\s*=\\s*TRUE", current_line)) {
        # keep base label
      } else {
        # skip chunks without key options
        i <- i + 1; next
      }
      # Actually rebuild chunk header
      chunk_options <- sub("^```\\{r\\s*[^,}]*\\s*(,.*)?\\s*\\}?\\s*$", "\\1", current_line)
      lines[i] <- format_chunk_header(new_base_label, chunk_options)
      i <- i + 1; next
    }
    i <- i + 1
  }
  return(paste(lines, collapse = "\n"))
}




