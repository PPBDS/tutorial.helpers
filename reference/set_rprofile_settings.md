# Configure R Profile Settings for Better User Experience

Configures important settings in your `.Rprofile` to improve the R
experience, especially for new users. This includes:

- Setting package installation to use binaries (non-Linux systems)

- Increasing the timeout for downloads to prevent installation failures

These settings help avoid common issues like source compilation failures
on Windows and timeout errors when downloading large packages.

You can examine your `.Rprofile` to confirm changes with
`usethis::edit_r_profile()`

## Usage

``` r
set_rprofile_settings(set_for_session = TRUE, backup = TRUE)
```

## Arguments

- set_for_session:

  Logical, defaults to `TRUE`. If `TRUE`, also applies these settings to
  the current R session.

- backup:

  Logical, defaults to `TRUE`. If `TRUE`, creates a backup of existing
  `.Rprofile` before modifying it.

## Value

Invisible `NULL`. Called for side effects.

## Examples

``` r
if (FALSE) { # \dontrun{
  # Apply settings to .Rprofile and current session
  set_rprofile_settings()
  
  # Only modify .Rprofile, don't change current session
  set_rprofile_settings(set_for_session = FALSE)
  
  # Modify without creating backup
  set_rprofile_settings(backup = FALSE)
} # }
```
