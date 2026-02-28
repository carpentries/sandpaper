# Clear the schedule in the lesson

Clear the schedule in the lesson

## Usage

``` r
reset_episodes(path = ".")
```

## Arguments

- path:

  path to the lesson

## Value

NULL, invisibly

## Examples

``` r
tmp <- tempfile()
create_lesson(tmp, open = FALSE, rmd = FALSE)
#> → Creating Lesson in /tmp/Rtmp82VLs2/file1a91545a2819...
#> ℹ No schedule set, using Rmd files in episodes/ directory.
#> → Creating Lesson in /tmp/Rtmp82VLs2/file1a91545a2819...
#> → To remove this message, define your schedule in config.yaml or use `set_episodes()` to generate it.
#> → Creating Lesson in /tmp/Rtmp82VLs2/file1a91545a2819...
#> ────────────────────────────────────────────────────────────────────────
#> → Creating Lesson in /tmp/Rtmp82VLs2/file1a91545a2819...
#> ℹ To save this configuration, use
#> 
#> set_episodes(path = path, order = ep, write = TRUE)
#> → Creating Lesson in /tmp/Rtmp82VLs2/file1a91545a2819...
#> ☐ Edit /tmp/Rtmp82VLs2/file1a91545a2819/episodes/introduction.md.
#> → Creating Lesson in /tmp/Rtmp82VLs2/file1a91545a2819...
#> ✔ First episode created in /tmp/Rtmp82VLs2/file1a91545a2819/episodes/introduction.md
#> → Creating Lesson in /tmp/Rtmp82VLs2/file1a91545a2819...
#> ℹ Downloading workflows from https://api.github.com/repos/carpentries/workbench-workflows/releases/latest
#> → Creating Lesson in /tmp/Rtmp82VLs2/file1a91545a2819...
#> ℹ Workflows up-to-date!
#> → Creating Lesson in /tmp/Rtmp82VLs2/file1a91545a2819...
#> ✔ Lesson successfully created in /tmp/Rtmp82VLs2/file1a91545a2819
#> → Creating Lesson in /tmp/Rtmp82VLs2/file1a91545a2819...
#> /tmp/Rtmp82VLs2/file1a91545a2819
get_episodes(tmp) # produces warning
#> [1] "introduction.md"
set_episodes(tmp, get_episodes(tmp), write = TRUE)
get_episodes(tmp) # no warning
#> [1] "introduction.md"
reset_episodes(tmp)
get_episodes(tmp) # produces warning again because there is no schedule
#> ℹ No schedule set, using Rmd files in episodes/ directory.
#> → To remove this message, define your schedule in config.yaml or use `set_episodes()` to generate it.
#> [1] "introduction.md"
```
