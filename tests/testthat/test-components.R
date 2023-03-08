library(learnr)
library(all.primer.tutorials)
library(tidyverse)

# Goal is to make sure that each tutorial includes the required Information and
# Submission sections. Unfortunately, I could not figure out how to check that a
# multiple-line chunk of code is present in a file.

# So, instead, we will read in the Information and Submission section templates
# with readLines(), which puts each line as a separate item in a text vector.
# Then we can confirm that all those lines are in each tutorial. Note that this
# does not confirm that they are all together and in the correct order! But it
# is good enough.

information_lines <- readLines("test-data/information_check.txt")

for(i in tutorial_paths){
  if(! all(information_lines %in% readLines(i))){
    stop("From test-components.R. Information lines missing from file ", i, "\n")
  }
}

submission_lines <- readLines("test-data/submission_check.txt")

for(i in tutorial_paths){
  if(! all(submission_lines %in% readLines(i))){
    stop("From test-components.R. Submission lines missing from file ", i, "\n")
  }
}

copy_button_lines <- readLines("test-data/copy_button_check.txt")

for(i in tutorial_paths){
  if(! all(copy_button_lines %in% readLines(i))){
    stop("From test-components.R. Copy button lines missing from file ", i, "\n")
  }
}

