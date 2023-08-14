# Key insight is that we can test tutorial files without installing them as
# tutorials. 


test_that("knit_tutorials() works on legal tutorials", {
  expect_null(
    knit_tutorials("fixtures/tutorial_examples/good-tutorial.Rmd")
  )
  expect_null(
    knit_tutorials(
      c("fixtures/tutorial_examples/good-tutorial.Rmd",
        "fixtures/tutorial_examples/no-info-tutorial.Rmd"))
  )
})


test_that("knit_tutorials() works on Getting Started tutorial", {
  
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

