# Create a code handout of challenges without solutions

This function will build a handout and save it to `files/code-handout.R`
in your lesson website. This will build with your website if you enable
it with `options(sandpaper.handout = TRUE)` or if you want to specify a
path, you can use `options(sandpaper.handout = "/path/to/handout.R")` to
save the handout to a specific path.

## Usage

``` r
build_handout(path = ".", out = NULL)
```

## Arguments

- path:

  the path to the lesson. Defaults to current working directory

- out:

  the path to the handout document. When this is `NULL` (default) or
  `TRUE`, the output will be `site/built/files/code-handout.R`.
