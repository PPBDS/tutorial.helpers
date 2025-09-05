# Test suite for set_rprofile_settings

# Helper function to set up a temporary home directory for testing
setup_temp_home <- function() {
  temp_home <- tempfile()
  dir.create(temp_home)
  # Set temporary HOME environment variable
  old_home <- Sys.getenv("HOME")
  Sys.setenv(HOME = temp_home)
  
  list(
    temp_home = temp_home,
    old_home = old_home,
    rprofile_path = file.path(temp_home, ".Rprofile")
  )
}

# Helper function to restore original HOME and clean up
cleanup_temp_home <- function(setup_info) {
  Sys.setenv(HOME = setup_info$old_home)
  if (dir.exists(setup_info$temp_home)) {
    unlink(setup_info$temp_home, recursive = TRUE)
  }
}

# Helper function to create a .Rprofile with specific content
create_rprofile <- function(path, content) {
  writeLines(content, path)
}

# Helper function to read .Rprofile content
read_rprofile <- function(path) {
  if (file.exists(path)) {
    readLines(path, warn = FALSE)
  } else {
    character(0)
  }
}

test_that("set_rprofile_settings creates new .Rprofile on non-Linux systems", {
  skip_on_os("linux")
  
  setup <- setup_temp_home()
  on.exit(cleanup_temp_home(setup))
  
  # Run function
  expect_message(
    set_rprofile_settings(set_for_session = FALSE, backup = FALSE),
    "Creating .Rprofile in your home directory"
  )
  
  # Verify file was created
  expect_true(file.exists(setup$rprofile_path))
  
  # Verify content
  content <- read_rprofile(setup$rprofile_path)
  expect_true(any(grepl("pkgType.*binary", content)))
  expect_true(any(grepl("timeout.*max\\(300", content)))
  expect_true(any(grepl("# R Profile Settings", content)))
})

test_that("set_rprofile_settings creates new .Rprofile on Linux systems", {
  skip_if_not(Sys.info()["sysname"] == "Linux")
  
  setup <- setup_temp_home()
  on.exit(cleanup_temp_home(setup))
  
  # Run function
  expect_message(
    set_rprofile_settings(set_for_session = FALSE, backup = FALSE),
    "Creating .Rprofile in your home directory"
  )
  
  # Verify file was created
  expect_true(file.exists(setup$rprofile_path))
  
  # Verify content (should only have timeout, not binary setting)
  content <- read_rprofile(setup$rprofile_path)
  expect_false(any(grepl("pkgType.*binary", content)))
  expect_true(any(grepl("timeout.*max\\(300", content)))
})

test_that("set_rprofile_settings handles existing .Rprofile without our settings", {
  skip_on_os("linux")
  
  setup <- setup_temp_home()
  on.exit(cleanup_temp_home(setup))
  
  # Create existing .Rprofile with different content
  existing_content <- c(
    "# My existing R profile",
    "options(repos = c(CRAN = 'https://cran.rstudio.com/'))",
    "library(devtools)"
  )
  create_rprofile(setup$rprofile_path, existing_content)
  
  # Run function
  expect_message(
    set_rprofile_settings(set_for_session = FALSE, backup = FALSE),
    "Successfully updated .Rprofile"
  )
  
  # Verify content was added
  content <- read_rprofile(setup$rprofile_path)
  expect_true(any(grepl("pkgType.*binary", content)))
  expect_true(any(grepl("timeout.*max\\(300", content)))
  
  # Verify existing content is preserved
  expect_true(any(grepl("My existing R profile", content)))
  expect_true(any(grepl("library\\(devtools\\)", content)))
})

test_that("set_rprofile_settings detects existing settings", {
  skip_on_os("linux")
  
  setup <- setup_temp_home()
  on.exit(cleanup_temp_home(setup))
  
  # Create .Rprofile with our settings already present
  existing_content <- c(
    "# Existing profile",
    "options(pkgType = 'binary')",
    "options(timeout = max(300, getOption('timeout')))",
    "# Other stuff"
  )
  create_rprofile(setup$rprofile_path, existing_content)
  
  # Run function
  expect_message(
    set_rprofile_settings(set_for_session = FALSE, backup = FALSE),
    "The following settings were already present"
  )
  
  # Content should be unchanged
  new_content <- read_rprofile(setup$rprofile_path)
  expect_equal(length(new_content), length(existing_content))
})

test_that("set_rprofile_settings handles partial existing settings", {
  skip_on_os("linux")
  
  setup <- setup_temp_home()
  on.exit(cleanup_temp_home(setup))
  
  # Create .Rprofile with only one of our settings
  existing_content <- c(
    "# Existing profile",
    "options(pkgType = 'binary')",
    "# Other stuff"
  )
  create_rprofile(setup$rprofile_path, existing_content)
  
  # Run function
  result <- capture_messages(
    set_rprofile_settings(set_for_session = FALSE, backup = FALSE)
  )
  
  # Should report one added, one already present
  expect_true(any(grepl("Added the following settings", result)))
  expect_true(any(grepl("already present", result)))
  
  # Verify timeout was added
  content <- read_rprofile(setup$rprofile_path)
  expect_true(any(grepl("timeout.*max\\(300", content)))
})

test_that("set_rprofile_settings creates and removes backup correctly", {
  skip_on_os("linux")
  
  setup <- setup_temp_home()
  on.exit(cleanup_temp_home(setup))
  
  # Create existing .Rprofile
  existing_content <- c("# Original content", "library(base)")
  create_rprofile(setup$rprofile_path, existing_content)
  
  # Run function with backup enabled (default)
  expect_message(
    set_rprofile_settings(set_for_session = FALSE, backup = TRUE),
    "Removed backup file \\(update successful\\)"
  )
  
  # Should not have backup files remaining
  backup_files <- list.files(setup$temp_home, pattern = "\\.Rprofile\\.backup_")
  expect_equal(length(backup_files), 0)
})

test_that("set_rprofile_settings applies session settings correctly", {
  skip_on_os("linux")
  
  setup <- setup_temp_home()
  on.exit(cleanup_temp_home(setup))
  
  # Store original options
  orig_pkgtype <- getOption("pkgType")
  orig_timeout <- getOption("timeout")
  
  # Run function with session settings enabled
  expect_message(
    set_rprofile_settings(set_for_session = TRUE, backup = FALSE),
    "Applying settings to current R session"
  )
  
  # Verify session options were set
  expect_equal(getOption("pkgType"), "binary")
  expect_gte(getOption("timeout"), 300)
  
  # Restore original options
  if (!is.null(orig_pkgtype)) options(pkgType = orig_pkgtype)
  if (!is.null(orig_timeout)) options(timeout = orig_timeout)
})

test_that("set_rprofile_settings preserves higher timeout values", {
  setup <- setup_temp_home()
  on.exit(cleanup_temp_home(setup))
  
  # Set a high timeout value
  options(timeout = 600)
  
  # Run function
  set_rprofile_settings(set_for_session = TRUE, backup = FALSE)
  
  # Should preserve the higher value
  expect_equal(getOption("timeout"), 600)
})

test_that("set_rprofile_settings skips backup when requested", {
  skip_on_os("linux")
  
  setup <- setup_temp_home()
  on.exit(cleanup_temp_home(setup))
  
  # Create existing .Rprofile
  create_rprofile(setup$rprofile_path, c("# Original"))
  
  # Run without backup
  result <- capture_messages(
    set_rprofile_settings(set_for_session = FALSE, backup = FALSE)
  )
  
  # Should not mention backup
  expect_false(any(grepl("backup", result)))
})

test_that("set_rprofile_settings handles whitespace variations in existing settings", {
  skip_on_os("linux")
  
  setup <- setup_temp_home()
  on.exit(cleanup_temp_home(setup))
  
  # Create .Rprofile with settings that have different whitespace
  existing_content <- c(
    "options( pkgType = 'binary' )",  # Extra spaces
    "options(timeout=max(300,getOption('timeout')))"  # No spaces
  )
  create_rprofile(setup$rprofile_path, existing_content)
  
  # Run function
  expect_message(
    set_rprofile_settings(set_for_session = FALSE, backup = FALSE),
    "already present"
  )
  
  # Should recognize both as already present
  content <- read_rprofile(setup$rprofile_path)
  expect_equal(length(content), 2)  # No additions
})

test_that("set_rprofile_settings adds blank line for readability", {
  skip_on_os("linux")
  
  setup <- setup_temp_home()
  on.exit(cleanup_temp_home(setup))
  
  # Create .Rprofile without trailing newline
  writeLines(c("# Existing", "library(utils)"), setup$rprofile_path, sep = "\n")
  
  # Run function
  set_rprofile_settings(set_for_session = FALSE, backup = FALSE)
  
  # Check that blank line was added for readability
  content <- read_rprofile(setup$rprofile_path)
  expect_true(any(content == ""))  # Should have a blank line
})

test_that("set_rprofile_settings session application works without file modification", {
  # Test that session settings can be applied even when file isn't modified
  
  # Store original options
  orig_timeout <- getOption("timeout")
  options(timeout = 60)  # Set low timeout
  
  # Run with session=TRUE but in a way that doesn't modify file
  # (by providing empty settings list - though this requires modifying the function)
  # Instead, test the session part by calling with existing settings
  
  setup <- setup_temp_home()
  on.exit({
    cleanup_temp_home(setup)
    if (!is.null(orig_timeout)) options(timeout = orig_timeout)
  })
  
  # Create file with settings already present
  if (Sys.info()["sysname"] != "Linux") {
    existing_content <- c(
      "options(pkgType = 'binary')",
      "options(timeout = max(300, getOption('timeout')))"
    )
  } else {
    existing_content <- "options(timeout = max(300, getOption('timeout')))"
  }
  create_rprofile(setup$rprofile_path, existing_content)
  
  # Run function - should apply to session even though file unchanged
  set_rprofile_settings(set_for_session = TRUE, backup = FALSE)
  
  # Verify session was updated
  expect_gte(getOption("timeout"), 300)
})