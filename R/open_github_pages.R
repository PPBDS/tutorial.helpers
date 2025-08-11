#' Open Multiple GitHub Pages in Browser Tabs
#'
#' This function opens multiple GitHub.io pages in browser tabs, making it easy
#' for teaching fellows to quickly review student webpages. It can accept either
#' a vector of URLs or a tibble/data.frame containing URLs.
#'
#' @param urls Either a character vector of URLs to open, OR a tibble/data.frame 
#'        containing submission data with a URL column
#' @param url_var Character string specifying the column name containing URLs.
#'        Required when urls is a tibble/data.frame. Ignored when urls is a character vector.
#' @param label_var Character string specifying the column name to use for 
#'        identifying each submission in verbose output (e.g., "name", "email").
#'        Only used when urls is a tibble/data.frame.
#' @param delay_seconds Numeric value specifying delay between opening each URL
#'        (default is 0.5 seconds to allow browser to process each request)
#' @param browser Character string specifying which browser to use. Options are
#'        "default" (system default), "chrome", "firefox", "safari", or "edge".
#'        On Windows, also supports "msedge". Default is "default".
#' @param verbose Logical value (TRUE or FALSE) specifying verbosity level.
#'        If TRUE, reports each URL as it's being opened.
#'
#' @return Invisible NULL. Function is called for its side effect of opening browser tabs.
#'
#' @details
#' The function uses the system's default method to open URLs, which typically
#' opens them in the default browser. Most modern browsers will open multiple
#' URLs as tabs in the same window when called in quick succession.
#'
#' The delay between opening URLs helps ensure the browser has time to process
#' each request properly. You may need to adjust this delay based on your
#' system performance and browser behavior.
#'
#' @examples
#' \dontrun{
#' # Open multiple GitHub Pages from vector
#' student_sites <- c("https://github.com/Abdul-Hannan96/stops.git")
#' 
#' open_github_pages(student_sites, verbose = TRUE)
#'
#' # Open from tibble/data.frame
#' path <- file.path(find.package("tutorial.helpers"), "tests/testthat/fixtures/answers_html")
#' 
#' result <- submissions_answers(
#'   path = path,
#'   title = c("stop"), 
#'   key_var = "email",
#'   membership = c("bluebird.jack.xu@gmail.com", "abdul.hannan20008@gmail.com"),
#'   vars = c("name","email","temperance-15"),
#'   verbose = TRUE
#' )
#'
#' open_github_pages(result, 
#'                   url_var = "temperance-15",
#'                   verbose = TRUE)
#' }
#'
#' @export
open_github_pages <- function(urls, 
                             url_var = NULL,
                             label_var = NULL,
                             delay_seconds = 0.5, 
                             browser = "default", 
                             verbose = FALSE) {
  
  # Input validation
  if (missing(urls) || is.null(urls)) {
    stop("'urls' must be provided.")
  }
  
  if (!is.numeric(delay_seconds) || length(delay_seconds) != 1 || delay_seconds < 0) {
    stop("'delay_seconds' must be a single non-negative numeric value.")
  }
  
  if (!is.logical(verbose) || length(verbose) != 1) {
    stop("'verbose' must be a single logical value (TRUE or FALSE).")
  }
  
  # Validate browser parameter
  valid_browsers <- c("default", "chrome", "firefox", "safari", "edge", "msedge")
  if (!browser %in% valid_browsers) {
    stop("'browser' must be one of: ", paste(valid_browsers, collapse = ", "))
  }
  
  # Determine input type and extract URLs accordingly
  if (is.data.frame(urls)) {
    # Handle tibble/data.frame input
    submission_data <- urls
    
    if (is.null(url_var)) {
      stop("'url_var' must be provided when 'urls' is a tibble/data.frame.")
    }
    
    if (nrow(submission_data) == 0) {
      stop("'submission_data' is empty.")
    }
    
    if (!url_var %in% colnames(submission_data)) {
      stop("Column '", url_var, "' not found in submission_data. Available columns: ", 
           paste(colnames(submission_data), collapse = ", "))
    }
    
    if (!is.null(label_var) && !label_var %in% colnames(submission_data)) {
      warning("Column '", label_var, "' not found in submission_data. Labels will not be used.")
      label_var <- NULL
    }
    
    # Extract URLs and labels
    url_vector <- submission_data[[url_var]]
    labels <- if (!is.null(label_var)) submission_data[[label_var]] else NULL
    
  } else if (is.character(urls)) {
    # Handle character vector input
    url_vector <- urls
    labels <- NULL
    
    if (length(url_vector) == 0) {
      stop("'urls' vector is empty.")
    }
    
  } else {
    stop("'urls' must be either a character vector or a tibble/data.frame.")
  }
  
  # Remove any empty or NA URLs
  valid_indices <- !is.na(url_vector) & nzchar(trimws(url_vector))
  clean_urls <- url_vector[valid_indices]
  
  if (!is.null(labels)) {
    clean_labels <- labels[valid_indices]
  } else {
    clean_labels <- NULL
  }
  
  if (length(clean_urls) == 0) {
    stop("No valid URLs found after cleaning.")
  }
  
  if (verbose) {
    message("Opening ", length(clean_urls), " URL(s) in browser...")
  }
  
  # Determine browser command based on operating system and browser choice
  get_browser_command <- function(browser_choice, url) {
    os_type <- Sys.info()["sysname"]
    
    if (browser_choice == "default") {
      # Use system default browser
      if (os_type == "Windows") {
        return(paste("start", shQuote(url)))
      } else if (os_type == "Darwin") {  # macOS
        return(paste("open", shQuote(url)))
      } else {  # Linux/Unix
        return(paste("xdg-open", shQuote(url)))
      }
    } else {
      # Use specific browser
      if (os_type == "Windows") {
        browser_paths <- list(
          chrome = "start chrome",
          firefox = "start firefox",
          edge = "start msedge",
          msedge = "start msedge"
        )
        if (browser_choice %in% names(browser_paths)) {
          return(paste(browser_paths[[browser_choice]], shQuote(url)))
        }
      } else if (os_type == "Darwin") {  # macOS
        browser_apps <- list(
          chrome = "open -a 'Google Chrome'",
          firefox = "open -a 'Firefox'",
          safari = "open -a 'Safari'",
          edge = "open -a 'Microsoft Edge'"
        )
        if (browser_choice %in% names(browser_apps)) {
          return(paste(browser_apps[[browser_choice]], shQuote(url)))
        }
      } else {  # Linux/Unix
        browser_commands <- list(
          chrome = "google-chrome",
          firefox = "firefox",
          edge = "microsoft-edge"
        )
        if (browser_choice %in% names(browser_commands)) {
          return(paste(browser_commands[[browser_choice]], shQuote(url)))
        }
      }
      
      # Fallback to default if specific browser not found
      warning("Specified browser '", browser_choice, "' not found. Using default browser.")
      return(get_browser_command("default", url))
    }
  }
  
  # Open each URL
  for (i in seq_along(clean_urls)) {
    url <- clean_urls[i]
    
    # Create label for verbose output
    label <- if (!is.null(clean_labels) && !is.na(clean_labels[i]) && nzchar(trimws(clean_labels[i]))) {
      paste0(" (", clean_labels[i], ")")
    } else {
      ""
    }
    
    if (verbose) {
      message("Opening (", i, "/", length(clean_urls), ")", label, ": ", url)
    }
    
    # Get the appropriate command for this URL
    command <- get_browser_command(browser, url)
    
    # Execute the command
    tryCatch({
      system(command, wait = FALSE, show.output.on.console = FALSE)
    }, error = function(e) {
      warning("Failed to open URL", label, ": ", url, ". Error: ", e$message)
    })
    
    # Add delay between URLs (except for the last one)
    if (i < length(clean_urls) && delay_seconds > 0) {
      Sys.sleep(delay_seconds)
    }
  }
  
  if (verbose) {
    message("Finished opening all URLs.")
  }
  
  invisible(NULL)
}