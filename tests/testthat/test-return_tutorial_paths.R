# For now, there is only one tutorial in this package. But one is good enough
# for testing. 


test_that("Can find path for tutorial.helpers tutorial", {
  paths <- return_tutorial_paths(package = "tutorial.helpers")
  
  expect_true(
    any(grepl("tutorial.Rmd", paths))
  )
})


# We can't assume that the tutorials in learnr won't change since we don't
# control that package. The best approach would be to add the (useful!)
# return_tutorial_paths() function to learnr itself.

test_that("Can find path for learnr tutorials", {
  
  paths <- return_tutorial_paths(package = "learnr")
  
  expect_true(
    any(grepl("ex-data-basics.Rmd", paths)),
    any(grepl("quiz_question.Rmd", paths))
  )
})

