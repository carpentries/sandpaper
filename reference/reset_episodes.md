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
#> → Creating Lesson in /tmp/RtmpYhnOfg/file1a1d19e4f06d...
#> ℹ No schedule set, using Rmd files in episodes/ directory.
#> → Creating Lesson in /tmp/RtmpYhnOfg/file1a1d19e4f06d...
#> → To remove this message, define your schedule in config.yaml or use `set_episodes()` to generate it.
#> → Creating Lesson in /tmp/RtmpYhnOfg/file1a1d19e4f06d...
#> ────────────────────────────────────────────────────────────────────────
#> → Creating Lesson in /tmp/RtmpYhnOfg/file1a1d19e4f06d...
#> ℹ To save this configuration, use
#> 
#> set_episodes(path = path, order = ep, write = TRUE)
#> → Creating Lesson in /tmp/RtmpYhnOfg/file1a1d19e4f06d...
#> ☐ Edit /tmp/RtmpYhnOfg/file1a1d19e4f06d/episodes/introduction.md.
#> → Creating Lesson in /tmp/RtmpYhnOfg/file1a1d19e4f06d...
#> ✔ First episode created in /tmp/RtmpYhnOfg/file1a1d19e4f06d/episodes/introduction.md
#> → Creating Lesson in /tmp/RtmpYhnOfg/file1a1d19e4f06d...
#> ℹ Using GitHub token for authenticated API request.
#> → Creating Lesson in /tmp/RtmpYhnOfg/file1a1d19e4f06d...
#> ℹ Downloading workflows from https://api.github.com/repos/carpentries/workbench-workflows/releases/latest
#> → Creating Lesson in /tmp/RtmpYhnOfg/file1a1d19e4f06d...
#> ℹ Workflows up-to-date!
#> → Creating Lesson in /tmp/RtmpYhnOfg/file1a1d19e4f06d...
#> ✔ Lesson successfully created in /tmp/RtmpYhnOfg/file1a1d19e4f06d
#> → Creating Lesson in /tmp/RtmpYhnOfg/file1a1d19e4f06d...
#> /tmp/RtmpYhnOfg/file1a1d19e4f06d
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
