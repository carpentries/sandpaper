# Create a carpentries lesson

This will create a boilerplate directory structure for a Carpentries
lesson and initialize a git repository.

## Usage

``` r
create_lesson(
  path,
  name = fs::path_file(path),
  rmd = TRUE,
  rstudio = rstudioapi::isAvailable(),
  open = rlang::is_interactive()
)
```

## Arguments

- path:

  the path to the new lesson folder

- name:

  the name of the lesson. If not provided, the folder name will be used.

- rmd:

  logical indicator if the lesson should use R Markdown (`TRUE`,
  default), or if it should use Markdown (`FALSE`). Note that lessons
  can be converted to use R Markdown at any time by adding a file with
  the `.Rmd` file extension in the lesson.

- rstudio:

  create an RStudio project (defaults to if RStudio exits)

- open:

  if interactive, the lesson will open in a new editor window.

## Value

the path to the new lesson

## Examples

``` r
tmp <- tempfile()
on.exit(unlink(tmp))
lsn <- create_lesson(tmp, name = "This Lesson", open = FALSE)
#> → Creating Lesson in /tmp/Rtmpw9vtxi/file1aa273ca71d...
#> ℹ No schedule set, using Rmd files in episodes/ directory.
#> → Creating Lesson in /tmp/Rtmpw9vtxi/file1aa273ca71d...
#> → To remove this message, define your schedule in config.yaml or use `set_episodes()` to generate it.
#> → Creating Lesson in /tmp/Rtmpw9vtxi/file1aa273ca71d...
#> ────────────────────────────────────────────────────────────────────────
#> → Creating Lesson in /tmp/Rtmpw9vtxi/file1aa273ca71d...
#> ℹ To save this configuration, use
#> 
#> set_episodes(path = path, order = ep, write = TRUE)
#> → Creating Lesson in /tmp/Rtmpw9vtxi/file1aa273ca71d...
#> ☐ Edit /tmp/Rtmpw9vtxi/file1aa273ca71d/episodes/introduction.Rmd.
#> → Creating Lesson in /tmp/Rtmpw9vtxi/file1aa273ca71d...
#> ✔ First episode created in /tmp/Rtmpw9vtxi/file1aa273ca71d/episodes/introduction.Rmd
#> → Creating Lesson in /tmp/Rtmpw9vtxi/file1aa273ca71d...
#> ℹ Using GitHub token for authenticated API request.
#> → Creating Lesson in /tmp/Rtmpw9vtxi/file1aa273ca71d...
#> ℹ Downloading workflows from https://api.github.com/repos/carpentries/workbench-workflows/releases/latest
#> → Creating Lesson in /tmp/Rtmpw9vtxi/file1aa273ca71d...
#> ℹ Workflows up-to-date!
#> → Creating Lesson in /tmp/Rtmpw9vtxi/file1aa273ca71d...
#> ℹ Consent to use package cache provided
#> → Creating Lesson in /tmp/Rtmpw9vtxi/file1aa273ca71d...
#> - The project is out-of-sync -- use `renv::status()` for details.
#> → Searching for and installing available dependencies
#> → Hydrating
#> The following packages were discovered:
#> 
#> # ~/work/_temp/Library -------------------------------------------------------
#> - R6            2.6.1
#> - base64enc     0.1-6
#> - bslib         0.10.0
#> - cachem        1.1.0
#> - cli           3.6.6
#> - digest        0.6.39
#> - evaluate      1.0.5
#> - fastmap       1.2.0
#> - fontawesome   0.5.3
#> - fs            2.0.1
#> - highr         0.12
#> - htmltools     0.5.9
#> - jquerylib     0.1.4
#> - jsonlite      2.0.0
#> - knitr         1.51
#> - lifecycle     1.0.5
#> - memoise       2.0.1
#> - mime          0.13
#> - rappdirs      0.3.4
#> - rlang         1.2.0
#> - rmarkdown     2.31
#> - sass          0.4.10
#> - tinytex       0.59
#> - xfun          0.57
#> - yaml          2.3.12
#> 
#> They will be copied into the project library.
#> 
#> - Copying packages into the project library ... Done!
#> - Hydrated 25 packages in 0.17 seconds.
#> - The project is out-of-sync -- use `renv::status()` for details.
#> → Recording changes in lockfile
#> The following package(s) will be updated in the lockfile:
#> 
#> # https://packagemanager.posit.co/cran/__linux__/noble/latest ----------------
#> - R6            [* -> 2.6.1]
#> - base64enc     [* -> 0.1-6]
#> - bslib         [* -> 0.10.0]
#> - cachem        [* -> 1.1.0]
#> - cli           [* -> 3.6.6]
#> - digest        [* -> 0.6.39]
#> - evaluate      [* -> 1.0.5]
#> - fastmap       [* -> 1.2.0]
#> - fontawesome   [* -> 0.5.3]
#> - fs            [* -> 2.0.1]
#> - highr         [* -> 0.12]
#> - htmltools     [* -> 0.5.9]
#> - jquerylib     [* -> 0.1.4]
#> - jsonlite      [* -> 2.0.0]
#> - knitr         [* -> 1.51]
#> - lifecycle     [* -> 1.0.5]
#> - memoise       [* -> 2.0.1]
#> - mime          [* -> 0.13]
#> - rappdirs      [* -> 0.3.4]
#> - renv          [* -> 1.2.1]
#> - rlang         [* -> 1.2.0]
#> - rmarkdown     [* -> 2.31]
#> - sass          [* -> 0.4.10]
#> - tinytex       [* -> 0.59]
#> - xfun          [* -> 0.57]
#> - yaml          [* -> 2.3.12]
#> 
#> The version of R recorded in the lockfile will be updated:
#> - R             [* -> 4.5.3]
#> 
#> - Lockfile written to "/tmp/Rtmpw9vtxi/file1aa273ca71d/renv/profiles/lesson-requirements/renv.lock".
#> ✔ Lesson successfully created in /tmp/Rtmpw9vtxi/file1aa273ca71d
#> → Creating Lesson in /tmp/Rtmpw9vtxi/file1aa273ca71d...
lsn
#> /tmp/Rtmpw9vtxi/file1aa273ca71d
```
