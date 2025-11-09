# Tutorial submission functions

Provides the core Shiny server and UI hooks for collecting and
downloading student answers from a learnr tutorial.
`submission_server()` should be called in an Rmd code chunk with
`context="server"`.

This function was modified from Colin Rundel's learnrhash package
(https://github.com/rundel/learnrhash).

UI block to include a download button and simple instructions for
students.

## Usage

``` r
submission_server()

submission_ui
```

## Format

An object of class `shiny.tag` of length 3.

## Value

No return value; called for side effects in a Shiny/learnr session.

An object of class shiny.tag

## Details

The server function uses a Shiny downloadHandler to let students
download their answers. All main logic must be wrapped in
[`local()`](https://rdrr.io/r/base/eval.html) with
[`parent.frame()`](https://rdrr.io/r/base/sys.parent.html) to ensure
access to the live learnr session and objects created in the parent
environment.

The `session` object (created by Shiny) is only available inside the
`downloadHandler$content` function, so any test-case extraction or
answer writing must happen there.

For reference: the `file` argument in `content` is a temporary file path
created by Shiny, and your handler's job is to write the downloadable
file there.

If you want to generate test fixtures, insert
[`browser()`](https://rdrr.io/r/base/browser.html) inside the `content`
function, then use functions like
`get_submissions_from_learnr_session(session)` at the prompt.

See also:
https://mastering-shiny.org/action-transfer.html#downloading-reports

## Examples

``` r
if(interactive()){
  submission_server()
}

if(interactive()){
  submission_ui
}
```
