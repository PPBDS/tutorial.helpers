library(parsermd)

tutorial_paths <- tutorial.helpers::return_tutorial_paths("learnr")

# One problem is that the tutorials in the learnr package have various problems.
# So, this "test" would produce warnings/errors which are not our fault! We
# could restrict our tests to just tutorials which we know are well-formatted.
# Or we could try to clean up learnr itself. I have submitted one PR but, for
# now, we just comment out the last set of checks which rely on parse_rmd().

for(i in tutorial_paths){

  # With regard to this first comment, maybe we should just fail from the start
  # if parse_rmd fail.

  # Note that parsermd, despite being wonderful, can not check for certain
  # errors because it can't parse a file with those errors in the first place.
  # So, we need to check, by hand, for code chunks which do not begin with an
  # "r" followed by a space. Gets the first line (the chunk label) of each code
  # chunk in the file.

  # The ex-data-mutate.Rmd has a missing last EOL. I submitted a PR to learnr.
  # Who knows how long that will take to fix. In the meantime, I set warn =
  # FALSE.

  lines <- readLines(i, warn = FALSE)
  labels <- lines[grepl("^```\\{.*\\}", lines)]

  # Gets the labels that don't have r (or other allowed languages) at the
  # beginning. By the way, the =html tag is used to render a gist in some
  # tutorials.

  no_r_labels <- labels[!grepl("```\\{(r|=html|bash|python|sql)[ ,\\}].*", labels)]

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
  # parses correctly. Problem is that some tutorials still make use of the `r
  # ''`, so we need to check for both } and that at the end.

  no_end_labels <- labels[!grepl("}|}`r ''`", labels)]
  if(length(no_end_labels) > 0){
    stop("From test-code-chunks.R. Missing `}` at end of code chunk labels: ",
         toString(no_end_labels), " Found in file ", i, "\n")
  }

  # DK: There is a problem with this file:
  # https://github.com/rstudio/learnr/blob/main/inst/tutorials/ex-data-filter/ex-data-filter.Rmd

  # parsermd::parse_rmd() on that file produces an error:

  # Error: Failed to parse line 242
  # ```{r filterex1, exercise = TRUE}
  # ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  # Not sure why. But that error causes me to comment out the rest of the checks
  # in this script. Might revisit this later.

  # Uses parse_rmd to get the structure of the document

  # doc_structure <- parsermd::parse_rmd(i)

  # Filters out the document so that we only pull the chunks and their labels

  # doc_labels <- doc_structure |> rmd_node_label()
  # doc_labels <- doc_labels[!is.na(doc_labels)]
  # doc_labels <- doc_labels[doc_labels != ""]

  # Checks for duplicates then stops it if there's multiple

  # dups <- doc_labels[duplicated(doc_labels)]
  # dups <- dups[!is.na(dups)]
  # if(length(dups) != 0){
  #   stop("From test-code-chunks.R. Duplicated code chunk labels ",
  #        toString(dups), " found in file ", i, "\n")
  # }

  # Check for eval = false in hints

  # hint_labels <- labels[grepl("hint", labels)]
  # for(label in hint_labels){
  #   if(! str_detect(label, "eval = FALSE")){
  #     stop("From test-code-chunks.R. `eval = false` missing from code chunk ",
  #          label, " in file ", i, "\n")
  #   }
  # }

}

