# make_exercise.R is still rough because it behaves poorly if you execute it in
# a document which is not set up like a tutorial, especially one which lacks a
# Section header.  of a tutorial file with a section header.

# Alas, when I try these now, I get an error about
#
# Error: RStudio not running
#
# The cause, I think, the call to rstudioapi::getActiveDocumentContext(). There
# must be a way around this . . .

# tutorial.helpers::make_exercise(type = "code", 
#                                 file_path = "fixtures/tutorial_examples/code-chunk-name-test-tutorial-1.Rmd")
# 
# tutorial.helpers::make_exercise(type = "no-answer",
#                                 file_path = "fixtures/tutorial_examples/code-chunk-name-test-tutorial-1.Rmd")
# tutorial.helpers::make_exercise(type = "yes-answer")

# We can, however, check to ensure that they error when given bad input.

expect_error(tutorial.helpers::make_exercise(type = "bad-input"))
