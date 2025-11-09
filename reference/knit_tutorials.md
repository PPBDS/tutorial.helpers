# Knit a set of tutorials

We define "testing" a tutorial as (successfully) running `render()` on
it. This function renders all the tutorials provided in
`tutorial_paths`. There is no check to see if the rendered file looks
OK. If a tutorial fails to render, then an error will be generated which
will propagate to the caller.

## Usage

``` r
knit_tutorials(tutorial_paths)
```

## Arguments

- tutorial_paths:

  Character vector of the paths to the tutorials to be knitted.

## Value

No return value, called for side effects.

## Examples

``` r
if (FALSE) { # \dontrun{
  knit_tutorials(tutorial_paths = return_tutorial_paths("tutorial.helpers"))
} # }
```
