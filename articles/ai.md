# Tutorials in the Age of AI

## Introduction

AI changes everything.

This document describes the best way to write R tutorials using the
[**learnr**](https://rstudio.github.io/learnr/) package. Prior to the
rise of AI,
[this](https://web.archive.org/web/20251008195459/https://ppbds.github.io/tutorial.helpers/articles/instructions.html)
[was](https://web.archive.org/web/20251008195807/https://ppbds.github.io/tutorial.helpers/articles/books.html)
the best way to write tutorials. Our purpose is no longer to teach
students how to code.

> *Our purpose is to teach students how to use AI to create.*

The [**tutorial.helpers**](https://ppbds.github.io/tutorial.helpers/)
package will help you to create good tutorials. Make sure that you are
using the latest development version. Install it with
`pak::pak(PPBDS/tutorial.helpers)`.

## Overview

To create a new tutorial, you first need a new directory, located in the
`inst/tutorials` directory of your package. Create that directory and
then move to it with [`setwd()`](https://rdrr.io/r/base/getwd.html).
Then, run:

    > rmarkdown::draft("tutorial.Rmd",
                      template = "tutorial_template",
                      package = "tutorial.helpers",
                      edit = TRUE)

The template, which is actually
`inst/rmarkdown/templates/tutoral_template/skeleton.Rmd` in the
**tutorial.helpers** package, starts with the `copy-code-chunk`, some
default code which records a student’s name, email and (otionally) id.
The template ends with the `download-answers` code chunk which provides
students with instructions on how to download a copy of their answers.

There is a `setup` code chunk at the top of a tutorial. You must have
[`library(learnr)`](https://rstudio.github.io/learnr/) and, if you use
our tools,
[`library(tutorial.helpers)`](https://ppbds.github.io/tutorial.helpers/)
in this chunk. If your tutorials are part of an R package, then you
should ensure that **tutorial.helpers** is included under Imports in the
DESCRIPTION file and that any library loaded in a tutorial is, at least,
included under Suggests.

Anything typed at the keyboard belongs in \`backticks\` (not “quotation
marks”), except for package names, which are always **bolded**. Function
names always include the parentheses: `read_csv()`, not `read_csv`.
Example: the `+` sign is used to connect `ggplot()` components when
using the **ggplot2** library.

Note that tutorials must be [R Markdown](https://rmarkdown.rstudio.com/)
documents, meaning that their suffix is `.Rmd`. You can not (yet) use
Quarto documents with tutorials. Fortunately, most of what you need
which works in Quarto also works in R Markdown. The main difference is
that code chunk options appear within the
[`{}`](https://rdrr.io/r/base/Paren.html). Don’t worry about this
detail.

AI tutorials begin with an *Introduction* which provides a summary of
the key packages/functions which the tutorial will cover. The
Introduction continues with a series of exercises which set up the
repo/project/QMD in which most of the tutorial will be completed.

After the Introduction, there are 1 or 2 sections — the official
**learnr** nomenclature is *Topics* — which are the meat of the
tutorial.

The last section is the *Summary*. It starts with the same overview with
which the Introduction began, but in the past tense. It then has a
couple exercises which finish up the tutorial by using
`quarto publish gh-pages analysis.qmd` to create a webpage featuring the
cool plots which the student has created. The URL for this new webpage
is usually the answer to the last exercise in Summary, thereby
completing the tutorial.

Anytime you ask a student to execute something in the Console, you
confirm that they have done so with CP/CR, the abbreviation for
**C**opy/**P**aste the **C**ommand/**R**esponse.

[**tutorial.helpers**](https://ppbds.github.io/tutorial.helpers/)
includes two particularly helpful functions:
[`make_exercise()`](https://ppbds.github.io/tutorial.helpers/reference/exercise_creation.md)
and
[`check_current_tutorial()`](https://ppbds.github.io/tutorial.helpers/reference/check_current_tutorial.md).
Use
[`make_exercise()`](https://ppbds.github.io/tutorial.helpers/reference/exercise_creation.md)
to add a new exercise to the current tutorial. It will number the
exercise, and the code chunk labels, automatically. Use
[`check_current_tutorial()`](https://ppbds.github.io/tutorial.helpers/reference/check_current_tutorial.md)
to renumber all the exercises and relabel the code chunks. This is
especially useful if you add or delete an exercise in the middle of a
section.

Students always need more practice working in a Quarto document (the
QMD) and the Console at the same time. Good data scientists go back and
forth between these two modes, writing something in the QMD, executing
it in the Console, editing the QMD, executing again, and so on. We need
to force students to do that more often.

Tutorials are divided into *Topics* that appear on the side panel. To
create these topics, we include a double hash (##) before the text for
it to show up as a side panel. This is also called the *topic title*.
Use [sentence
case](https://apastyle.apa.org/style-grammar-guidelines/capitalization/sentence-case).
On the line after the topic title, put three hashes. This ensures that
students will see the introductory text before they see the first
exercise.

### Questions

There are two types of text questions: 1) those that provide the
students with the correct answer, after they have submitted their own
answer, and, 2) those that do not provide an answer. Examples:

```` default
### Exercise 6

Explain potential outcomes in about two sentences.

```{r definitions-6}
question_text(NULL,
    message = "This is where we place the correct answer. It will appear only after 
    students have submitted their own answers. Note that we do not need to wrap the 
    answer text by hand.",          
    answer(NULL, 
           correct = TRUE),
    allow_retry = FALSE,
    incorrect = NULL,
    rows = 6)
``` 
````

For the `message` argument, you should provide an **excellent** answer.
We want to allow students to check for themselves that they got, more or
less, the correct answer. Note how we set `allow_retry` to FALSE. This
means that, after they see our answer, students can’t modify their
answer. The `rows` argument decides how many rows the empty text input
will have.

Always specify (approximately) how much you want students to write.
Reasonable units are: one sentence, two sentences and a paragraph. Pick
one of these three unless you have a good reason not to. But be wary of
asking for more than a sentence, unless you just want an AI answer. The
ideal question is easier for a student to just answer than to ask AI.

For paragraph questions, you should mention specific words or phrases
which the students should include in their answers. If your suggested
answer includes the word “validity,” for example, then tell the students
to include (and define) validity as part of their answer.

You can insert a text question which provides an answer by placing your
cursor in the desired location and running
`tutorial.helpers::make_exercise(type = "yes-answer")`.

However, for many written questions, we don’t provide an answer, so we
don’t mind if students resubmit. This format is most commonly used for
“process” questions in which we have told students to do something and
then confirm that they have done it by copying/pasting the result from a
command. To create a template for these questions, we run
[`tutorial.helpers::make_exercise()`](https://ppbds.github.io/tutorial.helpers/reference/exercise_creation.md),
since the default value for `type` is `"no-answer"`. Doing so produces
an outline which looks like this:

```` default
### Exercise 7

```{r exercise-7}
question_text(NULL,
    answer(NULL, correct = TRUE),
    allow_retry = TRUE,
    try_again_button = "Edit Answer",
    incorrect = NULL,
    rows = 5)
```

###

```{r exercise-7-test, echo = TRUE}

```

###
````

The question will almost always instruct the student to “CP/CR,” often
after running `show_fle(chunk = "Last")`. Adjust the value of `rows` to
match the expected length of the pasted output. If the question asks
student to run some R code, we will generally include a reasonable
answer in the `test` chunk. This serves two purposes. First, because
`echo = TRUE`, we show the student that code (and its output) in the
tutorial. This code should be excellent. We want students to learn from
our example. Second, the code will be run when we test the tutorial, so
we can be sure that this code (and, we hope, code like it) will work for
the student.

### Knowledge drops

The most difficult part of tutorial creation is writing the “knowledge
drops,” the snippets of wisdom (and the associated links) which are used
at the end of each exercise. These generally come in two categories:
details about R functions/packages/websites and background information
about the substantive data science problem at hand.

Do not expect this to be easy! Good knowledge drops are hard. Make them
short. Students will not read more than a sentence or two.

Perhaps the best place for a knowledge drop, especially for written
questions, is at the start of the exercise. That is, instead of just
asking the question immediately, provide a sentence or two of knowledge
even if this information is not really needed to answer the question.
Students tend to read those sentences closely since they might be
relevant to the question they need to answer.

Rhetorical questions (almost) always work poorly for knowledge drops.

A knowledge drop should not be a road sign. Example: “In the next
section we will explore the data further.” Don’t waste time telling
students what you expect to do next, or what you have just completed
doing. Teach them something real!

The most important knowledge drops mention packages and functions which
we want students to be aware of, packages/functions which they might
want to mention to the AI explicitly, given the topic under
consideration.

### Inputs

In addition to `tutorial.Rmd`, a tutorial will often use other inputs.
The two most common locations for storing these inputs are `data` and
`images` directories at the same level as the `tutorial.Rmd` file. Any
file in `data` or `images` will be available at run time. (Note that the
directories must have these names. Something like `my_data` will not
work.)

#### Data

If you need for an R object to be accessible in an exercise code chunk,
create it in the initial global `setup` code chunk at the top of the
tutorial.

Be wary of code which downloads data from the web. This won’t work if
the student does not have an internet connection when she creates the
tutorial. Instead, save the code which downloaded the data and then
place that object in an RDS file in the `data` directory. Here is an
example from the “Wrangling Census data with Tidyverse tools” tutorial
from the
[**tidycensus.tutorials**](https://ppbds.github.io/tidycensus.tutorials/)
package.

``` default
median_age <- get_acs(geography = "county",
                      variables = "B01002_001",
                      year = 2020)
write_rds(median_age, "data/median_age.rds")

median_age <- read_rds("data/median_age.rds")
```

The first two commands download data and save it to an RDS file in the
`data` directory.

This code assumes that you are located in the same directory as the
`tutorial.Rmd` file. You only run those commands once, and then you
comment them out because you don’t want them re-run each time the
tutorial is created. The `read_rds()` call is never commented out
because we always need the `median_age` object.

When designing tutorials which use objects like `median_age`, we
generally write two exercise code chunks. The first has the student run
the same code as that which we used to create the object ourselves. This
won’t work if the student is not connected to the web but, with luck, in
that case they will get a sensible error message. The second question
informs the students that we have, behind the scenes, assigned the
result of the function to an R object. We then ask the student to just
print out that object. We don’t have them do the assignment themselves,
not least because we don’t like questions which don’t generate any
output.

We use a similar approach with models which can take awhile to fit.
Example:

``` default
fit_gauss <- brm(formula = biden ~ 1,
                data = poll_data,
                refresh = 0,
                silent = 2,
                seed = 9)
write_rds(fit_gauss, "data/fit_gauss.rds")

fit_gauss <- read_rds("data/fit_gauss.rds")
```

Again, this code only works if you are in the tutorial directory, not in
the higher directory of the R project itself. Also, the first two
commands are commented out, unless you are running them by hand to
create the object.

What happens if the data is too large? See the “Arrow” tutorial in the
[**r4ds.tutorials**](https://ppbds.github.io/r4ds.tutorials/) for an
example. First, we generally switch away from code exercises and use
written exercises. Students run the required commands and then
copy/paste the command/response. Big downloads don’t work well in
exercise code chunks. Second, we create small versions of this big data
in the global `setup` chunk. This allows us to create test code chunks
for most of the exercises which follow. These tests will run much more
quickly with this smaller data. Also, for any package on CRAN, we need
to keep the overall size of the package as small as possible.

There are two main uses for files in `data`. First, they can be used at
“compile time” (when the `tutorial.Rmd` is knit to HTML) for making
plots or doing anything else. Second, and more importantly, they are
available to students in the exercise code blocks during “run time”
(when students are doing the tutorial).

#### Images

To add images to a tutorial, first make a directory called `images` in
the folder that contains `tutorial.Rmd`. Store all images for that
tutorial there. You can work with those files in all the usual ways.

Use `include_graphics()` to add the image into the document. Include
this code in its own chunk, in the place where you want the image to
appear in the tutorial.

```` default
```{r}
include_graphics("images/example.png")
```
````

`include_graphics()` is part of the `knitr` package, so you need
[`library(knitr)`](https://yihui.org/knitr/) in the setup code chunk.
Note that you do not need to name these code chunks.

Because students will complete the tutorials using screens of very
different widths, it is a good idea to put
`knitr::opts_chunk$set(out.width = '90%')` in your `setup` code chunk.
In this way, images will appear at a sensible size regardless of whether
students are using a phone screen or a big monitor.

## Tutorial Introduction

Students need some background in order to complete these sorts of
tutorials, some familiarity with R, GitHub and so on. Students should
have completed the “Getting Started” and “Introduction to R” tutorials
from the
[**tutorial.helpers**](https://CRAN.R-project.org/package=tutorial.helpers)
package. They should also complete the first four Positron tutorials
(i.e., through “Positron and GitHub Introduction”) from
[**positron.tutorials**](https://ppbds.github.io/positron.tutorials/).

Always begin by having students set up a repo and a Quarto document to
work in. Again, you must replace `XX` with something sensible and
usually different from the other `XX`’s. So, in the below example, the
name of the repo and the title of the QMD will be different even though
we hold their places with `XX` in both cases.

```` default
### Exercise 1

Create a Github repo called `XX`. Set the "Add a README file" toggle box to "On."

Connect the repo to a project on your computer using `File -> New Folder from Git ...`.  Make sure to select the "Open in a new window" box. 

You need two Positron windows: this one for running the tutorial and the one you just created for writing your code and interacting with the Console.

In the new window, select `File -> New File -> Quarto Document ...`. Provide a title -- `"XX"` -- and an author (you). Save the file as `analysis.qmd`. Render the document. 

Create a `.gitignore` file with `analysis_files` on the first line and then a blank line. Save and push.

In the Console, run:

```         
show_file(".gitignore")
```

If that fails, it is probably because you have not yet loaded `library(tutorial.helpers)` in the Console.

CP/CR.

```{r introduction-1}
question_text(NULL,
    answer(NULL, correct = TRUE),
    allow_retry = TRUE,
    try_again_button = "Edit Answer",
    incorrect = NULL,
    rows = 3)
```

### 

<!-- XX: Insert a knowledge drop related to this project. -->

<!-- XX: By default, the next two questions just mention tidyverse. If there is more than one required library, you can just add those libraries to these steps, adjusting the grammar as needed. Or, you might have separate questions for each library, thereby providing more room for knowledge drops. -->
````

Feel free to copy/paste this question as-is, replacing `XX` with
whatever makes sense for your assignment. That is, you need to provide
your own repo name, Quarto document title and so on. The repo name
should be descriptive and also not likely to have conflicts with other
repos in the students GitHub account, i.e., `golf-scores` not
`project-1`.

You do not need to use `analysis.qmd` as the name of the QMD file which
the student creates. But using the same name doesn’t hurt anything and
is convenient since it decreases the number of things which the tutorial
author needs to change.

You are, obviously, responsible for adding a knowledge drop which
teaches the students something about the larger topic. The most
important things to mention are useful packages and functions.

The second question in the Introduction is usually:

```` default
### Exercise 2

In your QMD, put `library(tidyverse)` in a new code chunk. Render the file using `Cmd/Ctrl + Shift + K`.

Notice that the file does not look good because the code is visible and there are annoying messages. To take care of this, add `#| message: false` to remove all the messages in this `setup` chunk. Also, add the following to the YAML header to remove all code echoes from the HTML:

```         
execute: 
  echo: false
```

Using `Cmd/Ctrl + Shift + K`, render the file again. Only the title and author should appear in the HTML.

In the Console, run:

```         
show_file("analysis.qmd", chunk = "Last")
```

CP/CR.

```{r introduction-2}
question_text(NULL,
    answer(NULL, correct = TRUE),
    allow_retry = TRUE,
    try_again_button = "Edit Answer",
    incorrect = NULL,
    rows = 6)
```

### 

<!-- XX: Insert a knowledge drop related to this project. -->
````

The third question generally loads the **tidyverse** library into the
Console:

```` default
### Exercise 3

Place your cursor in the QMD file on the `library(tidyverse)` line. Use `Cmd/Ctrl + Enter` to execute that line.

Note how this command causes `library(tidyverse)` to be copied down to the Console and then executed. 

CP/CR.

```{r introduction-3}
question_text(NULL,
    answer(NULL, correct = TRUE),
    allow_retry = TRUE,
    try_again_button = "Edit Answer",
    incorrect = NULL,
    rows = 8)
```

###

<!-- XX: Insert a knowledge drop related to this project. -->
````

If the target audience for the tutorial is more experienced, you can be
less didactic, leaving out several of these instructions. You could also
add more steps, like loading more libraries at once.

I recommend offering these explicit instructions in every tutorial.
First, students need lots of practice. Second, each time you tell them
to add something to the QMD, you give yourself an opportunity for a
knowledge drop. The same applies when you tell students to execute, in
the Console, a new addition to the QMD.

```` default
### Exercise 4

<!-- XX: Delete this question if you do not make use of a `data` directory in this tutorial. Note the extra spaces after the command. These are needed to ensure separate lines for each command when students copy/paste. -->

From the Console, run these three commands:

`getwd()`  
`dir.create("data")`  
`list.files()`  

This will create a `data` directory in your project. This is a good place to store any data that you are working with.

CP/CR.

```{r introduction-4}
question_text(NULL,
    answer(NULL, correct = TRUE),
    allow_retry = TRUE,
    try_again_button = "Edit Answer",
    incorrect = NULL,
    rows = 5)
```

###

You answer should look something like this, although your path will be different.

```
> getwd()  
[1] "/Users/dkane/Desktop/projects/xx"  
> dir.create("data")  
> list.files()  
 [1] "analysis_files" "analysis.html"  "analysis.qmd"   "data"           "README.md"    
>  
```

<!-- XX: If you have downloaded some data, then you might want to create the tibbles that you will use here. (Of course, you also need to create those tibbles in the setup chunk so that any test code which create will run.) -->
````

## Tutorial Topics

You will probably have one or two Topics, in between the Introduction
and Summary. Any tutorial which both uses a lot of AI and is supposed to
take an hour or so will only have, at most, two Topics.

``` default
## XX: First topic (use sentence case)
###

<!-- XX: Mention the packages/functions which you plan on covering in this Topic. Not everything mentioned here is specified in the Introduction/Summary, but everything in Introduction/Summary is referenced in one of these topic introductions, the space before Exercise 1 in each topic. -->
```

If you are downloading some data, the natural place to do so is in the
first exercise of a Section.

```` default
### Exercise 1

<!-- XX: In this question, "XX" is the full name of the file, like "cheeses.xlsx". -->

We begin by downloading XX directly from GitHub to the `data` directory using `download.file()`. 

In the Console, run:

```         
download.file(
  "https://github.com/PPBDS/ai.tutorials/raw/refs/heads/main/inst/tutorials/r4ds-2/data/cheeses.xlsx",
  destfile = "data/XX"
)
```

CP/CR.

```{r cheese-1}
question_text(NULL,
    answer(NULL, correct = TRUE),
    allow_retry = TRUE,
    try_again_button = "Edit Answer",
    incorrect = NULL,
    rows = 8)
```

###

<!-- XX: Insert a knowledge drop related to this project. -->
````

The meat of a Topic generally involves asking AI to create a pipe which
accomplishes some goal. The end of a Topic always finishes up with a
plot. The last four questions set up and then guide the student to
creating that plot. If you want the student to mimic a plot, you can
place it in the `images` subdirectory and then use
`knitr::include_graphics("images/plot.png")` to show it to students.

To teach students about topic X, we first need to decide the final
destination. What do we want students to be able to do on their own
after completing the tutorial? For us, this will almost always be a
plot. Having envisioned this goal, we need to create a “path” which
students can use to reach that goal, first under our supervision and,
second, on their own. The path will consist of several stepping stones,
or stops along the way.

To ensure that students are on the right path with their code, we need
to provide them with our code that is verified to be correct. Although
we should not tell students to replace their code with ours at every
step, if a student is lost, they should be able to refer to our code to
get back on track. We also want to include our code in test chunks, both
to show students and to confirm that it works.

Consider this example:

```` default
### Exercise 6

Using your favorite AI, prompt it to generate R code that ... Add the code to your QMD in a new chunk. Place your cursor on the first line of the code and run `Cmd/Ctrl + Enter`.

In the Console, run:

```         
show_file("analysis.qmd", chunk = "Last")
```

CP/CR.

```{r something-1}
question_text(NULL,
    answer(NULL, correct = TRUE),
    allow_retry = TRUE,
    try_again_button = "Edit Answer",
    incorrect = NULL,
    rows = 4)
```

###

```{r, echo = TRUE}
XX: Insert our excellent code, probably made with the help of AI but also "cleaned up" so that it is concise and provides an excellent example for students to mimic.
```

### 

<!-- XX: Insert a knowledge drop related to this project. -->
````

The R chunk with `echo = TRUE` allows the students to see the code we
have written within it. This makes it easy for the students to copy and
paste our code if they need to.

Since `eval = TRUE` is the default argument in an R chunk, the code
within will automatically be run as well. Students will be able to see
any output from the code, which can be helpful if the code plots a
graph. If it is inappropriate or unnecessary to include the output of
the code, just set `eval = FALSE` explicitly.

In that case, the answer chunk would look like:

```` default
```{r, echo = TRUE, eval = FALSE}

```
````

## Plotting Questions

Plotting exercises are generally handled with a sequence of four
questions. Prior to these, the tutorial will probably have the student
practice gathering, organizing, and cleaning the data.

The first of the three prior questions tells the student to replace the
current pipe which they have in the QMD with our code. We check that
they have done so with
[`show_file()`](https://ppbds.github.io/tutorial.helpers/reference/show_file.md).
The purpose of this question is to ensure that the student’s data will
match our data.

```` default
### Exercise 3

Before creating a plot, we need to ensure that your data matches our data. In the QMD, replace your code from the previous exercise with our code.

In the Console, run:

```         
show_file("analysis.qmd", chunk = "Last")
```

CP/CR.

```{r xx-first-section-use-sentence-case-3}
question_text(NULL,
    answer(NULL, correct = TRUE),
    allow_retry = TRUE,
    try_again_button = "Edit Answer",
    incorrect = NULL,
    rows = 6)
```

###

<!-- XX: Insert a knowledge drop related to this project. -->
````

Note that the numbering of theses questions is arbitrary. Just run
[`check_current_tutorial()`](https://ppbds.github.io/tutorial.helpers/reference/check_current_tutorial.md)
to fix it.

The second question tells the student to, in the QMD, assign the result
of the pipe to a new variable, often `x`. We then tell the student to
`Cmd/Ctrl + Enter` this code so that the workspace includes a copy of
`x`.

```` default
### Exercise 4

Within the latest code chunk, add the option: `#| cache: true`. Assign the result of the pipe to `x`. 

`Cmd/Ctrl + Shift + K`. By including `#| cache: true` you cause Quarto to cache the results of the chunk. The next time you render your QMD, as long as you have not changed the code, Quarto will just load up the saved object.

If you have not done so already, you should add `analysis_cache` to the `.gitginore`. The content of the cache file does not belong on GitHub.

Place your cursor on the line where the pipe is assigned to `x`, run `Cmd/Ctrl + Enter`, thus ensuring that the workspace also includes a copy of `x`.

CP/CR.

```{r xx-first-section-use-sentence-case-4}
question_text(NULL,
    answer(NULL, correct = TRUE),
    allow_retry = TRUE,
    try_again_button = "Edit Answer",
    incorrect = NULL,
    rows = 8)
```

###

Our code:

```{r, echo = TRUE}
# x <- ... where the ellipsis are replaced with the code which creates x.
```

###

<!-- XX: Insert a knowledge drop related to this project. -->
````

Note that we need `x` to be created in the QMD, not just in the Console,
because later chunks will use `x` to create the plot.

The third question tells the student to type `x` in the Console,
followed by “CP/CR.” The purpose is both to have the student look at the
tibble and also to set the stage for the actual graphics question. In
defining `x`, you should probably require that the students keep only a
reasonable number of variables.

```` default
### Exercise 5

Within the Console, type `x`, which we previously assigned to a pipe and ran in the Console. Hit `Enter`.

CP/CR.

```{r xx-first-section-use-sentence-case-5}
question_text(NULL,
    answer(NULL, correct = TRUE),
    allow_retry = TRUE,
    try_again_button = "Edit Answer",
    incorrect = NULL,
    rows = 8)
```

###

Our code:

```{r, echo=TRUE}
# x
```

###

<!-- XX: Insert a knowledge drop related to this project. -->
````

This also reminds students that they will often need to tell AI the
variables in `x`, most easily by just copy/pasting the top of `x` into
the AI interface.

Could these questions be combined into one? Probably. But spreading
things has two advantages. First, it ensures that even the weaker
students do not get lost. Second, it provides us with more opportunities
to drop some knowledge.

Now, we can move on to the plotting question. In the age of AI, students
will have AI write code for their plot. They will do that while
specifying that their data is `x` from earlier. The student will add
their new code to a new code cell, and we check that they have done so
with
[`show_file()`](https://ppbds.github.io/tutorial.helpers/reference/show_file.md).
The purpose of this question is to ensure that the student has generated
their own code, albeit with AI help.

```` default
### Exercise 6

Ask AI to generate R code that uses `x` to plot a basic graph showing XX ... Mention you want to use the data from `x` and copy/paste the `x` you ran in the Console with the resulting tibble. You only need the top 3 lines, mainly to include column names.

Within `labs()`, edit or add a proper title, subtitle, and caption. If axis labels would be useful, add them, but if unnecessary, don't bother. Don't assign the code for the plot to any variable. Put the plot code in a new code chunk. Run `Cmd/Ctrl + Shift + K` to ensure that everything works. Make your plot look nice.

In the Console, run:

```         
show_file("analysis.qmd", chunk = "Last")
```

CP/CR.

```{r xx-first-section-use-sentence-case-6}
question_text(NULL,
    answer(NULL, correct = TRUE),
    allow_retry = TRUE,
    try_again_button = "Edit Answer",
    incorrect = NULL,
    rows = 12)
```

###

Our code:

```{r, echo=TRUE}
# XX: Make sure your plotting code is good! This will take some time. You had better have a subtitle which provides the take-away message of the plot. AI sometimes gives you too much code, lots of `theme()` stuff and so on. This is no good! In most cases, we are happy with concise, straightforward code. 
```

###

<!-- XX: Insert a knowledge drop related to this project. -->
````

## Tutorial Summary

Once you have completed one or two Topics, it is time for the Summary
section.

``` default
## Summary
###

<!-- XX: The exact same two to four sentences about the main packages/functions used in the Introduction, but written here in the past tense. You made a promise and you kept it.  -->
```

```` default
### Exercise 1

`Cmd/Ctrl + Shift + K` to ensure that everything works.  The resulting HTML page should be attractive, showing clean versions of your plot(s).

At the Console, run:

```
show_file("analysis.qmd")
```

CP/CR.

```{r summary-1}
question_text(NULL,
    answer(NULL, correct = TRUE),
    allow_retry = TRUE,
    try_again_button = "Edit Answer",
    incorrect = NULL,
    rows = 30)
```

### 

<!-- XX: Insert a knowledge drop related to this project. -->
````

```` default
### Exercise 2

Commit and push all your files. Copy/paste the URL to your Github repo.

```{r summary-2}
question_text(NULL,
    answer(NULL, correct = TRUE),
    allow_retry = TRUE,
    try_again_button = "Edit Answer",
    incorrect = NULL,
    rows = 3)
```

### 

<!-- XX: Insert a knowledge drop related to this project. -->
````

```` default
### Exercise 3

Publish your rendered QMD to GitHub Pages. In the Terminal --- not the Console! --- run:

```
quarto publish gh-pages analysis.qmd
```

Copy/paste the resulting URL below.

```{r summary-3}
question_text(NULL,
    answer(NULL, correct = TRUE),
    allow_retry = TRUE,
    try_again_button = "Edit Answer",
    incorrect = NULL,
    rows = 1)
```

### 

<!-- XX: The tutorial is now over. Add any necessary acknowledgements and/or provide a link to further high quality readings, ideally readings which you mentioned in at least one knowledge drop above. -->
````

In the age of AI, the purpose of a tutorial is to teach students how to
create with AI. We do that by forcing them to practice, and by providing
intelligent advice along the way.
