# Test suite for return_tutorial_paths function

test_that("return_tutorial_paths function exists and has correct signature", {
  expect_true(exists("return_tutorial_paths"))
  expect_true(is.function(return_tutorial_paths))
  
  # Check function arguments
  args <- formals(return_tutorial_paths)
  expect_true("package" %in% names(args))
  expect_equal(length(args), 1)
})

test_that("return_tutorial_paths validates input correctly", {
  # Test with invalid input types
  expect_error(return_tutorial_paths(123), "'package' must be a single character string")
  expect_error(return_tutorial_paths(NULL), "'package' must be a single character string")
  expect_error(return_tutorial_paths(c("pkg1", "pkg2")), "'package' must be a single character string")
  expect_error(return_tutorial_paths(character(0)), "'package' must be a single character string")
})

test_that("return_tutorial_paths handles non-existent packages gracefully", {
  # Should return empty vector with warning for non-existent package
  expect_warning(
    result <- return_tutorial_paths("this_package_definitely_does_not_exist_12345"),
    "Package .* is not installed"
  )
  expect_equal(result, character(0))
  expect_type(result, "character")
})

test_that("return_tutorial_paths handles packages without tutorials", {
  # Base R packages like 'stats' don't have tutorials
  # Should return empty vector, not error
  result <- return_tutorial_paths("stats")
  expect_equal(result, character(0))
  expect_type(result, "character")
})

test_that("return_tutorial_paths works with learnr package", {
  skip_if_not_installed("learnr")
  
  result <- return_tutorial_paths("learnr")
  
  # Should return character vector (may be empty if no tutorials)
  expect_type(result, "character")
  
  # If tutorials are found, they should be valid file paths
  if (length(result) > 0) {
    expect_true(all(file.exists(result)))
    expect_true(all(grepl("\\.Rmd$", result, ignore.case = TRUE)))
    # Should be sorted
    expect_equal(result, sort(result))
  }
})

test_that("return_tutorial_paths works with tutorial.helpers", {
  skip_if_not_installed("tutorial.helpers")
  
  # Check if tutorials directory exists (only available after installation)
  tutorials_dir <- system.file("tutorials", package = "tutorial.helpers")
  skip_if(tutorials_dir == "", "tutorial.helpers not fully installed")
  
  result <- return_tutorial_paths("tutorial.helpers")
  
  expect_type(result, "character")
  
  # If tutorials are found, validate them
  if (length(result) > 0) {
    expect_true(all(file.exists(result)))
    expect_true(all(grepl("\\.Rmd$", result, ignore.case = TRUE)))
    # Should be sorted
    expect_equal(result, sort(result))
    
    # Each path should contain "tutorial.helpers" and "tutorials"
    expect_true(all(grepl("tutorial\\.helpers", result)))
    expect_true(all(grepl("tutorials", result)))
  }
})

test_that("return_tutorial_paths returns consistent output format", {
  skip_if_not_installed("learnr")
  
  result <- return_tutorial_paths("learnr")
  
  # Should always return character vector
  expect_type(result, "character")
  
  # Should be sorted
  expect_equal(result, sort(result))
  
  # No duplicates
  expect_equal(length(result), length(unique(result)))
  
  # If any results, they should be valid paths
  if (length(result) > 0) {
    expect_true(all(file.exists(result)))
    expect_true(all(nzchar(result)))
  }
})

test_that("return_tutorial_paths handles case sensitivity", {
  skip_if_not_installed("learnr")
  
  result <- return_tutorial_paths("learnr")
  
  # Should find .Rmd files regardless of case (.Rmd, .rmd, .RMD)
  if (length(result) > 0) {
    expect_true(all(grepl("\\.[Rr][Mm][Dd]$", result)))
  }
})

test_that("return_tutorial_paths fallback mechanism", {
  # Test that function can handle cases where learnr::available_tutorials fails
  # This is hard to test directly, but we can test with a package that might
  # not register properly with learnr but still has .Rmd files
  
  # Test with a base package - should return empty gracefully
  result <- return_tutorial_paths("utils")
  expect_type(result, "character")
  expect_equal(length(result), 0)
})

test_that("return_tutorial_paths file path construction", {
  skip_if_not_installed("learnr")
  
  result <- return_tutorial_paths("learnr")
  
  if (length(result) > 0) {
    # All paths should be non-empty strings
    expect_true(all(nzchar(result)))
    
    # All paths should end with .Rmd (case insensitive)
    expect_true(all(grepl("\\.Rmd$", result, ignore.case = TRUE)))
    
    # All paths should contain "tutorials" directory
    expect_true(all(grepl("tutorials", result)))
    
    # All files should actually exist
    expect_true(all(file.exists(result)))
  }
})