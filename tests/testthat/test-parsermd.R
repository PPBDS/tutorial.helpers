library(parsermd)
library(all.primer.tutorials)

# This is a test to make sure that all tutorials can be parsed with
# the package parsermd without error.

# We are using parsermd for both the label formatting addin
# and the answer html downloading function.

# However, the parsermd package currently throws errors when we use
# tricks like `r ''` to show code chunks.
# Previously, we would show code chunks like such:
# ````markdown
# ```{r}`r ''`
# 1 + 1
# ```
# ````

# Now we changed to using pictures with knitr to show the code chunks.
# A tutorial that previously used it was 011-rstudio-and-friends,
# now it is changed to using knitr::include_graphics()
# from the data directory.

for (i in tutorial_paths){
  cat(paste("Testing tutorial", i, " with parsermd\n"))
  tryCatch(
    {
      parsermd::parse_rmd(i)
    },
    error = function(cond){
      message(paste("test-parsermd.R: Error Parsing Tutorial ", i))
      message("Returned with Below Error:")
      message(cond)
      stop("From test-parsermd.R: Test failed on ", i, "\n")
    }
  )
}




