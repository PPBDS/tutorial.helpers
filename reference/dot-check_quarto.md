# Package build dependencies

This function ensures renv detects quarto as a dependency while keeping
it in Suggests rather than Imports. It is deliberately never called: its
mere presence (referencing the quarto namespace) is what makes renv
record quarto. Do not delete it.

## Usage

``` r
.check_quarto()
```
