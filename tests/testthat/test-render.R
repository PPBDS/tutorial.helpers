library(all.primer.tutorials)
library(tidyverse)

# Our definition of "test" for a tutorial file is to run render() and hope there
# is no error. There is no check to see if "tutorial.html" looks OK, just that
# that string is returned.

# Might we do more here? For example, what we really want to confirm is that,
# when a student presses the "Start Tutorial" button, things will work. I am not
# sure if render() is the same thing. But, the good news is that this test seems
# much more robust than that. In other words, it catches things that do not
# cause (immediate) failures with Start Tutorial.

# See the details.Rmd file for some thoughts on what this is doing and how
# we might improve it.

for(i in tutorial_paths){
  cat(paste("Testing tutorial:", i, "\n"))
  test_that(paste("rendering", i), {
    expect_output(rmarkdown::render(i, output_file = "tutorial.html"),
                  "tutorial.html")
  })
}

# There are two problems with this list of files. First, it is long! There are a
# lot of tutorials and they take a while to run. There is not a lot to be done
# about that. The second problem is that there is no way to customize it.
# Sometimes, we would just like to test one tutorial, especially while we are
# working on it. Other times, we want to test all the tutorials but one.

# This test is not complete because it does not simulate the scenario in which a
# user runs a tutorial directly. For example, if you forget to include
# library(all.primer.tutorials) in the code chunk for a tutorial, it will fail for a
# user because it won't find submission_ui. But such a flawed tutorial.Rmd will
# pass this test because we load library(primary.tutorials) before we start the
# test above. Maybe this is just an edge case we can ignore.
