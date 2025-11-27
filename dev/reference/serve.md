# Build your lesson and work on it at the same time

This function will serve your lesson and it will auto-update whenever
you save a file.

## Usage

``` r
serve(path = ".", quiet = !interactive(), ...)
```

## Arguments

- path:

  the path to your lesson. Defaults to the current path.

- quiet:

  if `TRUE`, then no messages are printed to the output. Defaults to
  `FALSE` in non-interactive sessions, which allows messages to be
  printed.

- ...:

  options passed on to
  [`servr::server_config()`](https://rdrr.io/pkg/servr/man/server_config.html)
  by way of [`servr::httw()`](https://rdrr.io/pkg/servr/man/httd.html).
  These can include **port** and **host** configuration.

## Value

the output of
[`servr::httw()`](https://rdrr.io/pkg/servr/man/httd.html), invisibly.
This is mainly used for its side-effect

## Details

`sandpaper::serve()` is an entry point to working on any lesson using
The Carpentries Workbench. When you run this function interactively, a
preview window will open either in RStudio or your browser with an
address like `localhost:4321` (note the number will likely be
different). When you make changes to files in your lesson, this preview
will update automatically.

When you are done with the preview, you can run
[`servr::daemon_stop()`](https://rdrr.io/pkg/servr/man/daemon_stop.html).

### Command line usage

You can use this on the command line if you do not use RStudio or
another IDE that acts as a web browser. To run this on the command line,
use:

    R -e 'sandpaper::serve()'

Note that unlike an interactive session, progress messages are not
printed (except for the accessibility checks) and the browser window
will not automatically launch. You can have these messages print to
screen with the `quiet = FALSE` argument. In addition, If you want to
specify a port and host for this function, you can do so using the port
and host arguments:

    R -e 'sandpaper::serve(quiet = FALSE, host = "127.0.0.1", port = "3435")'

## See also

[`build_lesson()`](https://carpentries.github.io/sandpaper/dev/reference/build_lesson.md),
render the lesson once, locally.

## Examples

``` r
if (FALSE) {
  # create an example lesson
  tmp <- tempfile()
  create_lesson(tmp, open = FALSE)

  # open the episode for editing
  file.edit(fs::path(tmp, "episodes", "01-introduction.Rmd"))

  # serve the lesson and begin editing the file. Watch how the file will
  # auto-update whenever you save it.
  sandpaper::serve()
  #
  # to stop the server, run
  servr::daemon_stop()
  #
  # If you want to use a different port, you can specify it directly
  sandpaper::serve(host = "127.0.0.1", port = "3435")
}
```
