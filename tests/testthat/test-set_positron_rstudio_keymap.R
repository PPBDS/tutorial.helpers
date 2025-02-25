# Test suite for set_positron_rstudio_keymap
test_that("set_positron_rstudio_keymap creates/updates settings.json", {
  # Fresh temp directory for this test
  temp_home <- tempdir()
  
  # Use real OS to determine path structure, but with test home_dir
  real_os <- Sys.info()["sysname"]
  if (real_os == "Windows") {
    settings_dir <- file.path(temp_home, "AppData", "Roaming", "Positron", "User")
  } else {  # macOS (Darwin) or other
    settings_dir <- file.path(temp_home, "Library", "Application Support", "Positron", "User")
  }
  settings_file <- file.path(settings_dir, "settings.json")
  
  # Clean up any existing temp files (for repeatability)
  if (file.exists(settings_file)) file.remove(settings_file)
  if (dir.exists(settings_dir)) unlink(settings_dir, recursive = TRUE)
  
  # Run the function with custom home_dir and capture output
  output <- capture.output({
    set_positron_rstudio_keymap(home_dir = temp_home)
  })
  
  # Check that expected messages were produced
  expect_match(
    paste(output, collapse = " "),
    "Created directory.*Created new settings.json.*Added/updated 'rstudio.keymap.enable': true",
    info = "Function did not produce expected creation messages"
  )
  
  # Check that the directory was created
  expect_true(dir.exists(settings_dir), info = "Directory not created")
  
  # Check that settings.json exists
  expect_true(file.exists(settings_file), info = "settings.json not created")
  
  # Read and verify the JSON content
  settings <- jsonlite::read_json(settings_file, simplifyVector = TRUE)
  expect_true(
    is.logical(settings[["rstudio.keymap.enable"]]) && settings[["rstudio.keymap.enable"]],
    info = "'rstudio.keymap.enable' not set to TRUE"
  )
  
  # Clean up temp files after test
  if (file.exists(settings_file)) file.remove(settings_file)
  if (dir.exists(settings_dir)) unlink(settings_dir, recursive = TRUE)
})

test_that("Function does nothing if keymap is already enabled", {
  # Fresh temp directory for this test
  temp_home <- tempdir()
  
  # Set up based on real OS
  real_os <- Sys.info()["sysname"]
  if (real_os == "Windows") {
    settings_dir <- file.path(temp_home, "AppData", "Roaming", "Positron", "User")
  } else {  # macOS (Darwin)
    settings_dir <- file.path(temp_home, "Library", "Application Support", "Positron", "User")
  }
  settings_file <- file.path(settings_dir, "settings.json")
  
  # Pre-create a settings.json with the setting
  dir.create(settings_dir, recursive = TRUE)
  write_json(list("rstudio.keymap.enable" = TRUE), settings_file, pretty = TRUE, auto_unbox = TRUE)
  
  # Run function and capture output
  output <- capture.output({
    set_positron_rstudio_keymap(home_dir = temp_home)
  })
  
  # Check for the "already true" message
  expect_match(
    paste(output, collapse = " "),
    "'rstudio.keymap.enable' is already true",
    info = "Function did not recognize existing setting"
  )
  
  # Verify content didn’t change
  settings <- read_json(settings_file, simplifyVector = TRUE)
  expect_equal(
    settings,
    list("rstudio.keymap.enable" = TRUE),
    info = "Settings were modified unexpectedly"
  )
  
  # Clean up
  if (file.exists(settings_file)) file.remove(settings_file)
  if (dir.exists(settings_dir)) unlink(settings_dir, recursive = TRUE)
})
