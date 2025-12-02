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
#> → Creating Lesson in /tmp/Rtmpy7dRDl/file19426c78f83a...
#> ℹ No schedule set, using Rmd files in episodes/ directory.
#> → Creating Lesson in /tmp/Rtmpy7dRDl/file19426c78f83a...
#> → To remove this message, define your schedule in config.yaml or use `set_episodes()` to generate it.
#> → Creating Lesson in /tmp/Rtmpy7dRDl/file19426c78f83a...
#> ────────────────────────────────────────────────────────────────────────
#> → Creating Lesson in /tmp/Rtmpy7dRDl/file19426c78f83a...
#> ℹ To save this configuration, use
#> 
#> set_episodes(path = path, order = ep, write = TRUE)
#> → Creating Lesson in /tmp/Rtmpy7dRDl/file19426c78f83a...
#> ☐ Edit /tmp/Rtmpy7dRDl/file19426c78f83a/episodes/introduction.md.
#> → Creating Lesson in /tmp/Rtmpy7dRDl/file19426c78f83a...
#> ✔ First episode created in /tmp/Rtmpy7dRDl/file19426c78f83a/episodes/introduction.md
#> → Creating Lesson in /tmp/Rtmpy7dRDl/file19426c78f83a...
#> ℹ Workflows up-to-date!
#> → Creating Lesson in /tmp/Rtmpy7dRDl/file19426c78f83a...
#> ✔ Lesson successfully created in /tmp/Rtmpy7dRDl/file19426c78f83a
#> → Creating Lesson in /tmp/Rtmpy7dRDl/file19426c78f83a...
#> /tmp/Rtmpy7dRDl/file19426c78f83a
get_config(tmp)
#> $carpentry
#> [1] "incubator"
#> 
#> $title
#> [1] "Lesson Title"
#> 
#> $created
#> [1] "2025-12-02"
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
#> [1] "https://github.com/carpentries/file19426c78f83a"
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
