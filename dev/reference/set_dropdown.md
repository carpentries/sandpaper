# Set the order of items in a dropdown menu

Set the order of items in a dropdown menu

## Usage

``` r
set_dropdown(path = ".", order = NULL, write = FALSE, folder)

set_episodes(path = ".", order = NULL, write = FALSE)

set_learners(path = ".", order = NULL, write = FALSE)

set_instructors(path = ".", order = NULL, write = FALSE)

set_profiles(path = ".", order = NULL, write = FALSE)
```

## Arguments

- path:

  path to the lesson. Defaults to the current directory.

- order:

  the files in the order presented (with extension)

- write:

  if `TRUE`, the schedule will overwrite the schedule in the current
  file.

- folder:

  one of four folders that sandpaper recognises where the files listed
  in `order` are located: episodes, learners, instructors, profiles.

## Examples

``` r
tmp <- tempfile()
create_lesson(tmp, "test lesson", open = FALSE, rmd = FALSE)
#> → Creating Lesson in /tmp/RtmpUfNzdK/file1c8774721641...
#> ℹ No schedule set, using Rmd files in episodes/ directory.
#> → Creating Lesson in /tmp/RtmpUfNzdK/file1c8774721641...
#> → To remove this message, define your schedule in config.yaml or use `set_episodes()` to generate it.
#> → Creating Lesson in /tmp/RtmpUfNzdK/file1c8774721641...
#> ────────────────────────────────────────────────────────────────────────
#> → Creating Lesson in /tmp/RtmpUfNzdK/file1c8774721641...
#> ℹ To save this configuration, use
#> 
#> set_episodes(path = path, order = ep, write = TRUE)
#> → Creating Lesson in /tmp/RtmpUfNzdK/file1c8774721641...
#> ☐ Edit /tmp/RtmpUfNzdK/file1c8774721641/episodes/introduction.md.
#> → Creating Lesson in /tmp/RtmpUfNzdK/file1c8774721641...
#> ✔ First episode created in /tmp/RtmpUfNzdK/file1c8774721641/episodes/introduction.md
#> → Creating Lesson in /tmp/RtmpUfNzdK/file1c8774721641...
#> ℹ Workflows up-to-date!
#> → Creating Lesson in /tmp/RtmpUfNzdK/file1c8774721641...
#> ✔ Lesson successfully created in /tmp/RtmpUfNzdK/file1c8774721641
#> → Creating Lesson in /tmp/RtmpUfNzdK/file1c8774721641...
#> /tmp/RtmpUfNzdK/file1c8774721641
# Change the title and License
set_config(c(title = "Absolutely Free Lesson", license = "CC0"),
  path = tmp,
  write = TRUE
)
#> ℹ Writing to /tmp/RtmpUfNzdK/file1c8774721641/config.yaml
#> → title: 'test lesson' -> title: 'Absolutely Free Lesson'
#> → license: 'CC-BY 4.0' -> license: 'CC0'
create_episode("using-R", path = tmp, open = FALSE)
#> ☐ Edit /tmp/RtmpUfNzdK/file1c8774721641/episodes/using-r.Rmd.
#> /tmp/RtmpUfNzdK/file1c8774721641/episodes/using-r.Rmd
print(sched <- get_episodes(tmp))
#> [1] "introduction.md" "using-r.Rmd"    

# reverse the schedule
set_episodes(tmp, order = rev(sched))
#> episodes:
#> - using-r.Rmd
#> - introduction.md
#> 
#> ────────────────────────────────────────────────────────────────────────
#> ℹ To save this configuration, use
#> 
#> set_episodes(path = tmp, order = rev(sched), write = TRUE)
# write it
set_episodes(tmp, order = rev(sched), write = TRUE)

# see it
get_episodes(tmp)
#> [1] "using-r.Rmd"     "introduction.md"
```
