# What we really want is a single function which, when called from the tutorial,
# does all the stuff we need. But, presumably, that is impossible. We need (?) a
# Shiny server and Shiny ui. There is not (?) any other way to produce this
# effect.

# Perhaps we can replace this function with the downloadthis package someday:
# https://CRAN.R-project.org/package=downloadthis. My initial testing suggests
# not.

# I need to declare a global variable in order to fix the NOTE from R CMD check.

utils::globalVariables(c("session"))

#' @title Tutorial submission functions
#' @rdname submission_functions
#'
#' @description The following function was modified from Colin Rundel's
#'   learnrhash package, available at https://github.com/rundel/learnrhash. Note
#'   that when including these functions in a learnr Rmd document it is
#'   necessary that the server function, `submission_server()`, be included in
#'   an R chunk where `context="server"`.
#'
#' @examples
#' if(interactive()){
#'   submission_server()
#' }
#'
#' @export
#'
#' @returns No return value, called for side effects.

submission_server <- function() {
  p <- parent.frame()

  # Note that this code is called from within
  # inst/child_documents/download_answers.Rmd. We need information from the
  # parent frame --- from the Rmd code which being run (by Shiny?) for this
  # tutorial. This is the environment which is calling this function,
  # submission_server(). Only this parent environment has access to objects
  # (like session) which we need to access. So, local() makes everything below
  # evaluated in the parent frame.
  
  # Sure seems like a better approach would be to make use of the same mechanism
  # by which Shiny stores the student's work in between sessions. Couldn't we
  # just find that and load it up somehow?
  
  local({

    # downloadHandler is a function, one of the arguments for which is filename.
    # We want to have the file name be different for each tutorial. But how do
    # we know the name of the tutorial in the middle of the session? It is easy
    # to access some information from the session object if we know the correct
    # learnr function. (Note that the session object only seems to exist within
    # a reactive function like this.)
    
    # Since the filename is just the tutorial_id plus the suffix, and since the
    # id information also exists in the session object, we don't really need the
    # call to get_tutorial_info() here.
    
    
    output$downloadHtml <- shiny::downloadHandler(
      filename = paste0(learnr::get_tutorial_info()$tutorial_id,
                        "_answers.html"),
      content = function(file){
        
        # This is how we make test cases. Uncomment this line and comment
        # write_answers(). Then, install the package. This assumes your test
        # case comes from the "Getting Started with Tutorials" tutorial). Then
        # run your tutorial as normal, choosing the RDS option at the end.
        
        # saveRDS(session, file = "~/Desktop/test_session_3.rds")
        write_answers(file, session)
      }
    )
    
    output$downloadRds <- shiny::downloadHandler(
      filename = paste0(learnr::get_tutorial_info()$tutorial_id,
                        "_answers.rds"),
      
      # Note that you must wrap the call to write_answers() inside a function. I
      # am confused about why. No doubt some weird Shiny/reactive thing . . .
      # But, then, why don't we need to do th same wrapping for the value of
      # filename just above?
      
      # Also, where does the value for "file" come from below? The Shiny book
      # reports that "`content` should be a function with one argument, `file`,
      # which is the path to save the file. The job of this function is to save
      # the file in a place that Shiny knows about, so it can then send it to
      # the user." Confusing!
      
      # The use of session is also weird. First, there is no explicit "session"
      # object. Presumably, this comes from the magic of Shiny, along with
      # local() and parent.frame(). Second, Section 9.2.2 of the Shiny Book
      # gives an example which uses a reactive object. Maybe this is a better
      # approach? Maybe is a reactive object which is automatically created in
      # Shiny?
      
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
    shiny::tags$li("Click a button to download a file containing your answers."),
    shiny::tags$li("Save the file onto your computer in a convenient location.")),
  shiny::fluidPage(
    shiny::mainPanel(
      shiny::div(id = "form",
                 shiny::downloadButton(outputId = "downloadRds", label = "Download RDS"),
                 shiny::downloadButton(outputId = "downloadHtml", label = "Download HTML"),
                 shiny::downloadButton(outputId = "downloadPdf", label = "Download PDF"))
    )
  ),
  shiny::div(
    shiny::tags$br(),
    
    "(If no file seems to download, try clicking with the alternative button on the desired download option and choose \"Save link as...\")",
    
    shiny::tags$br()
    )
)

