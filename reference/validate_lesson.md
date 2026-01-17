# Pre-build validation of lesson elements

A validator based on the
[pegboard::Lesson](https://carpentries.github.io/pegboard/reference/Lesson.html)
class cached with
[`this_lesson()`](https://carpentries.github.io/sandpaper/reference/lesson_storage.md)
that will provide line reports for fenced divs, links, images, and
heading structure. For details on the type of validators avaliable, see
the `{pegboard}` article [Validation of Lesson
Elements](https://carpentries.github.io/pegboard/articles/validation.html)

## Usage

``` r
validate_lesson(path = ".", headings = FALSE, quiet = FALSE)
```

## Arguments

- path:

  the path to the lesson. Defaults ot the current directory

- headings:

  If `TRUE`, headings will be checked and validated. Currently set to
  `FALSE` as we are re-investigating some false positives.

- quiet:

  if `TRUE`, no messages will be issued, otherwise progress messages
  will be issued for each test

## Value

a list with the results for each test as described in
[pegboard::Lesson](https://carpentries.github.io/pegboard/reference/Lesson.html)

## Details

### Headings

We expect the headings to be semantic and informative. Details of the
tests for headings can be found at
[`pegboard::validate_headings()`](https://carpentries.github.io/pegboard/reference/validate_headings.html)

### Internal Links and Images

Internal links and images should exist and images should have alt text.
Details for these tests can be found at
[`pegboard::validate_links()`](https://carpentries.github.io/pegboard/reference/validate_links.html)

### Fenced Divs (callout blocks)

Callout Blocks should be one of the expected types. Details for this
test can be found at
[`pegboard::validate_divs()`](https://carpentries.github.io/pegboard/reference/validate_divs.html)

## Examples

``` r
tmp <- tempfile()
lsn <- create_lesson(tmp, open = FALSE)
#> → Creating Lesson in /tmp/Rtmpfmukg6/file1bf333007bd7...
#> ℹ No schedule set, using Rmd files in episodes/ directory.
#> → Creating Lesson in /tmp/Rtmpfmukg6/file1bf333007bd7...
#> → To remove this message, define your schedule in config.yaml or use `set_episodes()` to generate it.
#> → Creating Lesson in /tmp/Rtmpfmukg6/file1bf333007bd7...
#> ────────────────────────────────────────────────────────────────────────
#> → Creating Lesson in /tmp/Rtmpfmukg6/file1bf333007bd7...
#> ℹ To save this configuration, use
#> 
#> set_episodes(path = path, order = ep, write = TRUE)
#> → Creating Lesson in /tmp/Rtmpfmukg6/file1bf333007bd7...
#> ☐ Edit /tmp/Rtmpfmukg6/file1bf333007bd7/episodes/introduction.Rmd.
#> → Creating Lesson in /tmp/Rtmpfmukg6/file1bf333007bd7...
#> ✔ First episode created in /tmp/Rtmpfmukg6/file1bf333007bd7/episodes/introduction.Rmd
#> → Creating Lesson in /tmp/Rtmpfmukg6/file1bf333007bd7...
#> ℹ Workflows up-to-date!
#> → Creating Lesson in /tmp/Rtmpfmukg6/file1bf333007bd7...
#> ℹ Consent to use package cache provided
#> → Creating Lesson in /tmp/Rtmpfmukg6/file1bf333007bd7...
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
#> - highr         0.11
#> - htmltools     0.5.9
#> - jquerylib     0.1.4
#> - jsonlite      2.0.0
#> - knitr         1.51
#> - lifecycle     1.0.5
#> - memoise       2.0.1
#> - mime          0.13
#> - rappdirs      0.3.3
#> - rlang         1.1.7
#> - rmarkdown     2.30
#> - sass          0.4.10
#> - tinytex       0.58
#> - xfun          0.55
#> - yaml          2.3.12
#> 
#> They will be copied into the project library.
#> 
#> - Copying packages into the project library ... Done!
#> - Hydrated 25 packages in 0.18 seconds.
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
#> - highr         [* -> 0.11]
#> - htmltools     [* -> 0.5.9]
#> - jquerylib     [* -> 0.1.4]
#> - jsonlite      [* -> 2.0.0]
#> - knitr         [* -> 1.51]
#> - lifecycle     [* -> 1.0.5]
#> - memoise       [* -> 2.0.1]
#> - mime          [* -> 0.13]
#> - rappdirs      [* -> 0.3.3]
#> - renv          [* -> 1.1.6]
#> - rlang         [* -> 1.1.7]
#> - rmarkdown     [* -> 2.30]
#> - sass          [* -> 0.4.10]
#> - tinytex       [* -> 0.58]
#> - xfun          [* -> 0.55]
#> - yaml          [* -> 2.3.12]
#> 
#> The version of R recorded in the lockfile will be updated:
#> - R             [* -> 4.5.2]
#> 
#> - Lockfile written to "/tmp/Rtmpfmukg6/file1bf333007bd7/renv/profiles/lesson-requirements/renv.lock".
#> ✔ Lesson successfully created in /tmp/Rtmpfmukg6/file1bf333007bd7
#> → Creating Lesson in /tmp/Rtmpfmukg6/file1bf333007bd7...
validate_lesson(lsn, headings = TRUE)
#> ── Validating Headings ─────────────────────────────────────────────────
#> ── Validating Fenced Divs ──────────────────────────────────────────────
#> ── Validating Internal Links and Images ────────────────────────────────
```
