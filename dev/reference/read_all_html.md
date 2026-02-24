# read all HTML files in a folder

read all HTML files in a folder

## Usage

``` r
read_all_html(path)
```

## Arguments

- path:

  the path to a folder with HTML files

## Value

a nested list of `html_documents` from
[`xml2::read_html()`](http://xml2.r-lib.org/reference/read_xml.md) with
two top-level elements:

- `$learner`: contains all of the html pages in the learner view

- `$instructor`: all of the pages in the instructor view

- `$paths`: the absolute paths for the pages

## Examples

``` r
tmpdir <- tempfile()
on.exit(fs::dir_delete(tmpdir))
#> Error: [ENOENT] Failed to search directory '/tmp/Rtmp3i6gqa/file1c883fc17503': no such file or directory
fs::dir_create(tmpdir)
fs::dir_create(fs::path(tmpdir, "instructor"))
writeLines("<p>Instructor</p>", fs::path(tmpdir, "instructor", "index.html"))
writeLines("<p>Learner</p>", fs::path(tmpdir, "index.html"))
sandpaper:::read_all_html(tmpdir)
#> $instructor
#> $instructor$index
#> {html_document}
#> <html>
#> [1] <body><p>Instructor</p></body>
#> 
#> 
#> $learner
#> $learner$index
#> {html_document}
#> <html>
#> [1] <body><p>Learner</p></body>
#> 
#> 
#> $paths
#> /tmp/Rtmp3i6gqa/file1c883fc17503/index.html
#> /tmp/Rtmp3i6gqa/file1c883fc17503/instructor/index.html
#> 
```
