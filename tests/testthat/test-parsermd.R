library(parsermd)
library(tutorial.helpers)

# DK: Is this test really necessary? Do we need to be able parsermd the
# tutorials? Doesn't testing that you can knit them cover that.

# This is a test to make sure that all tutorials can be parsed with
# the package parsermd without error.

# We are using parsermd for both the label formatting addin
# and the answer html downloading function.


# tutorial_paths <- tutorial.helpers::return_tutorial_paths()

# for (i in tutorial_paths){
#   cat(paste("Testing tutorial", i, " with parsermd\n"))
#   tryCatch(
#     {
#       parsermd::parse_rmd(i)
#     },
#     error = function(cond){
#       message(paste("test-parsermd.R: Error Parsing Tutorial ", i))
#       message("Returned with Below Error:")
#       message(cond)
#       stop("From test-parsermd.R: Test failed on ", i, "\n")
#     }
#   )
# }




