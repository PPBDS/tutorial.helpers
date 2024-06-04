# Create a temporary directory for test files

temp_dir <- tempdir()

# Create test files with non-portable file names

file.copy(from = "fixtures/process_submissions_dir/Aadi.html",
          to = file.path(temp_dir, "introduction_answers -- Aadi.html"),
          overwrite = TRUE)
file.copy(from = "fixtures/process_submissions_dir/astrxr.html",
          to = file.path(temp_dir, "introduction_answers -- astrxr.html"),
          overwrite = TRUE)
file.copy(from = "fixtures/process_submissions_dir/Ivy.html",
          to = file.path(temp_dir, "ivy-introduction -- Ivy S.html"),
          overwrite = TRUE)

# Set the test directory path as an environment variable
Sys.setenv("TEST_DIR" = temp_dir)
