library(tidyverse)
library(learnr)
library(stringr)
library(all.primer.tutorials)
library(parsermd)

for(i in tutorial_paths){

  # Note that parsermd, despite being wonderful, can not check for certain
  # errors because it can't parse a file with those errors in the first place.
  # So, we need to check, by hand, for code chunks which do not begin with an
  # "r" followed by a space. Gets the first line (the chunk label) of each code
  # chunk in the file.

  lines <- readLines(i)
  labels <- lines[grepl("^```\\{.*\\}", lines)]

  # Gets the labels that don't have r or =html at the beginning.
  # =html tag is used to render gist in tutorials (use case: rstudio and friends).

  no_r_labels <- labels[!grepl("```\\{(r|=html)[ ,\\}].*", labels)]

  if(length(no_r_labels) > 0){
    stop("From test-code-chunks.R. Missing `r` at beginning of code chunk labels: ",
         toString(no_r_labels), " Found in file ", i, "\n")
  }

  # Gets the labels that don't have a space, a comma, or a }. This is because
  # labels like {r chunk-name}, {r}, and {r, include = FALSE} are all valid and
  # used throughout the tutorial. parsermd also doesn't detect chunks if there's
  # no space so this is easier.

  no_space_labels <- labels[grepl("```\\{r[^\ },]", labels)]
  if(length(no_space_labels) > 0){
    stop("From test-code-chunks.R. Missing space or comma at beginning of code chunk labels: ",
         toString(no_space_labels), " Found in file ", i, "\n")
  }

  # Gets the labels that don't have a } at the end. This is so that everything
  # parses correctly.

  no_end_labels <- labels[!grepl("}$", labels)]
  if(length(no_end_labels) > 0){
    stop("From test-code-chunks.R. Missing `}` at end of code chunk labels: ",
         toString(no_end_labels), " Found in file ", i, "\n")
  }

  # Uses parse_rmd to get the structure of the document

  doc_structure <- parse_rmd(i)

  # Filters out the document so that we only pull the chunks and their labels

  doc_labels <- doc_structure |> rmd_node_label()
  doc_labels <- doc_labels[!is.na(doc_labels)]
  doc_labels <- doc_labels[doc_labels != ""]

  # Checks for duplicates then stops it if there's multiple

  dups <- doc_labels[duplicated(doc_labels)]
  dups <- dups[!is.na(dups)]
  if(length(dups) != 0){
    stop("From test-code-chunks.R. Duplicated code chunk labels ",
         toString(dups), " found in file ", i, "\n")
  }

  # Check for eval = false in hints

  hint_labels <- labels[grepl("hint", labels)]
  for(label in hint_labels){
    if(! str_detect(label, "eval = FALSE")){
      stop("From test-code-chunks.R. `eval = false` missing from code chunk ",
           label, " in file ", i, "\n")
    }
  }

}
