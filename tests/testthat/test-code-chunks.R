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

}

