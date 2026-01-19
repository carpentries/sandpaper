# Internal cache for storing pre-computed lesson objects

A storage cache for
[pegboard::Lesson](https://carpentries.github.io/pegboard/reference/Lesson.html)
objects and other pre-computed items for use by other internal functions
while `{sandpaper}` is working.

## Usage

``` r
this_lesson(path)

clear_this_lesson()

set_this_lesson(path)

set_resource_list(path)

clear_resource_list(path)
```

## Arguments

- path:

  a path to the current lesson

## Lesson Object Storage

`this_lesson()` will return a
[pegboard::Lesson](https://carpentries.github.io/pegboard/reference/Lesson.html)
object if it has previously been stored. There are three values that are
cached:

- `.this_lesson` a
  [pegboard::Lesson](https://carpentries.github.io/pegboard/reference/Lesson.html)
  object

- `.this_diff` a charcter vector from
  [`gert::git_diff_patch()`](https://docs.ropensci.org/gert/reference/git_diff.html)

- `.this_status` a data frame from
  [`gert::git_status()`](https://docs.ropensci.org/gert/reference/git_commit.html)

- `.this_commit` the hash of the most recent commit

The function `this_lesson()` first checks if `.this_diff` is different
than the output of
[`gert::git_diff_patch()`](https://docs.ropensci.org/gert/reference/git_diff.html),
then checks if there are any changes to
[`gert::git_status()`](https://docs.ropensci.org/gert/reference/git_commit.html),
and then finally checks if the commits are identical. If there are
differences or the values are not previously cached, the lesson is
loaded into memory, otherwise, it is fetched from the previously stored
lesson.

The storage cache is in a global package object called `.store`, which
is initialised when `{sandpaper}` is loaded via
[`.lesson_store()`](https://carpentries.github.io/sandpaper/reference/dot-lesson_store.md)

If there have been no changes git is aware of, the lesson remains the
same.

## Pre-Computed Object Storage

A side-effect of `this_lesson()` is that it will also initialise
pre-computed objects that pertain to the lesson itself. These are
initialised via
[`set_globals()`](https://carpentries.github.io/sandpaper/reference/set_globals.md).
These storage objects are:

- `.resources`: a list of markdown resources for the lesson derived from
  [`get_resource_list()`](https://carpentries.github.io/sandpaper/reference/get_resource_list.md)
  via `set_resource_list()`

- `this_metadata`: metadata with template for including in the pages.
  initialised in `initialise_metadata()` via
  [`set_globals()`](https://carpentries.github.io/sandpaper/reference/set_globals.md)

- `learner_globals`: variables for the learner version of the pages
  initialised in
  [`set_globals()`](https://carpentries.github.io/sandpaper/reference/set_globals.md)

- `instructor_globals`: variables for the instructor version of the
  pages initialised in
  [`set_globals()`](https://carpentries.github.io/sandpaper/reference/set_globals.md)

## Examples

``` r
tmp <- tempfile()
create_lesson(tmp, open = FALSE, rmd = FALSE)
#> → Creating Lesson in /tmp/Rtmph9vhkW/file1bff310151f7...
#> ℹ No schedule set, using Rmd files in episodes/ directory.
#> → Creating Lesson in /tmp/Rtmph9vhkW/file1bff310151f7...
#> → To remove this message, define your schedule in config.yaml or use `set_episodes()` to generate it.
#> → Creating Lesson in /tmp/Rtmph9vhkW/file1bff310151f7...
#> ────────────────────────────────────────────────────────────────────────
#> → Creating Lesson in /tmp/Rtmph9vhkW/file1bff310151f7...
#> ℹ To save this configuration, use
#> 
#> set_episodes(path = path, order = ep, write = TRUE)
#> → Creating Lesson in /tmp/Rtmph9vhkW/file1bff310151f7...
#> ☐ Edit /tmp/Rtmph9vhkW/file1bff310151f7/episodes/introduction.md.
#> → Creating Lesson in /tmp/Rtmph9vhkW/file1bff310151f7...
#> ✔ First episode created in /tmp/Rtmph9vhkW/file1bff310151f7/episodes/introduction.md
#> → Creating Lesson in /tmp/Rtmph9vhkW/file1bff310151f7...
#> ℹ Workflows up-to-date!
#> → Creating Lesson in /tmp/Rtmph9vhkW/file1bff310151f7...
#> ✔ Lesson successfully created in /tmp/Rtmph9vhkW/file1bff310151f7
#> → Creating Lesson in /tmp/Rtmph9vhkW/file1bff310151f7...
#> /tmp/Rtmph9vhkW/file1bff310151f7
# Read the lesson into cache
system.time(sandpaper:::this_lesson(tmp))
#>    user  system elapsed 
#>   0.160   0.008   0.168 
system.time(sandpaper:::this_lesson(tmp)) # less time to read in once cached
#>    user  system elapsed 
#>   0.002   0.002   0.003 
l <- sandpaper:::this_lesson(tmp)
l
#> <Lesson>
#>   Public:
#>     blocks: function (type = NULL, level = 0, path = FALSE) 
#>     built: NULL
#>     challenges: function (path = FALSE, graph = FALSE, recurse = TRUE) 
#>     children: NULL
#>     clone: function (deep = FALSE) 
#>     episodes: list
#>     extra: list
#>     files: active binding
#>     get: function (element = NULL, collection = "episodes") 
#>     handout: function (path = NULL, solution = FALSE) 
#>     has_children: active binding
#>     initialize: function (path = ".", rmd = FALSE, jekyll = TRUE, ...) 
#>     isolate_blocks: function () 
#>     load_built: function () 
#>     n_problems: active binding
#>     overview: FALSE
#>     path: /tmp/Rtmph9vhkW/file1bff310151f7
#>     reset: function () 
#>     rmd: FALSE
#>     sandpaper: TRUE
#>     show_problems: active binding
#>     solutions: function (path = FALSE) 
#>     summary: function (collection = "episodes") 
#>     thin: function (verbose = TRUE) 
#>     trace_lineage: function (episode_path) 
#>     validate_divs: function () 
#>     validate_headings: function (verbose = TRUE) 
#>     validate_links: function () 
#>   Private:
#>     deep_clone: function (name, value) 
# clear the cache
sandpaper:::clear_this_lesson()
system.time(sandpaper:::this_lesson(tmp)) # have to re-read the lesson
#>    user  system elapsed 
#>   0.147   0.006   0.152 
system.time(sandpaper:::this_lesson(tmp))
#>    user  system elapsed 
#>   0.003   0.000   0.003 
unlink(tmp)
```
