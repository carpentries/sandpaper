# Create an Episode from a template

These functions allow you to create an episode that will be added to the
schedule.

## Usage

``` r
create_episode(
  title,
  ext = "Rmd",
  make_prefix = FALSE,
  add = TRUE,
  path = ".",
  open = rlang::is_interactive()
)

create_episode_md(
  title,
  make_prefix = FALSE,
  add = TRUE,
  path = ".",
  open = rlang::is_interactive()
)

create_episode_rmd(
  title,
  make_prefix = FALSE,
  add = TRUE,
  path = ".",
  open = rlang::is_interactive()
)

draft_episode_md(
  title,
  make_prefix = FALSE,
  path = ".",
  open = rlang::is_interactive()
)

draft_episode_rmd(
  title,
  make_prefix = FALSE,
  path = ".",
  open = rlang::is_interactive()
)
```

## Arguments

- title:

  the title of the episode

- ext:

  a character. If `ext = "Rmd"` (default), then the new episode will be
  an R Markdown episode. If `ext = "md"`, then the new episode will be a
  markdown episode, which can not generate dynamic content.

- make_prefix:

  a logical. When `TRUE`, the prefix for the file will be automatically
  determined by the files already present. When `FALSE` (default), it
  assumes no prefix is needed.

- add:

  (logical or numeric) If numeric, it represents the position the
  episode should be added. If `TRUE`, the episode is added to the end of
  the schedule. If `FALSE`, the episode is added as a draft episode.

- path:

  the path to the `{sandpaper}` lesson.

- open:

  if interactive, the episode will open in a new editor window.

## Examples

``` r
tmp <- tempfile()
create_lesson(tmp, open = FALSE, rmd = FALSE)
#> → Creating Lesson in /tmp/RtmpcTm5wz/file1c013afbbaec...
#> ℹ No schedule set, using Rmd files in episodes/ directory.
#> → Creating Lesson in /tmp/RtmpcTm5wz/file1c013afbbaec...
#> → To remove this message, define your schedule in config.yaml or use `set_episodes()` to generate it.
#> → Creating Lesson in /tmp/RtmpcTm5wz/file1c013afbbaec...
#> ────────────────────────────────────────────────────────────────────────
#> → Creating Lesson in /tmp/RtmpcTm5wz/file1c013afbbaec...
#> ℹ To save this configuration, use
#> 
#> set_episodes(path = path, order = ep, write = TRUE)
#> → Creating Lesson in /tmp/RtmpcTm5wz/file1c013afbbaec...
#> ☐ Edit /tmp/RtmpcTm5wz/file1c013afbbaec/episodes/introduction.md.
#> → Creating Lesson in /tmp/RtmpcTm5wz/file1c013afbbaec...
#> ✔ First episode created in /tmp/RtmpcTm5wz/file1c013afbbaec/episodes/introduction.md
#> → Creating Lesson in /tmp/RtmpcTm5wz/file1c013afbbaec...
#> ℹ Workflows up-to-date!
#> → Creating Lesson in /tmp/RtmpcTm5wz/file1c013afbbaec...
#> ✔ Lesson successfully created in /tmp/RtmpcTm5wz/file1c013afbbaec
#> → Creating Lesson in /tmp/RtmpcTm5wz/file1c013afbbaec...
#> /tmp/RtmpcTm5wz/file1c013afbbaec
create_episode_md("getting-started", path = tmp)
#> ☐ Edit /tmp/RtmpcTm5wz/file1c013afbbaec/episodes/getting-started.md.
#> /tmp/RtmpcTm5wz/file1c013afbbaec/episodes/getting-started.md
```
