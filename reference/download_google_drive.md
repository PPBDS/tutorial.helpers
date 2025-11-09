# Download Files from a Google Drive Folder

Downloads all files or filtered files from a public Google Drive folder
to a local directory.

## Usage

``` r
download_google_drive(
  url,
  path = NULL,
  title = NULL,
  overwrite = TRUE,
  verbose = TRUE
)
```

## Arguments

- url:

  Character string. The Google Drive folder URL or ID. Supports standard
  folder URLs (e.g.,
  `"https://drive.google.com/drive/folders/FOLDER_ID"`) or direct folder
  IDs.

- path:

  Character string or NULL. The local directory path for downloads. If
  NULL (default), uses the current working directory. If the directory
  doesn't exist, it will be created.

- title:

  Character vector or NULL. Patterns to match against file names for
  filtering. If provided, only files whose names contain any of these
  patterns (case-insensitive) are downloaded. If NULL (default), all
  files are downloaded.

- overwrite:

  Logical. If TRUE (default), overwrites existing files. If FALSE, skips
  files that already exist.

- verbose:

  Logical. If TRUE (default), prints detailed progress messages.

## Value

Character string. The path to the directory where files were downloaded.

## Examples

``` r
if (FALSE) { # \dontrun{
# Download all files to current directory
download_google_drive("https://drive.google.com/drive/folders/1Rgxfiw")

# Download to a specific directory with filtering
download_google_drive(
  url = "https://drive.google.com/drive/folders/1Rgxfiw",
  path = "./my_data",
  title = c("report", ".csv"),
  overwrite = FALSE
)
} # }
```
