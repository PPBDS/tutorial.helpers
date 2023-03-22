#' Make Exercise witn an Answer
#'
#' @description
#'
#' It appears that the RStudio addins must have function names only as the
#' Binding value. In other words, you can't have make_exercise(type =
#' 'yes-answer') as the value. So, we need a function which makes this call.
#'
#'
#' @export

make_yes_answer <- function(){
  make_exercise(type = 'yes-answer')
}
