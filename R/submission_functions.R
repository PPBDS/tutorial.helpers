#' @title Tutorial submission functions
#' @rdname submission_functions
#'
#' @description 
#'   Provides the core Shiny server and UI hooks for collecting and downloading student answers
#'   from a learnr tutorial. `submission_server()` should be called in an Rmd code chunk with
#'   `context="server"`. 
#'   
#'   This function was modified from Colin Rundel's learnrhash package
#'   (https://github.com/rundel/learnrhash).
#'
#' @details
#'   The server function uses a Shiny downloadHandler to let students download their answers.
#'   All main logic must be wrapped in `local()` with `parent.frame()` to ensure access to the live
#'   learnr session and objects created in the parent environment.
#'
#'   The `session` object (created by Shiny) is only available inside the `downloadHandler$content`
#'   function, so any test-case extraction or answer writing must happen there.
#'
#'   For reference: the `file` argument in `content` is a temporary file path created by Shiny,
#'   and your handler's job is to write the downloadable file there.
#'
#'   If you want to generate test fixtures, insert `browser()` inside the `content` function,
#'   then use functions like `get_submissions_from_learnr_session(session)` at the prompt.
#'
#'   See also: https://mastering-shiny.org/action-transfer.html#downloading-reports
#'
#' @examples
#' if(interactive()){
#'   submission_server()
#' }
#'
#' @export
#'
#' @returns No return value; called for side effects in a Shiny/learnr session.

submission_server <- function() {
  p <- parent.frame()



  # All main logic is run in the parent frame to access live session/reactive values.
  local({
    output$downloadHtml <- shiny::downloadHandler(
      filename = paste0(learnr::get_tutorial_info()$tutorial_id, "_answers.html"),
      content = function(file) {
        # browser()
        # subs <- tutorial.helpers:::get_submissions_from_learnr_session(session)
        # saveRDS(subs, testthat::test_path("fixtures", "session_save.rds"))
        write_answers(file, session)
      }
    )
  }, envir = p)
  
  NULL
}

#' @rdname submission_functions
#'
#' @description UI block to include a download button and simple instructions for students.
#'
#' @examples
#' if(interactive()){
#'   submission_ui
#' }
#'
#' @export
#'
#' @returns An object of class shiny.tag

submission_ui <- shiny::div(
  "When you have completed this tutorial, follow these steps:",
  shiny::tags$br(),
  shiny::tags$ol(
    shiny::tags$li("Click the button to download a file containing your answers."),
    shiny::tags$li("Save the file onto your computer in a convenient location.")
  ),
  shiny::fluidPage(
    shiny::mainPanel(
      shiny::div(id = "form",
                 shiny::downloadButton(outputId = "downloadHtml", label = "Download HTML"))
    )
  ),
  shiny::div(
    shiny::tags$br(),
    "(If no file seems to download, try right-clicking the download button and choose \"Save link as...\")",
    shiny::tags$br()
  )
)

