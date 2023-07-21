


make_exercise_one <- function(type = "code", file_path = NULL){

  if (is.null(file_path))
  {
    exercise_number <- determine_exercise_number()
    section_id <- determine_code_chunk_name()
  }
  else
  {

    exercise_number <- determine_exercise_number(file_path)
    section_id <- determine_code_chunk_name(file_path)
  }

  if(type == "code"){
    new_exercise <- sprintf("### Exercise %s\n\n\n```{r %s-%s, exercise = TRUE}\n\n```\n\n<button onclick = \"transfer_code(this)\">Copy previous code</button>\n\n```{r %s-%s-hint, eval = FALSE}\n\n```\n\n###\n\n",
                            exercise_number,
                            section_id,
                            exercise_number,
                            section_id,
                            exercise_number)
  }

  new_exercise <-
    dplyr::case_match(
      type,
      "code"       ~ sprintf("### Exercise %s\n\n\n```{r %s-%s, exercise = TRUE}\n\n```\n\n<button onclick = \"transfer_code(this)\">Copy previous code</button>\n\n```{r %s-%s-hint, eval = FALSE}\n\n```\n\n###\n\n",
                             exercise_number,
                             section_id,
                             exercise_number,
                             section_id,
                             exercise_number),
      "no-answer"  ~ sprintf("### Exercise %s\n\n\n```{r %s-%s}\nquestion_text(NULL,\n\tanswer(NULL, correct = TRUE),\n\tallow_retry = TRUE,\n\ttry_again_button = \"Edit Answer\",\n\tincorrect = NULL,\n\trows = 3)\n```\n\n###\n\n",
                             exercise_number,
                             section_id,
                             exercise_number),
      "yes-answer" ~ sprintf("### Exercise %s\n\n\n```{r %s-%s}\nquestion_text(NULL,\n\tmessage = \"Place correct answer here.\",\n\tanswer(NULL, correct = TRUE),\n\tallow_retry = FALSE,\n\tincorrect = NULL,\n\trows = 6)\n```\n\n###\n\n",
                             exercise_number,
                             section_id,
                             exercise_number))

}
