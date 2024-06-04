# Get the test directory path from the environment variable
temp_dir <- Sys.getenv("TEST_DIR")

# Remove the temporary test directory and its contents
unlink(temp_dir, recursive = TRUE)