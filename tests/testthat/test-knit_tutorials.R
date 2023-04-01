# Key insight is that we can test tutorial files without installing them as
# tutorials. 

# But why does this fail in testing locally when it works on Github!

# Single tutorials

knit_tutorials("test-data/tutorial_examples/good-tutorial.Rmd")

expect_error(knit_tutorials(
  "test-data/tutorial_examples/no-exist.Rmd")
  )

# Vector of tutorials

knit_tutorials(
  c("test-data/tutorial_examples/good-tutorial.Rmd",
    "test-data/tutorial_examples/no-info-tutorial.Rmd")
)

expect_error(
  knit_tutorials(
    c("test-data/tutorial_examples/good-tutorial.Rmd",
      "test-data/tutorial_examples/no-exist.Rmd")
  )
)