# Next time we revisit this, consider some changes. First, split this file into
# two. One part has the two functions we use: submission_server() and
# submission_ui. The second part has all the helper functions.

# Second, bringing in the learnr functions somehow. I hate being dependent on
# learnr given how unresponsive they are. We could just make copies of the
# functions we use. Or we could just incorporate the key code from those
# functions where we need them.

# What we really want is a single function which, when called from the tutorial,
# does all the stuff we need. But, presumably, that is impossible. We need (?) a
# Shiny server and Shiny ui. This is not (?) any other way to produce this
# effect.

# Want to change the color to the OK box so that it is green when students enter
# their email or other text. This seem relevant:

# https://stackoverflow.com/questions/33620133/change-the-color-of-action-button-in-shiny/35871042

# But where, exactly, do we add this code given that we don't control the Shiny
# sessions which learnr itself starts and stops?

# Ought to understand and explain exactly what shiny::div() does.
# NL: Creates an html <div></div> element.

#' @title Tutorial submission functions
#'
#' @description
#'
#' The following function was modified from Colin Rundel's learnrhash package,
#' available at https://github.com/rundel/learnrhash.
#'
#' This note is also modified from Professor Rundel's description: Note that
#' when including these functions in a learnr Rmd document it is necessary that
#' the server function, `submission_server()`, be included in an R chunk where
#' `context="server"`. Conversely, any of the ui functions, `*_ui()`, must *not*
#' be included in an R chunk with a `context`.
#'
#' @param session session object from shiny with learnr
#'
#' @rdname submission_functions
#' @export

submission_server <- function(session) {
  p = parent.frame()

  # We need information from the parent frame --- from the learnr code which is
  # running this tutorial. This is the environment which is calling this
  # function, submission_server. Only this parent environment has access to
  # objects (like input, output, and session) which we need to access. So,
  # local() makes everything below evaluated in the parent frame.

  local({

    output$downloadHtml <- shiny::downloadHandler(
      filename = paste0(learnr::get_tutorial_info()$tutorial_id,
                        "_answers.html"),
      content = function(file){
        build_html(file, session)
      }
    )

    output$downloadRds <- shiny::downloadHandler(

      # Next code chunk is key. downloadHandler is a function, one of the
      # arguments for which is filename. We want to have the file name be
      # different for each tutorial. But how do we know the name of the tutorial
      # in the middle of the session? It is easy to access some information from
      # the session object if we know the correct learnr function. (Note that
      # the call to session only seems to work within a reactive function like
      # this.)

      filename = paste0(learnr::get_tutorial_info()$tutorial_id,
                        "_answers.rds"),

      content = function(file){

        # We used to execute the next two lines in a separate step, requiring
        # users to generate the hash by pressing a button. But this is hardly
        # necessary. We can just do it here, whenever users press the download
        # button. Would be nice to get the learnr people to export these
        # functions so that the ::: hack is not necessary. I have submitted a
        # request: https://github.com/rstudio/learnr/issues/454. The functions
        # are small, so we might just copy them over. But given that we need
        # learnr regardless, that seems excessive.

        build_rds(file, session)
      }
    )

  }, envir = p)
}


#' @rdname submission_functions
#' @export

submission_ui <- shiny::div(

  "When you have completed this tutorial, follow these steps:",

  shiny::tags$br(),
  shiny::tags$ol(
    shiny::tags$li("Click a button to download a file containing your answers. A window will pop up."),
    shiny::tags$li("Save the file onto your computer in a convenient location.")),
  shiny::fluidPage(
    shiny::mainPanel(
      shiny::div(id = "form",
                 shiny::downloadButton(outputId = "downloadRds", label = "Download RDS"),
                 shiny::downloadButton(outputId = "downloadHtml", label = "Download HTML"))
    )
  )
)

# Never understand what this hack does or why it is necessary.

utils::globalVariables(c("session", "page_num"))
