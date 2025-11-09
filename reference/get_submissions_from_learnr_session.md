# Return a list of tutorial answers

Grabs information from the `learnr` session environment, not directly
from the session object itself. Since we are using the session
environment, we currently don't (?) have a way to save the environment
and hence can't test this function.

## Usage

``` r
get_submissions_from_learnr_session(sess)
```

## Arguments

- sess:

  session object from shiny with learnr

## Value

a list which includes the exercise submissions of tutorial
