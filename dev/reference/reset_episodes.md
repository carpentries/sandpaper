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
#> → Creating Lesson in /tmp/Rtmp6yLLZk/file1acc26e953fc...
#> ℹ No schedule set, using Rmd files in episodes/ directory.
#> → Creating Lesson in /tmp/Rtmp6yLLZk/file1acc26e953fc...
#> → To remove this message, define your schedule in config.yaml or use `set_episodes()` to generate it.
#> → Creating Lesson in /tmp/Rtmp6yLLZk/file1acc26e953fc...
#> ────────────────────────────────────────────────────────────────────────
#> → Creating Lesson in /tmp/Rtmp6yLLZk/file1acc26e953fc...
#> ℹ To save this configuration, use
#> 
#> set_episodes(path = path, order = ep, write = TRUE)
#> → Creating Lesson in /tmp/Rtmp6yLLZk/file1acc26e953fc...
#> ☐ Edit /tmp/Rtmp6yLLZk/file1acc26e953fc/episodes/introduction.md.
#> → Creating Lesson in /tmp/Rtmp6yLLZk/file1acc26e953fc...
#> ✔ First episode created in /tmp/Rtmp6yLLZk/file1acc26e953fc/episodes/introduction.md
#> → Creating Lesson in /tmp/Rtmp6yLLZk/file1acc26e953fc...
#> ℹ Using GitHub token for authenticated API request.
#> → Creating Lesson in /tmp/Rtmp6yLLZk/file1acc26e953fc...
#> ℹ Downloading workflows from https://api.github.com/repos/carpentries/workbench-workflows/releases/latest
#> → Creating Lesson in /tmp/Rtmp6yLLZk/file1acc26e953fc...
#> ℹ Workflows up-to-date!
#> → Creating Lesson in /tmp/Rtmp6yLLZk/file1acc26e953fc...
#> ✔ Lesson successfully created in /tmp/Rtmp6yLLZk/file1acc26e953fc
#> → Creating Lesson in /tmp/Rtmp6yLLZk/file1acc26e953fc...
#> /tmp/Rtmp6yLLZk/file1acc26e953fc
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
