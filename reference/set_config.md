# Set individual keys in a configuration file

Set individual keys in a configuration file

## Usage

``` r
set_config(pairs = NULL, create = FALSE, path = ".", write = FALSE)
```

## Arguments

- pairs:

  a named list or character vector with keys as the names and the new
  values as the contents

- create:

  if `TRUE`, any new values in `pairs` will be created and appended;
  defaults to `FALSE`, which prevents typos from sneaking in. single
  key-pair values currently supported.

- path:

  path to the lesson. Defaults to the current directory.

- write:

  if `TRUE`, the schedule will overwrite the schedule in the current
  file.

## Details

This function deals strictly with keypairs in the yaml. For lists, see
[`set_dropdown()`](https://carpentries.github.io/sandpaper/reference/set_dropdown.md).

### Default Keypairs Known by Sandpaper

When you create a new lesson in sandpaper, there are a set of default
keypairs that are pre-filled. To make sure contact information and links
in the footer are accurate, please modify these values.

- **carpentry** `[character]` one of cp, dc, swc, lab, incubator

- **title** `[character]` the lesson title (e.g.
  `'Introduction to R for Plant Pathologists'`

- **created** `[character]` Date in ISO 8601 format (e.g.
  `'2021-02-09'`)

- **keywords** `[character]` comma-separated list (e.g
  `'static site, R, tidyverse'`)

- **life_cycle** `[character]` one of pre-alpha, alpha, beta, stable

- **license** `[character]` a license for the lesson (e.g.
  `'CC-BY 4.0'`)

- **source** `[character]` the source repository URL

- **branch** `[character]` the default branch (e.g. `'main'`)

- **contact** `[character]` an email address of who to contact for more
  information about the lesson

### Optional Keypairs Known by Sandpaper

The following keypairs are known by sandpaper, but are optional:

- **lang** `[character]` the [language
  code](https://www.gnu.org/software/gettext/manual/html_node/Usual-Language-Codes.html)
  that matches the language of the lesson content. This defaults to
  `"en"`, but can be any language code (e.g. "ja" specifying Japanese)
  or combination language code and [country
  code](https://www.gnu.org/software/gettext/manual/html_node/Country-Codes.html)
  (e.g. "pt_BR" specifies Pourtugese used in Brazil). For more
  information on how this is used, see [the Locale Names section of the
  gettext
  manual](https://www.gnu.org/software/gettext/manual/html_node/Locale-Names.html)

- **url** `[character]` custom URL if you are deploying to a URL that is
  not the default github pages io domain.

- **fail_on_error** `[boolean]` for R Markdown lessons; fail the build
  if any chunks produce an error. Use `#| error: true` in chunk options
  to allow the error to be displayed

- **workbench-beta** `[boolean]` if truthy, this displays a banner on
  the site that indicates the site is in the workbench beta phase.

- **overview** `[boolean]` All lessons must have episodes with the
  exception of overview lessons. To indicate that your lesson serves as
  an overview for other lessons, use `overview: true`

- **handout** `[boolean]` or `[character]` This option instructs
  `{sandpaper}` to create a handout of all RMarkdown files via
  `{pegboard}`, which uses
  [`knitr::purl()`](https://rdrr.io/pkg/knitr/man/knit.html) in the
  background after removing everything but the challenges (without
  solutions) and any code blocks where `purl = TRUE`. The default path
  for the handout is `files/code-handout.R`

As the workbench becomes more developed, some of these optional keys may
disappear.

#### Custom Engines

To use a specific version of sandpaper or varnish locally, you would
install them using
`remotes::install_github("carpentries/sandpaper@VERSION")` syntax, but
to provision these versions on GitHub, you can provision these in the
`config.yaml` file:

- **sandpaper** `[character]` github string or version number of
  sandpaper version to use

- **varnish** `[character]` github string or version number of varnish
  version to use

- **pegboard** `[character]` github string or version number of pegboard
  version to use

For example, if you had forked your own version of varnish to modify the
colourscheme, you could use:

    varnish: MYACCOUNT/varnish

If there is a specific branch of sandpaper or varnish that is being
tested, and you want to test it on your lesson temporarily, you could
use the `@` symbol to refer to the specific branch or commit to use:

    sandpaper: carpentries/sandpaper@BRANCH-NAME
    varnish: carpentries/varnish@BRANCH-name

## Examples

``` r
if (FALSE) {
tmp <- tempfile()
create_lesson(tmp, "test lesson", open = FALSE, rmd = FALSE)
# Change the title and License (default vars)
set_config(c(title = "Absolutely Free Lesson", license = "CC0"),
  path = tmp,
  write = TRUE
)

# add the URL and workbench-beta indicator
set_config(list("workbench-beta" = TRUE, url = "https://example.com/"),
  path = tmp,
  create = TRUE,
  write = TRUE
)
}
```
