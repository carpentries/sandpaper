# Internal Global Lesson Storage Generator

This function will generate an object store that will contain and update
a lesson object based on the status of the git repository

## Usage

``` r
.lesson_store()
```

## Value

a list with four functions that operate on a supplied path string

- [`get()`](https://rdrr.io/r/base/get.html) returns `.this_lesson` (as
  described in
  [`this_lesson()`](https://carpentries.github.io/sandpaper/dev/reference/lesson_storage.md))

- `set(path)` sets `.this_lesson` and its git statuses from the lesson
  in `path`. This also sets
  [`set_globals()`](https://carpentries.github.io/sandpaper/dev/reference/set_globals.md)
  and
  [`set_resource_list()`](https://carpentries.github.io/sandpaper/dev/reference/lesson_storage.md).

- `valid(path)` uses `path` to validate if a lesson is identical to the
  stored lesson from its git status. Returns `TRUE` if it is identical
  and `FALSE` if it is not

- `clear()` resets all global variables.

## See also

[`.list_store()`](https://carpentries.github.io/sandpaper/dev/reference/dot-list_store.md)
for a generic list implementation and
[`this_lesson()`](https://carpentries.github.io/sandpaper/dev/reference/lesson_storage.md)
for details of the implementation of this generator in sandpaper
