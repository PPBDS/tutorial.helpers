---
title: "Rstudio Addins"
author: David Kane
output: rmarkdown::html_vignette
vignette: >
  %\VignetteEngine{knitr::knitr}
  %\VignetteIndexEntry{Rstudio Addins}
  %\VignetteEncoding{UTF-8}
---



## Overview

We have provided four additions to the RStudio Addins menu: "Tutorial Code Exercise", "Tutorial Written Exercise (with Answer)", "Tutorial Written Exercise (no Answer)" and "Format Tutorial Chunk Labels." The first three each insert the skeleton for the next exercise in a tutorial, featuring all the key component parts. We even takes a guess at the correct exercise number.  The "Format Tutorial Chunk Labels" addin is the most useful. Always run it before testing your tutorial. It ensures that all the exercises are sequentially numbered and that all the code chunk names are correct and unique.

You can find the addins in the "Addins" tab on the top Rstudio toolbar. Make sure that your cursor is located at the point in your Rmd at which you want to insert the new exercise. 

<img src="images/code-exercise-1.png" alt="plot of chunk unnamed-chunk-1" width="95%" height="95%" />

### Tutorial Code Exercise

Create a new code exercise skeleton with an exercise title and with auto-generated code chunk ids.



````default
### Exercise 7

```{r exercises-7, exercise = TRUE}

```

<button onclick = "transfer_code(this)">Copy previous code</button>

```{r exercises-7-hint, eval = FALSE}

```

```{r, include = FALSE}

```
###
````

See [our advice](https://ppbds.github.io/tutorial.helpers/articles/instructions.html#exercises) about writing good tutorial Code Exercises. First. start with the correct answer, the code you want students to submit. Please that code in the Test Chunk at the end. Our test process will ensure that this code will work for the students. Second, copy/paste the correct answer into the Hint Chunk in the middle. Then replace one or more of the key words or function arguments or argument values with `...`. Third, add your actual question to the top of the skeleton. What instructions will cause students to enter the correct answer in the Exercise Code Chunk? Fourth, drop some knowledge after the `###` at the end. Each Exercise is an opportunity to teach. Make use of them!


### Tutorial Written Exercise (with and without answers)

Both create similar exercise structures with auto-generated code chunk id and Exercise number. The difference is that the `question_text()` options are filled in differently.

Tutorial Written Exercise (with Answer):


````default
### Exercise 8

```{r exercises-8}
question_text(NULL,
	message = "Place correct answer here.",
	answer(NULL, correct = TRUE),
	allow_retry = FALSE,
	incorrect = NULL,
	rows = 6)
```

###
````

Written Exercise (no Answer):


````default
### Exercise 9

```{r exercises-9}
question_text(NULL,
	answer(NULL, correct = TRUE),
	allow_retry = TRUE,
	try_again_button = "Edit Answer",
	incorrect = NULL,
	rows = 3)
```

###
````

The "with Answer" Exercises require the tutorial author to provide an (excellent!) answer to the question. This is harder than it looks, especially for questions without a single "right" answer. But it is also a rare opportunity since students will usually study the supplied answer quite closely. They want to check that their answer matches. We can't allow students to edit their answers to these questions since they might (misuse) that option to just copy/paste/modify our supplied answer.

The "no Answer" Exercises are usually used for confirmation that a student has completed a specified task. In that case, there is no need for us to supply a correct answer. And we can allow students to edit their submissions.

### Format Tutorial Chunk Labels

We often need to add a new Exercise in the middle of a collection of other Exercises. Or, we want to delete one Exercise from the middle of the collection. In either scenario, our Exercises are now mis-numbered. We either have two Exercise 5's or we go straight from Exercise 4 to Exercise 5. We want to renumber all the remaining Exercises so that there are no duplicates or missing numbers.

The "Format Tutorial Chunk Labels" addin accomplishes this renumbering. But it also does more, changing all the code chunk names --- both in the Exercise chunks and the Hint chunks --- to be consistent with the new Exercise numbers. Finally, it ensures that all code chunk labels follow our standard: begin with (up to 20 characters from) the Section Title, remove special characters, replace spaces with dashes, and make all letters lowercase.

Since the code chunk labels (derived from your section titles) have a hard cutoff at 20 characters, try to make sure that your Section Titles are different somewhere in the first 20 characters (including spaces). If not, the tutorial will not run since unique code chunk labels are required.




