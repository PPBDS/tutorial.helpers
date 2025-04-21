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

test_that("set_positron_settings creates/updates settings.json", {
  temp_home <- tempdir()
  paths <- setup_temp_settings(temp_home)
  
  # Run the function with custom home_dir and capture output
  output <- capture.output({
    set_positron_settings(home_dir = temp_home, set.binary = FALSE)
  })
  
  # Check individual expected messages
  expect_match(output[1], "Created directory:", info = "Directory creation message missing")
  expect_match(output[2], "Created new settings.json at:", info = "File creation message missing")
  expect_match(output[3], "Setting rstudio.keymap.enable to TRUE", info = "Setting update message missing")
  expect_match(output[4], "Updated settings in", info = "Settings update confirmation message missing")
  
  # Check that the directory and file were created
  expect_true(dir.exists(paths$dir), info = "Directory not created")
  expect_true(file.exists(paths$file), info = "settings.json not created")
  
  # Verify JSON content
  settings <- jsonlite::read_json(paths$file, simplifyVector = TRUE)
  expect_true(
    is.logical(settings[["rstudio.keymap.enable"]]) && settings[["rstudio.keymap.enable"]],
    info = "'rstudio.keymap.enable' not set to TRUE"
  )
})

test_that("Function does nothing if all settings are already set", {
  temp_home <- tempdir()
  paths <- setup_temp_settings(temp_home)
  
  # Pre-create settings.json with all settings
  dir.create(paths$dir, recursive = TRUE)
  jsonlite::write_json(
    list(
      "rstudio.keymap.enable" = TRUE
    ), 
    paths$file, pretty = TRUE, auto_unbox = TRUE
  )
  
  # Run function and capture output
  output <- capture.output({
    set_positron_settings(home_dir = temp_home, set.binary = FALSE)
  })
  
  # Check for the "No settings changes needed" message
  expect_match(
    output[1],
    "No settings changes needed in",
    info = "Function did not recognize existing settings"
  )
  
  # Verify content didn't change
  settings <- jsonlite::read_json(paths$file, simplifyVector = TRUE)
  expect_equal(
    settings,
    list(
      "rstudio.keymap.enable" = TRUE
    ),
    info = "Settings were modified unexpectedly"
  )
})

test_that("set.binary = TRUE calls set_binary_only_in_r_profile()", {
  temp_home <- tempdir()
  paths <- setup_temp_settings(temp_home)
  
  # Set up mock and inject into function's environment
  binary_called <- FALSE
  mock_func <- function() {
    binary_called <<- TRUE
  }
  
  # Capture output and override the function in its environment
  output <- capture.output({
    # Temporarily modify the function's environment
    orig_env <- environment(set_positron_settings)
    environment(set_positron_settings) <- list2env(list(set_binary_only_in_r_profile = mock_func), parent = orig_env)
    on.exit(environment(set_positron_settings) <- orig_env)  # Restore after test
    set_positron_settings(home_dir = temp_home, set.binary = TRUE)
  }, type = "output")
  
  # Check that the mock was called
  expect_true(binary_called, info = "set_binary_only_in_r_profile() was not called")
  
  # Check for the binary message, matching literally
  expect_match(
    tail(output, 1)[[1]],
    "Running set_binary_only_in_r_profile() to configure binary options.", 
    fixed = TRUE,
    info = "Binary configuration message missing or incorrect"
  )
})

test_that("set.binary = FALSE skips set_binary_only_in_r_profile()", {
  temp_home <- tempdir()
  paths <- setup_temp_settings(temp_home)
  
  # Set up mock and inject into function's environment
  binary_called <- FALSE
  mock_func <- function() {
    binary_called <<- TRUE
  }
  
  # Capture output and override the function in its environment
  output <- capture.output({
    orig_env <- environment(set_positron_settings)
    environment(set_positron_settings) <- list2env(list(set_binary_only_in_r_profile = mock_func), parent = orig_env)
    on.exit(environment(set_positron_settings) <- orig_env)  # Restore after test
    set_positron_settings(home_dir = temp_home, set.binary = FALSE)
  }, type = "output")
  
  # Check that the mock was not called
  expect_false(binary_called, info = "set_binary_only_in_r_profile() was called unexpectedly")
  
  # Check that the binary message is absent
  expect_false(
    any(grepl("Running set_binary_only_in_r_profile", output)),
    info = "Binary configuration message appeared when it shouldn't"
  )
})
