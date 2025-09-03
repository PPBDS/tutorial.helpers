# Key insight is that we can test tutorial files without installing them as
# tutorials. 

test_good_tutorial <- test_path("fixtures", "tutorial_examples", "good-tutorial.Rmd")

test_no_info_tutorial <- test_path("fixtures", "tutorial_examples", "no-info-tutorial.Rmd")

test_that("knit_tutorials() works on legal tutorials", {
  expect_null(
    knit_tutorials(test_good_tutorial)
  )
  expect_null(
    knit_tutorials(
      c(test_good_tutorial,
        test_no_info_tutorial))
  )
})


test_that("knit_tutorials() works on installed tutorials", {
  
  
  expect_null(
    knit_tutorials(
      system.file("tutorials/getting-started/tutorial.Rmd", 
                  package = "tutorial.helpers")
    )
  )
})

test_that("knit_tutorials() fails on illegal tutorials", {
  expect_error(
    knit_tutorials("fixtures/tutorial_examples/no-exist.Rmd")
    )
  expect_error(
    knit_tutorials(
      c("fixtures/tutorial_examples/good-tutorial.Rmd",
        "fixtures/tutorial_examples/no-exist.Rmd")
      )
    )
})

