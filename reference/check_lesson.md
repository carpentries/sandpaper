# [deprecated](https://rdrr.io/r/base/Deprecated.html) Check the lesson structure for errors

This function is now deprecated in favour of
[`validate_lesson()`](https://carpentries.github.io/sandpaper/reference/validate_lesson.md).

## Usage

``` r
check_lesson(path = ".", quiet = TRUE)
```

## Arguments

- path:

  the path to your lesson

- quiet:

  if quiet (default TRUE) then no info messages printed to stdout

## Value

`TRUE` (invisibly) if the lesson is cromulent, otherwise, it will error
with a list of things to fix.

## Examples

``` r
# Everything should work out of the box
tmp <- tempfile()
create_lesson(tmp, open = FALSE, rmd = FALSE)
#> → Creating Lesson in /tmp/Rtmpy7dRDl/file19423580e7eb...
#> ℹ No schedule set, using Rmd files in episodes/ directory.
#> → Creating Lesson in /tmp/Rtmpy7dRDl/file19423580e7eb...
#> → To remove this message, define your schedule in config.yaml or use `set_episodes()` to generate it.
#> → Creating Lesson in /tmp/Rtmpy7dRDl/file19423580e7eb...
#> ────────────────────────────────────────────────────────────────────────
#> → Creating Lesson in /tmp/Rtmpy7dRDl/file19423580e7eb...
#> ℹ To save this configuration, use
#> 
#> set_episodes(path = path, order = ep, write = TRUE)
#> → Creating Lesson in /tmp/Rtmpy7dRDl/file19423580e7eb...
#> ☐ Edit /tmp/Rtmpy7dRDl/file19423580e7eb/episodes/introduction.md.
#> → Creating Lesson in /tmp/Rtmpy7dRDl/file19423580e7eb...
#> ✔ First episode created in /tmp/Rtmpy7dRDl/file19423580e7eb/episodes/introduction.md
#> → Creating Lesson in /tmp/Rtmpy7dRDl/file19423580e7eb...
#> ℹ Workflows up-to-date!
#> → Creating Lesson in /tmp/Rtmpy7dRDl/file19423580e7eb...
#> ✔ Lesson successfully created in /tmp/Rtmpy7dRDl/file19423580e7eb
#> → Creating Lesson in /tmp/Rtmpy7dRDl/file19423580e7eb...
#> /tmp/Rtmpy7dRDl/file19423580e7eb
check_lesson(tmp)

# if things do not work, then an error is thrown with information about
# what has failed you
unlink(file.path(tmp, ".gitignore"))
unlink(file.path(tmp, "site"), recursive = TRUE)
try(check_lesson(tmp))
#> ! The .gitignore file is missing the following elements:
#> episodes/*html
#> site/*
#> !site/README.md
#> .Rhistory
#> .Rapp.history
#> .RData
#> .Ruserdata
#> *-Ex.R
#> /*.tar.gz
#> /*.Rcheck/
#> .Rproj.user/
#> vignettes/*.html
#> vignettes/*.pdf
#> .httr-oauth
#> *_cache/
#> /cache/
#> *.utf8.md
#> *.knit.md
#> .Renviron
#> docs/
#> po/*~
#> Error in report_validation(checklist, "There were errors with the lesson structure.") : 
#>   There were errors with the lesson structure.

unlink(tmp)
```
