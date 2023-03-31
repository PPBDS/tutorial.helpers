# Key insight is that we can test tutorial files without installing them as
# tutorials. 

# But why does this fail in testing locally when it works on Github!

# tutorial.helpers/child_documents/copy_button.Rmd) 
# ── Error (/Users/dkane/Desktop/projects/tutorial.helpers/R/knit_tutorials.R:24:7): rendering test-data/tutorial_examples/good-tutorial.Rmd ──
# Error in `if (xfun::is_blank(options$code)) {
#   options$code <- "# empty server context"
# }`: the condition has length > 1
# Backtrace:
#   1. testthat::expect_output(...)
# at tutorial.helpers/R/knit_tutorials.R:24:6
# 10. rmarkdown::render(i, output_file = "tutorial.html")
# 11. knitr::knit(knit_input, knit_output, envir = envir, quiet = quiet)
# 12. knitr:::process_file(text, output)
# 15. knitr:::process_group.block(group)
# 16. knitr:::call_block(x)
# 17. base::lapply(sc_split(params$child), knit_child, options = block$params)
# 18. knitr (local) FUN(X[[i]], ...)
# 19. knitr::knit(..., tangle = opts_knit$get("tangle"), envir = envir)
# 20. knitr:::process_file(text, output)
# 23. knitr:::process_group.block(group)
# 24. knitr:::call_block(x)
# 26. rmarkdown (local) hook(params)

# Also need a test for a vector of tutorials. Add some error testing.

knit_tutorials("test-data/tutorial_examples/good-tutorial.Rmd")

