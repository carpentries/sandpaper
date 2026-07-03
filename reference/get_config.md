# Get the configuration parameters for the lesson

Get the configuration parameters for the lesson

## Usage

``` r
get_config(path = ".")
```

## Arguments

- path:

  path to the lesson

## Value

a yaml list

## Examples

``` r
tmp <- tempfile()
create_lesson(tmp, open = FALSE, rmd = FALSE)
#> → Creating Lesson in /tmp/RtmpqRlAf5/file1aae3a4bb0d4...
#> ℹ No schedule set, using Rmd files in episodes/ directory.
#> → Creating Lesson in /tmp/RtmpqRlAf5/file1aae3a4bb0d4...
#> → To remove this message, define your schedule in config.yaml or use `set_episodes()` to generate it.
#> → Creating Lesson in /tmp/RtmpqRlAf5/file1aae3a4bb0d4...
#> ────────────────────────────────────────────────────────────────────────
#> → Creating Lesson in /tmp/RtmpqRlAf5/file1aae3a4bb0d4...
#> ℹ To save this configuration, use
#> 
#> set_episodes(path = path, order = ep, write = TRUE)
#> → Creating Lesson in /tmp/RtmpqRlAf5/file1aae3a4bb0d4...
#> ☐ Edit /tmp/RtmpqRlAf5/file1aae3a4bb0d4/episodes/introduction.md.
#> → Creating Lesson in /tmp/RtmpqRlAf5/file1aae3a4bb0d4...
#> ✔ First episode created in /tmp/RtmpqRlAf5/file1aae3a4bb0d4/episodes/introduction.md
#> → Creating Lesson in /tmp/RtmpqRlAf5/file1aae3a4bb0d4...
#> ℹ Using GitHub token for authenticated API request.
#> → Creating Lesson in /tmp/RtmpqRlAf5/file1aae3a4bb0d4...
#> ℹ Downloading workflows from https://api.github.com/repos/carpentries/workbench-workflows/releases/latest
#> → Creating Lesson in /tmp/RtmpqRlAf5/file1aae3a4bb0d4...
#> ℹ Workflows up-to-date!
#> → Creating Lesson in /tmp/RtmpqRlAf5/file1aae3a4bb0d4...
#> ✔ Lesson successfully created in /tmp/RtmpqRlAf5/file1aae3a4bb0d4
#> → Creating Lesson in /tmp/RtmpqRlAf5/file1aae3a4bb0d4...
#> /tmp/RtmpqRlAf5/file1aae3a4bb0d4
get_config(tmp)
#> $carpentry
#> [1] "incubator"
#> 
#> $title
#> [1] "Lesson Title"
#> 
#> $created
#> [1] "2026-07-03"
#> 
#> $keywords
#> [1] "software, data, lesson, The Carpentries"
#> 
#> $life_cycle
#> [1] "pre-alpha"
#> 
#> $license
#> [1] "CC-BY 4.0"
#> 
#> $source
#> [1] "https://github.com/carpentries/file1aae3a4bb0d4"
#> 
#> $branch
#> [1] "main"
#> 
#> $contact
#> [1] "team@carpentries.org"
#> 
#> $episodes
#> [1] "introduction.md"
#> 
#> $learners
#> NULL
#> 
#> $instructors
#> NULL
#> 
#> $profiles
#> NULL
#> 
```
