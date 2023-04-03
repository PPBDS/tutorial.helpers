# For now, there is only one tutorial in this package. But one is good enough
# for testing. 

x <- return_tutorial_paths(package = testing_package())

stopifnot(any(grepl("tutorial.Rmd", x)))

# We can't assume that the tutorials in learnr won't change since we don't
# control that package. The best approach would be to add the (useful!)
# return_tutorial_paths() function to learnr itself.

x <- return_tutorial_paths(package = "learnr")

# In the meantime, we will just test that two specific learnr tutorials are
# still present.

stopifnot(any(grepl("ex-data-basics.Rmd", x)))
stopifnot(any(grepl("quiz_question.Rmd", x)))
