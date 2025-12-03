# Move an episode in the schedule

If you need to move a single episode, this function gives you a
programmatic or interactive interface to accomplishing this task,
whether you need to add and episode, draft, or remove an episode from
the schedule.

## Usage

``` r
move_episode(ep = NULL, position = NULL, write = FALSE, path = ".")
```

## Arguments

- ep:

  the name of a draft episode or the name/number of a published episode
  to move.

- position:

  the position in the schedule to move the episode. Valid positions are
  from 0 to the number of episodes (+1 for drafts). A value of 0
  indicates that the episode should be removed from the schedule.

- write:

  defaults to `FALSE`, which will show the potential changes. If `TRUE`,
  the schedule will be modified and written to `config.yaml`

- path:

  the path to the lesson (defaults to the current working directory)

## See also

[`create_episode()`](https://carpentries.github.io/sandpaper/reference/create_episode.md),
[`set_episodes()`](https://carpentries.github.io/sandpaper/reference/set_dropdown.md),
[`get_drafts()`](https://carpentries.github.io/sandpaper/reference/get_drafts.md),
[`get_episodes()`](https://carpentries.github.io/sandpaper/reference/get_dropdown.md)

## Examples

``` r
if (interactive() || Sys.getenv("CI") != "") {
  tmp <- tempfile()
  create_lesson(tmp)
  create_episode_md("getting-started", path = tmp, open = FALSE)
  create_episode_rmd("plotting", path = tmp, open = FALSE)
  create_episode_md("experimental", path = tmp, add = FALSE, open = FALSE)
  set_episodes(tmp, c("getting-started.md", "introduction.Rmd", "plotting.Rmd"),
    write = TRUE)

  # Default episode order is alphabetical, we can use this to nudge episodes
  get_episodes(tmp)
  move_episode("introduction.Rmd", 1L, path = tmp) # by default, it shows you the change
  move_episode("introduction.Rmd", 1L, write = TRUE, path = tmp) # write the results
  get_episodes(tmp)

  # Add episodes from the drafts
  get_drafts(tmp)
  move_episode("experimental.md", 2L, path = tmp) # view where it will live
  move_episode("experimental.md", 2L, write = TRUE, path = tmp)
  get_episodes(tmp)

  # Unpublish episodes by setting position to zero
  move_episode("experimental.md", 0L, path = tmp) # view the results
  move_episode("experimental.md", 0L, write = TRUE, path = tmp)
  get_episodes(tmp)

  # Interactively select the position where the episode should go by omitting
  # the position argument
  if (interactive()) {
    move_episode("experimental.md", path = tmp)
  }
}
#> → Creating Lesson in /tmp/RtmpMShUNW/file19323cb8fc4...
#> ℹ No schedule set, using Rmd files in episodes/ directory.
#> → Creating Lesson in /tmp/RtmpMShUNW/file19323cb8fc4...
#> → To remove this message, define your schedule in config.yaml or use `set_episodes()` to generate it.
#> → Creating Lesson in /tmp/RtmpMShUNW/file19323cb8fc4...
#> ────────────────────────────────────────────────────────────────────────
#> → Creating Lesson in /tmp/RtmpMShUNW/file19323cb8fc4...
#> ℹ To save this configuration, use
#> 
#> set_episodes(path = path, order = ep, write = TRUE)
#> → Creating Lesson in /tmp/RtmpMShUNW/file19323cb8fc4...
#> ☐ Edit /tmp/RtmpMShUNW/file19323cb8fc4/episodes/introduction.Rmd.
#> → Creating Lesson in /tmp/RtmpMShUNW/file19323cb8fc4...
#> ✔ First episode created in /tmp/RtmpMShUNW/file19323cb8fc4/episodes/introduction.Rmd
#> → Creating Lesson in /tmp/RtmpMShUNW/file19323cb8fc4...
#> ℹ Workflows up-to-date!
#> → Creating Lesson in /tmp/RtmpMShUNW/file19323cb8fc4...
#> ℹ Consent to use package cache provided
#> → Creating Lesson in /tmp/RtmpMShUNW/file19323cb8fc4...
#> - The project is out-of-sync -- use `renv::status()` for details.
#> → Searching for and installing available dependencies
#> → Hydrating
#> The following packages were discovered:
#> 
#> # ~/work/_temp/Library -------------------------------------------------------
#> - R6            2.6.1
#> - base64enc     0.1-3
#> - bslib         0.9.0
#> - cachem        1.1.0
#> - cli           3.6.5
#> - digest        0.6.39
#> - evaluate      1.0.5
#> - fastmap       1.2.0
#> - fontawesome   0.5.3
#> - fs            1.6.6
#> - glue          1.8.0
#> - highr         0.11
#> - htmltools     0.5.8.1
#> - jquerylib     0.1.4
#> - jsonlite      2.0.0
#> - knitr         1.50
#> - lifecycle     1.0.4
#> - memoise       2.0.1
#> - mime          0.13
#> - rappdirs      0.3.3
#> - rlang         1.1.6
#> - rmarkdown     2.30
#> - sass          0.4.10
#> - tinytex       0.58
#> - xfun          0.54
#> - yaml          2.3.11
#> 
#> They will be copied into the project library.
#> 
#> - Copying packages into the project library ... Done!
#> - Hydrated 26 packages in 0.2 seconds.
#> - The project is out-of-sync -- use `renv::status()` for details.
#> → Recording changes in lockfile
#> The following package(s) will be updated in the lockfile:
#> 
#> # https://packagemanager.posit.co/cran/__linux__/noble/latest ----------------
#> - R6            [* -> 2.6.1]
#> - base64enc     [* -> 0.1-3]
#> - bslib         [* -> 0.9.0]
#> - cachem        [* -> 1.1.0]
#> - cli           [* -> 3.6.5]
#> - digest        [* -> 0.6.39]
#> - evaluate      [* -> 1.0.5]
#> - fastmap       [* -> 1.2.0]
#> - fontawesome   [* -> 0.5.3]
#> - fs            [* -> 1.6.6]
#> - glue          [* -> 1.8.0]
#> - highr         [* -> 0.11]
#> - htmltools     [* -> 0.5.8.1]
#> - jquerylib     [* -> 0.1.4]
#> - jsonlite      [* -> 2.0.0]
#> - knitr         [* -> 1.50]
#> - lifecycle     [* -> 1.0.4]
#> - memoise       [* -> 2.0.1]
#> - mime          [* -> 0.13]
#> - rappdirs      [* -> 0.3.3]
#> - renv          [* -> 1.1.5]
#> - rlang         [* -> 1.1.6]
#> - rmarkdown     [* -> 2.30]
#> - sass          [* -> 0.4.10]
#> - tinytex       [* -> 0.58]
#> - xfun          [* -> 0.54]
#> - yaml          [* -> 2.3.11]
#> 
#> The version of R recorded in the lockfile will be updated:
#> - R             [* -> 4.5.2]
#> 
#> - Lockfile written to "/tmp/RtmpMShUNW/file19323cb8fc4/renv/profiles/lesson-requirements/renv.lock".
#> ✔ Lesson successfully created in /tmp/RtmpMShUNW/file19323cb8fc4
#> → Creating Lesson in /tmp/RtmpMShUNW/file19323cb8fc4...
#> ☐ Edit /tmp/RtmpMShUNW/file19323cb8fc4/episodes/getting-started.md.
#> ☐ Edit /tmp/RtmpMShUNW/file19323cb8fc4/episodes/plotting.Rmd.
#> ☐ Edit /tmp/RtmpMShUNW/file19323cb8fc4/episodes/experimental.md.
#> episodes:
#> - introduction.Rmd
#> - getting-started.md
#> - plotting.Rmd
#> 
#> ────────────────────────────────────────────────────────────────────────
#> ℹ To save this configuration, use
#> 
#> move_episode(ep = "introduction.Rmd", position = 1, path = tmp, write = TRUE)
#> ℹ Files are in draft: episodes/experimental.md
#> ℹ All files in learners/ published (config.yaml empty)
#> ℹ All files in instructors/ published (config.yaml empty)
#> ℹ All files in profiles/ published (config.yaml empty)
#> episodes:
#> - introduction.Rmd
#> - experimental.md
#> - getting-started.md
#> - plotting.Rmd
#> 
#> ────────────────────────────────────────────────────────────────────────
#> ℹ To save this configuration, use
#> 
#> move_episode(ep = "experimental.md", position = 2, path = tmp, write = TRUE)
#> episodes:
#> - introduction.Rmd
#> - getting-started.md
#> - plotting.Rmd
#> 
#> ── Removed episodes ────────────────────────────────────────────────────
#> - experimental.md
#> ────────────────────────────────────────────────────────────────────────
#> ℹ To save this configuration, use
#> 
#> move_episode(ep = "experimental.md", position = 0, path = tmp, write = TRUE)
```
