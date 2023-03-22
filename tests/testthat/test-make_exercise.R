# make_exercise.R is still rough because it behaves poorly outside of a tutorial
# file with a section header. So, for now, we make a section header for testing
# purposes. Also, it is not clear how we can test these functions since they
# seem to just edit this file on the fly.  So, for now, we just test to see that
# they run, and that they error when they should.

# Alas, when I try these now, I get an error about Error: RStudio not running,
# caused by, I think, the call to rstudioapi::getActiveDocumentContext(). There
# must be a way around this . . .

## My section header
###



# tutorial.helpers::make_exercise(type = "code")


# tutorial.helpers::make_exercise(type = "no-answer")


# tutorial.helpers::make_exercise(type = "yes-answer")


expect_error(tutorial.helpers::make_exercise(type = "bad-input"))
