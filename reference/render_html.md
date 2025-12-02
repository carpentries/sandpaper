# Render html from a markdown file

This uses
[`rmarkdown::pandoc_convert()`](https://pkgs.rstudio.com/rmarkdown/reference/pandoc_convert.html)
to render HTML from a markdown file. We've specified pandoc extensions
that align with the features desired in the Carpentries such as
`markdown_in_html_blocks`, `tex_math_dollars`, and `native_divs`.

## Usage

``` r
render_html(path_in, ..., quiet = FALSE, glosario = NULL)
```

## Arguments

- path_in:

  path to a markdown file

- ...:

  extra options (e.g. lua filters) to be passed to pandoc

- quiet:

  if `TRUE`, no output is produced. Default is `FALSE`, which reports
  the markdown build via pandoc

- glosario:

  a named list of glosario terms and definitions. Defaults to NULL.

## Value

a character containing the rendred HTML file

## Examples

``` r
if (rmarkdown::pandoc_available("2.11")) {
# first example---markdown to HTML
tmp <- tempfile()
ex <- c("# Markdown",
  "",
  "::: challenge",
  "",
  "How do you write markdown divs?",
  "",
  ":::"
)
writeLines(ex, tmp)
cat(sandpaper:::render_html(tmp))

# adding a lua filter

lua <- tempfile()
lu <- c("Str = function (elem)",
"  if elem.text == 'markdown' then",
"    return pandoc.Emph {pandoc.Str 'mowdrank'}",
"  end",
"end")
writeLines(lu, lua)
lf <- paste0("--lua-filter=", lua)
cat(sandpaper:::render_html(tmp, lf))
}
#> <div id="markdown" class="section level1">
#> <h1>Markdown</h1>
#> <div id="discussion1" class="callout discussion">
#> <div class="callout-square">
#> <i class='callout-icon' data-feather='message-circle'></i>
#> </div>
#> <span class='callout-header'>Discussion</span>
#> <div class="section level3 callout-title callout-inner">
#> <h3 class="callout-title">Challenge</h3>
#> <div class="callout-content">
#> <p>How do you write markdown divs?</p>
#> </div>
#> </div>
#> </div>
#> </div><div id="markdown" class="section level1">
#> <h1>Markdown</h1>
#> <div id="discussion1" class="callout discussion">
#> <div class="callout-square">
#> <i class='callout-icon' data-feather='message-circle'></i>
#> </div>
#> <span class='callout-header'>Discussion</span>
#> <div class="section level3 callout-title callout-inner">
#> <h3 class="callout-title">Challenge</h3>
#> <div class="callout-content">
#> <p>How do you write <em>mowdrank</em> divs?</p>
#> </div>
#> </div>
#> </div>
#> </div>
```
