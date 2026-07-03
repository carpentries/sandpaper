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
#> → Creating Lesson in /tmp/Rtmps3YM4i/file1aec173ee07d...
#> ℹ No schedule set, using Rmd files in episodes/ directory.
#> → Creating Lesson in /tmp/Rtmps3YM4i/file1aec173ee07d...
#> → To remove this message, define your schedule in config.yaml or use `set_episodes()` to generate it.
#> → Creating Lesson in /tmp/Rtmps3YM4i/file1aec173ee07d...
#> ────────────────────────────────────────────────────────────────────────
#> → Creating Lesson in /tmp/Rtmps3YM4i/file1aec173ee07d...
#> ℹ To save this configuration, use
#> 
#> set_episodes(path = path, order = ep, write = TRUE)
#> → Creating Lesson in /tmp/Rtmps3YM4i/file1aec173ee07d...
#> ☐ Edit /tmp/Rtmps3YM4i/file1aec173ee07d/episodes/introduction.md.
#> → Creating Lesson in /tmp/Rtmps3YM4i/file1aec173ee07d...
#> ✔ First episode created in /tmp/Rtmps3YM4i/file1aec173ee07d/episodes/introduction.md
#> → Creating Lesson in /tmp/Rtmps3YM4i/file1aec173ee07d...
#> ℹ Using GitHub token for authenticated API request.
#> → Creating Lesson in /tmp/Rtmps3YM4i/file1aec173ee07d...
#> ℹ Downloading workflows from https://api.github.com/repos/carpentries/workbench-workflows/releases/latest
#> → Creating Lesson in /tmp/Rtmps3YM4i/file1aec173ee07d...
#> ℹ Workflows up-to-date!
#> → Creating Lesson in /tmp/Rtmps3YM4i/file1aec173ee07d...
#> ✔ Lesson successfully created in /tmp/Rtmps3YM4i/file1aec173ee07d
#> → Creating Lesson in /tmp/Rtmps3YM4i/file1aec173ee07d...
#> /tmp/Rtmps3YM4i/file1aec173ee07d
# Change the title and License
set_config(c(title = "Absolutely Free Lesson", license = "CC0"),
  path = tmp,
  write = TRUE
)
#> ℹ Writing to /tmp/Rtmps3YM4i/file1aec173ee07d/config.yaml
#> → title: 'test lesson' -> title: 'Absolutely Free Lesson'
#> → license: 'CC-BY 4.0' -> license: 'CC0'
create_episode("using-R", path = tmp, open = FALSE)
#> ☐ Edit /tmp/Rtmps3YM4i/file1aec173ee07d/episodes/using-r.Rmd.
#> /tmp/Rtmps3YM4i/file1aec173ee07d/episodes/using-r.Rmd
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
