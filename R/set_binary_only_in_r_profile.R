#' @title Set pkgType to binary in .Rprofile
#'
#' @description
#'
#' This functions sets the `pkgType` global option to "binary" in your
#' `.Rprofile`. New R users, especially those on Windows, should never install
#' from source. Doing so fails too often, and too confusingly. It also sets the
#' value for this R session. So, you do not need to either restart R nor source
#' the .Rprofile by hand.
#'
#' You can examine your `.Rprofile` to confirm this change with
#' usethis::edit_r_profile()
#'
#' @returns No return value, called for side effects.
#'
#' @export

set_binary_only_in_r_profile <- function(){
  
  # Should we still change the option value to binary at the end of this
  # function? It is bad practice to just change options, I think. Perhaps we
  # could just require students to restart the R session?

  # This function is modeled after the function census_api_key() from the
  # tidycensus package. We only do it on non-Linux systems because Linux is
  # confusing and new users rarely use Linux. (What about Chromebooks?)

  if(Sys.info()["sysname"] != "Linux"){

    # Get path to user Rprofile and Renviron

    home <- Sys.getenv("HOME")
    rprof <- file.path(home, ".Rprofile")

    # Create lines to insert. We added the trailing newline because there is a
    # bug (?) whereby the .Rprofile script does not run when the .Rprofile file
    # does not end with a trailing newline.

    rprof_line <- "options(pkgType = 'binary')\n"

    # If user already has an .Rprofile, then just append to that file If not,
    # create an .Rprofile in home directory and write to that. I *think* that
    # new installations do not create a .Rprofile by default.

    if(file.exists(rprof)){

      curr_prof <- readr::read_file(rprof)


      # If option already in user's .Rprofile, then just don't write in it

      if(stringr::str_detect(gsub(" ", "", curr_prof), 
                             stringr::fixed(gsub(" ", "", rprof_line)))){

        message("options(pkgType = 'binary') is already in your .Rprofile.")

      }else{
        
        # We claim to be appending, but we are really replacing. Should we just
        # append?

        message("Appending options(pkgType = 'binary') to your .Rprofile")

        write(paste0(trimws(curr_prof), "\n", rprof_line), file = rprof, append = FALSE)

      }
    }
    if(!file.exists(rprof)){

      message("Creating .Rprofile in your home directory")

      file.create(rprof)

      write(rprof_line, file = rprof, append = TRUE)

    }

  # Set pkgType to "binary" for this R session

    options(pkgType = "binary")
    message("You will only install the binary version of packages.")
  }
  else{
    message("No changes made to your .Rprofile because you are using Linux.")
  }

}
