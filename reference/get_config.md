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
#> → Creating Lesson in /tmp/RtmpitXu2m/file19b362bc0f62...
#> ℹ No schedule set, using Rmd files in episodes/ directory.
#> → Creating Lesson in /tmp/RtmpitXu2m/file19b362bc0f62...
#> → To remove this message, define your schedule in config.yaml or use `set_episodes()` to generate it.
#> → Creating Lesson in /tmp/RtmpitXu2m/file19b362bc0f62...
#> ────────────────────────────────────────────────────────────────────────
#> → Creating Lesson in /tmp/RtmpitXu2m/file19b362bc0f62...
#> ℹ To save this configuration, use
#> 
#> set_episodes(path = path, order = ep, write = TRUE)
#> → Creating Lesson in /tmp/RtmpitXu2m/file19b362bc0f62...
#> ☐ Edit /tmp/RtmpitXu2m/file19b362bc0f62/episodes/introduction.md.
#> → Creating Lesson in /tmp/RtmpitXu2m/file19b362bc0f62...
#> ✔ First episode created in /tmp/RtmpitXu2m/file19b362bc0f62/episodes/introduction.md
#> → Creating Lesson in /tmp/RtmpitXu2m/file19b362bc0f62...
#> ℹ Using GitHub token for authenticated API request.
#> → Creating Lesson in /tmp/RtmpitXu2m/file19b362bc0f62...
#> ℹ Downloading workflows from https://api.github.com/repos/carpentries/workbench-workflows/releases/latest
#> → Creating Lesson in /tmp/RtmpitXu2m/file19b362bc0f62...
#> ℹ Workflows up-to-date!
#> → Creating Lesson in /tmp/RtmpitXu2m/file19b362bc0f62...
#> ✔ Lesson successfully created in /tmp/RtmpitXu2m/file19b362bc0f62
#> → Creating Lesson in /tmp/RtmpitXu2m/file19b362bc0f62...
#> /tmp/RtmpitXu2m/file19b362bc0f62
get_config(tmp)
#> $carpentry
#> [1] "incubator"
#> 
#> $title
#> [1] "Lesson Title"
#> 
#> $created
#> [1] "2026-09-30"
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
#> [1] "https://github.com/carpentries/file19b362bc0f62"
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
