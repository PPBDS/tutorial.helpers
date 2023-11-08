#' Determine the code chunk name of a new exercise in a tutorial.
#'
#' @param file_path Character string of the file path to the tutorial
#'
#' @return The section id of the exercise based on its section
#' @export

determine_code_chunk_name <- function(file_path = NULL){

  # Unable to test function using the getActiveDocumentContext() function, use
  # the file_path as an alternative. Issue with using file_path is the cursor placement. It will
  # always run the function as if the next exercise to create is at the bottom of the page.
  # Also, note to explore options of including special characters in code chunk names.
  # Currently, most special characters like "{#(.*)}" are excluded and check for the neccesity of some of the
  # trimws functions. Currently, cut_content represents a all the lines in a file in a list which is then reversed.
  # Also note to perhaps explore expanding the 20 character limit for exercises headers. Explore splitting this function up
  # by creating a function that takes a section header and returns a code chunk name (both being character strings).
  # Ultimately this would greatly improve testing but may not be completely necessary.

  if (is.null(file_path))
  {

    ctx <- rstudioapi::getActiveDocumentContext()
    row <- ctx$selection[[1]]$range$end[["row"]]

    cut_content <- rev(ctx$contents[1:row])

  }
  else
  {
    cut_content <- rev(readLines(file_path))

  }

  # Get everything until the current row as a list of lines
  # and reverse that list

  section_id <- "NONE_SET"

  for (l in cut_content){
    # Find the latest section

    if (stringr::str_detect(l, "^## ")){

      # Remove the pattern "{#...}" and non-alphanumeric characters except
      # spaces and slashes
      
      cleaned_l <- gsub("\\{#(.*)\\}", "", l)
      cleaned_l <- gsub("[^a-zA-Z0-9 /]", "", cleaned_l)
      
      # Convert to lowercase, replace spaces and slashes with hyphens, trim to
      # 30 characters, and trim whitespace
      
      section_id <- trimws(cleaned_l)
      section_id <- substr(gsub("[ /]", "-", tolower(section_id)), 1, 30)
      section_id <- gsub("-+$", "", section_id)
      section_id <- gsub("^-+", "", section_id)

      # After finding a section, stop looping immediately

      return(section_id)
    }
  }

}
