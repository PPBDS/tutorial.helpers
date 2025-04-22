# Test suite for set_positron_settings

# Helper function to set up and clean up temp directory
setup_temp_settings <- function(temp_home) {
  real_os <- Sys.info()["sysname"]
  if (real_os == "Windows") {
    settings_dir <- file.path(temp_home, "AppData", "Roaming", "Positron", "User")
  } else {  # macOS (Darwin) or other
    settings_dir <- file.path(temp_home, "Library", "Application Support", "Positron", "User")
  }
  settings_file <- file.path(settings_dir, "settings.json")
  
  # Clean up if exists
  if (file.exists(settings_file)) file.remove(settings_file)
  if (dir.exists(settings_dir)) unlink(settings_dir, recursive = TRUE)
  
  list(dir = settings_dir, file = settings_file)
}

# Helper function to create a settings file with specific content
create_settings_file <- function(file_path, settings_content = NULL) {
  # Create parent directory if it doesn't exist
  dir.create(dirname(file_path), recursive = TRUE, showWarnings = FALSE)
  
  if (is.null(settings_content)) {
    # Create empty file
    file.create(file_path)
  } else {
    # Create file with specified content
    jsonlite::write_json(settings_content, file_path, pretty = TRUE, auto_unbox = TRUE)
  }
}

test_that("set_positron_settings handles non-existent file with no changes", {
  temp_home <- tempdir()
  paths <- setup_temp_settings(temp_home)
  
  # Run function with empty positron_settings (default)
  set_positron_settings(home_dir = temp_home, set.binary = FALSE)
  
  # Verify file was created
  expect_true(file.exists(paths$file))
  
  # Verify file contains empty settings
  settings <- jsonlite::read_json(paths$file, simplifyVector = TRUE)
  expect_equal(length(settings), 0)
})

test_that("set_positron_settings handles non-existent file with one change", {
  temp_home <- tempdir()
  paths <- setup_temp_settings(temp_home)
  
  # Run function with one setting
  set_positron_settings(
    home_dir = temp_home, 
    set.binary = FALSE,
    positron_settings = list("rstudio.keymap.enable" = TRUE)
  )
  
  # Verify file was created
  expect_true(file.exists(paths$file))
  
  # Verify settings were applied
  settings <- jsonlite::read_json(paths$file, simplifyVector = TRUE)
  expect_equal(length(settings), 1)
  expect_equal(settings[["rstudio.keymap.enable"]], TRUE)
})

test_that("set_positron_settings handles non-existent file with two changes", {
  temp_home <- tempdir()
  paths <- setup_temp_settings(temp_home)
  
  # Run function with two settings
  set_positron_settings(
    home_dir = temp_home, 
    set.binary = FALSE,
    positron_settings = list(
      "rstudio.keymap.enable" = TRUE,
      "editor.wordWrap" = "on"
    )
  )
  
  # Verify file was created
  expect_true(file.exists(paths$file))
  
  # Verify settings were applied
  settings <- jsonlite::read_json(paths$file, simplifyVector = TRUE)
  expect_equal(length(settings), 2)
  expect_equal(settings[["rstudio.keymap.enable"]], TRUE)
  expect_equal(settings[["editor.wordWrap"]], "on")
})

test_that("set_positron_settings handles empty file with no changes", {
  temp_home <- tempdir()
  paths <- setup_temp_settings(temp_home)
  
  # Create empty file
  create_settings_file(paths$file)
  
  # Run function with empty settings
  set_positron_settings(home_dir = temp_home, set.binary = FALSE)
  
  # Verify file still exists
  expect_true(file.exists(paths$file))
  
  # Verify file contains empty settings
  settings <- jsonlite::read_json(paths$file, simplifyVector = TRUE)
  expect_equal(length(settings), 0)
})

test_that("set_positron_settings handles empty file with one change", {
  temp_home <- tempdir()
  paths <- setup_temp_settings(temp_home)
  
  # Create empty settings file
  create_settings_file(paths$file, list())
  
  # Run function with one setting
  set_positron_settings(
    home_dir = temp_home, 
    set.binary = FALSE,
    positron_settings = list("rstudio.keymap.enable" = TRUE)
  )
  
  # Verify settings were applied
  settings <- jsonlite::read_json(paths$file, simplifyVector = TRUE)
  expect_equal(length(settings), 1)
  expect_equal(settings[["rstudio.keymap.enable"]], TRUE)
})

test_that("set_positron_settings handles empty file with two changes", {
  temp_home <- tempdir()
  paths <- setup_temp_settings(temp_home)
  
  # Create empty settings file
  create_settings_file(paths$file, list())
  
  # Run function with two settings
  set_positron_settings(
    home_dir = temp_home, 
    set.binary = FALSE,
    positron_settings = list(
      "rstudio.keymap.enable" = TRUE,
      "editor.wordWrap" = "on"
    )
  )
  
  # Verify settings were applied
  settings <- jsonlite::read_json(paths$file, simplifyVector = TRUE)
  expect_equal(length(settings), 2)
  expect_equal(settings[["rstudio.keymap.enable"]], TRUE)
  expect_equal(settings[["editor.wordWrap"]], "on")
})

test_that("set_positron_settings handles existing file with irrelevant settings", {
  temp_home <- tempdir()
  paths <- setup_temp_settings(temp_home)
  
  # Create settings file with existing but irrelevant settings
  create_settings_file(paths$file, list(
    "unrelated.setting1" = "value1",
    "unrelated.setting2" = FALSE
  ))
  
  # Run function with new settings
  set_positron_settings(
    home_dir = temp_home, 
    set.binary = FALSE,
    positron_settings = list(
      "rstudio.keymap.enable" = TRUE,
      "editor.wordWrap" = "on"
    )
  )
  
  # Verify all settings are present (old and new)
  settings <- jsonlite::read_json(paths$file, simplifyVector = TRUE)
  expect_equal(length(settings), 4)
  expect_equal(settings[["unrelated.setting1"]], "value1")
  expect_equal(settings[["unrelated.setting2"]], FALSE)
  expect_equal(settings[["rstudio.keymap.enable"]], TRUE)
  expect_equal(settings[["editor.wordWrap"]], "on")
})

test_that("set_positron_settings handles mixed existing settings", {
  temp_home <- tempdir()
  paths <- setup_temp_settings(temp_home)
  
  # Create settings file with mix of relevant and irrelevant settings
  create_settings_file(paths$file, list(
    "unrelated.setting" = "value1",
    "rstudio.keymap.enable" = FALSE,
    "editor.wordWrap" = "on"
  ))
  
  # Run function with settings that partially overlap
  set_positron_settings(
    home_dir = temp_home, 
    set.binary = FALSE,
    positron_settings = list(
      "rstudio.keymap.enable" = TRUE,  # This should change
      "editor.wordWrap" = "on"        # This should not change
    )
  )
  
  # Verify settings were properly updated/preserved
  settings <- jsonlite::read_json(paths$file, simplifyVector = TRUE)
  expect_equal(length(settings), 3)
  expect_equal(settings[["unrelated.setting"]], "value1")  # Preserved
  expect_equal(settings[["rstudio.keymap.enable"]], TRUE)  # Changed
  expect_equal(settings[["editor.wordWrap"]], "on")       # Unchanged
})

test_that("set_positron_settings supports list of lists format", {
  temp_home <- tempdir()
  paths <- setup_temp_settings(temp_home)
  
  # Run function with list of lists format
  set_positron_settings(
    home_dir = temp_home, 
    set.binary = FALSE,
    positron_settings = list(
      list("rstudio.keymap.enable", TRUE),
      list("editor.wordWrap", "on")
    )
  )
  
  # Verify settings were applied
  settings <- jsonlite::read_json(paths$file, simplifyVector = TRUE)
  expect_equal(length(settings), 2)
  expect_equal(settings[["rstudio.keymap.enable"]], TRUE)
  expect_equal(settings[["editor.wordWrap"]], "on")
})

test_that("set_binary parameter properly controls binary profile setting", {
  temp_home <- tempdir()
  paths <- setup_temp_settings(temp_home)
  
  # Mock the binary function
  binary_called <- FALSE
  mock_func <- function() {
    binary_called <<- TRUE
  }
  
  # Temporarily modify the function's environment
  orig_env <- environment(set_positron_settings)
  environment(set_positron_settings) <- list2env(
    list(set_binary_only_in_r_profile = mock_func), 
    parent = orig_env
  )
  
  # Test with set.binary = TRUE
  binary_called <- FALSE
  set_positron_settings(home_dir = temp_home, set.binary = TRUE)
  expect_true(binary_called)
  
  # Test with set.binary = FALSE
  binary_called <- FALSE
  set_positron_settings(home_dir = temp_home, set.binary = FALSE)
  expect_false(binary_called)
  
  # Restore original environment
  environment(set_positron_settings) <- orig_env
})

