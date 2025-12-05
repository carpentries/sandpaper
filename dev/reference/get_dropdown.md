# Helpers to extract contents of dropdown menus on the site

This fuction will extract the resources that exist and are listed in the
config file.

## Usage

``` r
get_dropdown(path = ".", folder, trim = TRUE)

get_episodes(path = ".", trim = TRUE)

get_learners(path = ".", trim = TRUE)

get_instructors(path = ".", trim = TRUE)

get_profiles(path = ".", trim = TRUE)
```

## Arguments

- path:

  the path to the lesson, defaults to the current working directory

- folder:

  the folder to extract fromt he dropdown menues

- trim:

  if `TRUE` (default), only the file name will be presented. When
  `FALSE`, the full path will be prepended.

## Value

a character vector of episodes in order of presentation

## Examples

``` r
tmp <- tempfile()
create_lesson(tmp, open = FALSE, rmd = FALSE)
#> → Creating Lesson in /tmp/RtmpPxAdba/file19f950e8823a...
#> ℹ No schedule set, using Rmd files in episodes/ directory.
#> → Creating Lesson in /tmp/RtmpPxAdba/file19f950e8823a...
#> → To remove this message, define your schedule in config.yaml or use `set_episodes()` to generate it.
#> → Creating Lesson in /tmp/RtmpPxAdba/file19f950e8823a...
#> ────────────────────────────────────────────────────────────────────────
#> → Creating Lesson in /tmp/RtmpPxAdba/file19f950e8823a...
#> ℹ To save this configuration, use
#> 
#> set_episodes(path = path, order = ep, write = TRUE)
#> → Creating Lesson in /tmp/RtmpPxAdba/file19f950e8823a...
#> ☐ Edit /tmp/RtmpPxAdba/file19f950e8823a/episodes/introduction.md.
#> → Creating Lesson in /tmp/RtmpPxAdba/file19f950e8823a...
#> ✔ First episode created in /tmp/RtmpPxAdba/file19f950e8823a/episodes/introduction.md
#> → Creating Lesson in /tmp/RtmpPxAdba/file19f950e8823a...
#> ℹ Workflows up-to-date!
#> → Creating Lesson in /tmp/RtmpPxAdba/file19f950e8823a...
#> ✔ Lesson successfully created in /tmp/RtmpPxAdba/file19f950e8823a
#> → Creating Lesson in /tmp/RtmpPxAdba/file19f950e8823a...
#> /tmp/RtmpPxAdba/file19f950e8823a
get_episodes(tmp)
#> [1] "introduction.md"
get_learners(tmp) # information for learners
#> [1] "reference.md" "setup.md"    
```
