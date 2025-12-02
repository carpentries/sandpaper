# Try to use `{renv}`

We use this when sandpaper starts to see if the user has previously
consented to `{renv}`. The problem is that
[`renv::consent()`](https://rstudio.github.io/renv/reference/consent.html)
throws `TRUE` if the user has consented and an error if it has not :(

## Usage

``` r
try_use_renv(force = FALSE)
```

## Arguments

- force:

  if `TRUE`, consent is forced to be TRUE, creating the cache directory
  if it did not exist before. Defaults to `FALSE`, which gently inquires
  for consent.

## Value

a character vector

## Details

This function wraps
[`renv::consent()`](https://rstudio.github.io/renv/reference/consent.html)
in a callr function and transforms the error into `FALSE`. It sets the
`sandpaper.use_renv` variable to the value of that check and then
returns the full text of the output if `FALSE` (this is the WELCOME
message that's given when someone uses `{renv}` for the first time) and
the last line of output if `TRUE` (a message either that a directory has
been created or that consent has already been provided.)
