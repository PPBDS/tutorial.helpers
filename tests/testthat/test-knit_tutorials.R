# Key insight is that we can test tutorial files without installing them as
# tutorials. 


test_that("knit_tutorials() works on legal tutorials", {
  expect_null(
    knit_tutorials("test-data/tutorial_examples/good-tutorial.Rmd")
  )
  expect_null(
    knit_tutorials(
      c("test-data/tutorial_examples/good-tutorial.Rmd",
        "test-data/tutorial_examples/no-info-tutorial.Rmd"))
  )
})


test_that("knit_tutorials() works on Getting Started tutorial", {
  
  # This test works on GHA but not on CRAN Debian, I think because the later
  # does not give you write access. But why would we be able to create some of
  # the other test tutorials? I am lost.
  
  skip_on_os("linux")
  
  expect_null(
    knit_tutorials(
      system.file("tutorials/getting-started/tutorial.Rmd", 
                  package = "tutorial.helpers")
      )
  )
})

test_that("knit_tutorials() fails on illegal tutorials", {
  expect_error(
    knit_tutorials("test-data/tutorial_examples/no-exist.Rmd")
    )
  expect_error(
    knit_tutorials("test-data/tutorial_examples/no-exist.Rmd")
    )
  expect_error(
    knit_tutorials(
      c("test-data/tutorial_examples/good-tutorial.Rmd",
        "test-data/tutorial_examples/no-exist.Rmd")
      )
    )
})

