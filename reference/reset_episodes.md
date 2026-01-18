# Clear the schedule in the lesson

Clear the schedule in the lesson

## Usage

``` r
reset_episodes(path = ".")
```

## Arguments

- path:

  path to the lesson

## Value

NULL, invisibly

## Examples

``` r
tmp <- tempfile()
create_lesson(tmp, open = FALSE, rmd = FALSE)
#> → Creating Lesson in /tmp/Rtmpgc9t3l/file1c085a50ab28...
#> ℹ No schedule set, using Rmd files in episodes/ directory.
#> → Creating Lesson in /tmp/Rtmpgc9t3l/file1c085a50ab28...
#> → To remove this message, define your schedule in config.yaml or use `set_episodes()` to generate it.
#> → Creating Lesson in /tmp/Rtmpgc9t3l/file1c085a50ab28...
#> ────────────────────────────────────────────────────────────────────────
#> → Creating Lesson in /tmp/Rtmpgc9t3l/file1c085a50ab28...
#> ℹ To save this configuration, use
#> 
#> set_episodes(path = path, order = ep, write = TRUE)
#> → Creating Lesson in /tmp/Rtmpgc9t3l/file1c085a50ab28...
#> ☐ Edit /tmp/Rtmpgc9t3l/file1c085a50ab28/episodes/introduction.md.
#> → Creating Lesson in /tmp/Rtmpgc9t3l/file1c085a50ab28...
#> ✔ First episode created in /tmp/Rtmpgc9t3l/file1c085a50ab28/episodes/introduction.md
#> → Creating Lesson in /tmp/Rtmpgc9t3l/file1c085a50ab28...
#> ℹ Workflows up-to-date!
#> → Creating Lesson in /tmp/Rtmpgc9t3l/file1c085a50ab28...
#> ✔ Lesson successfully created in /tmp/Rtmpgc9t3l/file1c085a50ab28
#> → Creating Lesson in /tmp/Rtmpgc9t3l/file1c085a50ab28...
#> /tmp/Rtmpgc9t3l/file1c085a50ab28
get_episodes(tmp) # produces warning
#> [1] "introduction.md"
set_episodes(tmp, get_episodes(tmp), write = TRUE)
get_episodes(tmp) # no warning
#> [1] "introduction.md"
reset_episodes(tmp)
get_episodes(tmp) # produces warning again because there is no schedule
#> ℹ No schedule set, using Rmd files in episodes/ directory.
#> → To remove this message, define your schedule in config.yaml or use `set_episodes()` to generate it.
#> [1] "introduction.md"
```
