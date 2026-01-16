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
#> → Creating Lesson in /tmp/Rtmp6Cln26/file1bf93a0dc995...
#> ℹ No schedule set, using Rmd files in episodes/ directory.
#> → Creating Lesson in /tmp/Rtmp6Cln26/file1bf93a0dc995...
#> → To remove this message, define your schedule in config.yaml or use `set_episodes()` to generate it.
#> → Creating Lesson in /tmp/Rtmp6Cln26/file1bf93a0dc995...
#> ────────────────────────────────────────────────────────────────────────
#> → Creating Lesson in /tmp/Rtmp6Cln26/file1bf93a0dc995...
#> ℹ To save this configuration, use
#> 
#> set_episodes(path = path, order = ep, write = TRUE)
#> → Creating Lesson in /tmp/Rtmp6Cln26/file1bf93a0dc995...
#> ☐ Edit /tmp/Rtmp6Cln26/file1bf93a0dc995/episodes/introduction.md.
#> → Creating Lesson in /tmp/Rtmp6Cln26/file1bf93a0dc995...
#> ✔ First episode created in /tmp/Rtmp6Cln26/file1bf93a0dc995/episodes/introduction.md
#> → Creating Lesson in /tmp/Rtmp6Cln26/file1bf93a0dc995...
#> ℹ Workflows up-to-date!
#> → Creating Lesson in /tmp/Rtmp6Cln26/file1bf93a0dc995...
#> ✔ Lesson successfully created in /tmp/Rtmp6Cln26/file1bf93a0dc995
#> → Creating Lesson in /tmp/Rtmp6Cln26/file1bf93a0dc995...
#> /tmp/Rtmp6Cln26/file1bf93a0dc995
get_config(tmp)
#> $carpentry
#> [1] "incubator"
#> 
#> $title
#> [1] "Lesson Title"
#> 
#> $created
#> [1] "2026-01-16"
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
#> [1] "https://github.com/carpentries/file1bf93a0dc995"
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
