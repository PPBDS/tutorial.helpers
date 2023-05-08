# What we really want is a single function which, when called from the tutorial,
# does all the stuff we need. But, presumably, that is impossible. We need (?) a
# Shiny server and Shiny ui. This is not (?) any other way to produce this
# effect.

# Perhaps we can replace this function with the downloadthis package someday:
# https://CRAN.R-project.org/package=downloadthis

# When we call this function, we just use submission_server(). But, then, where
# does the information for the session argument come from?


#' @title Tutorial submission functions
#' @rdname submission_functions
#'
#' @description The following function was modified from Colin Rundel's
#'   learnrhash package, available at https://github.com/rundel/learnrhash. Note
#'   that when including these functions in a learnr Rmd document it is
#'   necessary that the server function, `submission_server()`, be included in
#'   an R chunk where `context="server"`.
#'
#' @param session Session object from `Shiny` with `learnr`.
#'
#' @examples
#' if(interactive()){
#'   submission_server(sess)
#' }
#'
#' @export
#'
#' @returns No return value, called for side effects.


submission_server <- function(session) {
  p = parent.frame()
  
  # This code is called from within inst/child_documents/download_answers.Rmd.
  # Note that the call is submission_server(), with no argument. Perhaps the
  # session object just exists somehow? In parent environment? I don't know how
  # this works!

  # We need information from the parent frame --- from the learnr code which is
  # running this tutorial. This is the environment which is calling this
  # function, submission_server. Only this parent environment has access to
  # objects (like input, output, and session) which we need to access. So,
  # local() makes everything below evaluated in the parent frame.
  
  # Sure seems like a better approach would be to make use of the same mechanism
  # by which Shiny stores the student's work in between sessions. Couldn't we
  # just find that and load it up somehow?

  local({

    # downloadHandler is a function, one of the arguments for which is
    # filename. We want to have the file name be different for each tutorial.
    # But how do we know the name of the tutorial in the middle of the
    # session? It is easy to access some information from the session object
    # if we know the correct learnr function. (Note that the call to session
    # only seems to work within a reactive function like this.)
    
    # Since the filename is just the tutorial_id plus the suffix, and since the
    # id information also exists in the session object, we don't really need the
    # call to get_tutorial_info() here.
    
    
    output$downloadHtml <- shiny::downloadHandler(
      filename = paste0(learnr::get_tutorial_info()$tutorial_id,
                        "_answers.html"),
      content = function(file){
        write_answers(file, session)
      }
    )

    output$downloadRds <- shiny::downloadHandler(
      filename = paste0(learnr::get_tutorial_info()$tutorial_id,
                        "_answers.rds"),
      content = function(file){
        write_answers(file, session)
      }
    )
    
    output$downloadPdf <- shiny::downloadHandler(
      filename = paste0(learnr::get_tutorial_info()$tutorial_id,
                        "_answers.pdf"),
      content = function(file){
        write_answers(file, session)
      }
    )

  }, envir = p)
  
  NULL
}


#' @rdname submission_functions
#' 
#' @examples
#' if(interactive()){
#'   submision_ui
#' }
#' 
#' @export
#' 
#' @returns An object of class shiny.tag.


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
                 shiny::downloadButton(outputId = "downloadHtml", label = "Download HTML"),
                 shiny::downloadButton(outputId = "downloadPdf", label = "Download PDF"))
    )
  )
)

