# Functions for Working with Tutorials

## Overview

We have provided two functions which help in the writing of tutorials:
[`make_exercise()`](https://ppbds.github.io/tutorial.helpers/reference/exercise_creation.md)
and
[`check_current_tutorial()`](https://ppbds.github.io/tutorial.helpers/reference/check_current_tutorial.md).
The first creates a new exercise in the open RMD at the current location
of your cursor. The key argument of
[`make_exercise()`](https://ppbds.github.io/tutorial.helpers/reference/exercise_creation.md)
is `type`, which is `"no-answer"` by default. The other allowed values
of `type` are `"yes-answer"` and `"code"`. The latter is rarely used.
[`check_current_tutorial()`](https://ppbds.github.io/tutorial.helpers/reference/check_current_tutorial.md)
reformats the entire open tutorial, mainly ordering exercises correctly
and ensuring that chunk labels are correct.

Make sure that your cursor is located in the correct location.

### Tutorial Written Exercise (without and with answers)

[`make_exercise()`](https://ppbds.github.io/tutorial.helpers/reference/exercise_creation.md),
by default, sets `type` to `"no-answer"`. It produces a new exercise
skeleton with an exercise title and with auto-generated code chunk
labels. The Topic, of which this Exercise is a part, is titled
“Plotting” so the code chunk id is `plotting`.

```` default
### Exercise 7

```{r plotting-7}
question_text(NULL,
    answer(NULL, correct = TRUE),
    allow_retry = TRUE,
    try_again_button = "Edit Answer",
    incorrect = NULL,
    rows = 5)
```

###

```{r plotting-7-test, echo = TRUE}

```

###
````

There are two code chunks included by default: question and test. You do
not need to include the test, although in most cases you should. The
question code chunk is the location in which students will type or paste
their answers. The test code chunk should include the correct answer, so
that you can be sure it will work for students when they enter it in the
question code chunk.

Both create similar exercise structures with an auto-generated code
chunk id and an exercise number. The difference is that the
`question_text()` options are filled in differently.

Using `make_exercise(type = 'yes-answer')` creates:

```` default
### Exercise 8

```{r plotting-8}
question_text(NULL,
    message = "Place correct answer here.",
    answer(NULL, correct = TRUE),
    allow_retry = FALSE,
    incorrect = NULL,
    rows = 6)
```

###
````

The “yes-answer” exercises require the tutorial author to provide an
(excellent!) answer to the question. This is harder than it looks,
especially for questions without a single “right” answer. But it is also
a rare opportunity since students will usually study the supplied answer
quite closely. They want to check that their answer matches. We can’t
allow students to edit their answers to these questions since they might
(misuse) that option to just copy/paste/modify our supplied answer.

The **learnr** package does not allow for hints to written exercises. We
could add a test chunk, but that rarely makes sense for a written
exercise.

`make_exercise(type = "exercise")` is not used very often, at least by
tutorial authors who believe that teaching students to use AI is of
utmost importance.

### Format exercise numbers and chunk labels

We often need to add a new exercise in the middle of a collection of
other exercises. Or, we want to delete one exercise from the middle of
the collection. In either scenario, our exercises are now mis-numbered.
We either have two Exercise 5’s or we go straight from Exercise 4 to
Exercise 6. We want to renumber all the remaining exercises so that
there are no duplicates or missing numbers.

[`check_current_tutorial()`](https://ppbds.github.io/tutorial.helpers/reference/check_current_tutorial.md)
accomplishes this renumbering. But it also does more, changing all the
code chunk names to be consistent with the new exercise numbers.
Finally, it ensures that all code chunk labels follow our standard:
begin with (up to 30 characters from) the topic title, remove special
characters, replace spaces with dashes, and make all letters lowercase.

Since the code chunk labels (derived from the title of the topic in
which the exercise resides) have a hard cutoff at 30 characters, try to
make sure that your topic titles are different somewhere in the first 30
characters (including spaces) within a given tutorial. If not, the
tutorial will not run since unique code chunk labels are required.
