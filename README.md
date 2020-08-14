
<!-- README.md is generated from README.Rmd. Please edit that file -->

# sandpaper

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/sandpaper)](https://CRAN.R-project.org/package=sandpaper)
[![R build
status](https://github.com/zkamvar/sandpaper/workflows/R-CMD-check/badge.svg)](https://github.com/zkamvar/sandpaper/actions)
[![Codecov test
coverage](https://codecov.io/gh/zkamvar/sandpaper/branch/master/graph/badge.svg)](https://codecov.io/gh/zkamvar/sandpaper?branch=master)
<!-- badges: end -->

The {sandpaper} package was created by [The
Carpentries](https://carpentries.org) to re-imagine our method of
creating lesson websites for our workshops. This package will take a
series of [Markdown](https://daringfireball.net/projects/markdown/) or
[RMarkdown](https://rmarkdown.rstudio.com/) files and generate a static
website with the features and styling of The Carpentries lessons
including customized layouts and callout blocks. Much of the
functionality in this package is inspired by [Jenny
Bryan’s](https://jennybryan.org/) work with the
[{usethis}](https://usethis.r-lib.org/) package.

-----

> Please note: {sandpaper} is very much a work in progress. At the
> moment, the only thing that is real is the README to serve as a
> roadmap for the future. Please [open an
> issue](https://github.com/zkamvar/sandpaper/issues/new) if you have
> any comments or suggestions\!

-----

## Installation

{sandpaper} is not currently on CRAN, but it can be installed from
github via the [{remotes}](https://remotes.r-lib.org/) package:

``` r
# install.packages("remotes")
remotes::install_github("zkamvar/sandpaper", dep = TRUE)
```

Note that this will also install development versions of the following
packages:

| package                                                          | What it does                                                              |
| ---------------------------------------------------------------- | ------------------------------------------------------------------------- |
| [{varnish}](https://github.com/zkamvar/varnish#readme)           | html, css, and javascript templates for The Carpentries (in progress)     |
| \[{dovetail}\]                                                   | drop-in knitr engine for parsing challenge/solution blocks                |
| [{gert}](https://github.com/r-lib/gert#readme)                   | a “batteries included” git interface for R                                |
| [{testthat}](https://github.com/r-lib/testthat#readme) version 3 | runs tests for the package. If you aren’t developing, you shouldn’t worry |

## Design

This package is designed to make the life of the lesson contributors and
maintainers easier by separating the tools needed to build the site from
the user-defined content of the site itself. It will no longer rely on
Jekyll or any of the other [\>450 static site
generators](https://staticsitegenerators.net), but instead rely on R,
RStudio, and [{pkgdown}](https://pkgdown.r-lib.org/) to generate a site
with the following features:

  - optional offline use
  - lesson versioning (e.g. I can navigate to
    <https://swcarpentry.github.io/python-novice-gapminder> for the
    current version and
    <https://swcarpentry.github.io/python-novice-gapminder/2020-11> for
    the release in 2020-11)
  - seamless updates to the Carpentries’ style
  - caching of rendered content for rapid deployment
  - packaging of [{learnr}](https://rstudio.github.io/learnr/index.html)
    materials
  - validation of lesson structure
  - git aware, but does not require contributors to have git installed

### Rendering locally

In a repository generated via {sandpaper}, only the source is committed
to avoid issues surrounding out-of-date artefacts and directory
structure confusion.

The website is generated in two steps:

1.  markdown files from the source files are rendered containing a hash
    for the source file so that these need only be re-rendered when they
    change.
2.  html files are generated from the rendered markdown files and the
    CSS and JS sources in the {sandpaper} package for the preview.

To ensure there are no clashes between minor differences in the user
setup, no artifacts are committed to the main branch of the repository.
Because of the caching mechanism between the website and the rendered
markdown files, long-running lessons can be updated and previewed
quickly.

### Rendering on continuous integration

Continuous integration will act as the single source-of-truth for how
the outputs of the lessons are rendered. For this, we want the resulting
website to be:

  - CI agnostic (but currently set up with GitHub)
  - easy to set up
  - auditable (e.g. I can see changes between the content of two
    commits)
  - versionable (e.g. I can instruct learners to go to `<WEBSITE>/1.1`.
    This is inspired from the python documentation style)

To acheive this, there will be two branches created: `md-outputs` and
`gh-pages` that will inerit like so main -\> `md-outputs` -\>
`gh-pages`. Because the build time from main to `md-outputs` can be time
intensive, this will default to updating only files that were changed.

  - `md-outputs`: this branch will contain the files and artifacts
    generated from rmarkdown in the vignettes directory of a thin
    package skeleton.
  - `gh-pages`: this branch is generated via `md-outputs` and bundles
    the html, css, and js for the website. This will contain a single
    `index.html` file with several subfolders with different versions of
    the site. The `index.html` file will redirect to the `current/`
    directory, which contains the up-to-date site.

> I believe that management of these can be done via `git worktree`, but
> I still need to dig into the mechanics of pkgdown further.

### Function syntax

The functions in {sandpaper} have the following prefixes:

  - `create_` will create/amend files or folders in your workspace
  - `build_` will build files from your source
  - `check_` validates either the elements of the lesson and/or episodes
  - `fetch_` will download files or resources from the internet
  - `get_` will retrieve information from your source files as an R
    object
  - `ci_` interacts with continous integration to build the website

Here is a working list of user-facing functions:

**Lesson and Episode Creation**

  - `create_lesson()` creates a lesson from scratch
  - `create_episode()` creates a new episode with the correct number
    prefix
  - `create_dataset()` creates a csv or text data set from an R object

**Website Creation and Validation**

  - `check_lesson()` checks and validates the source files and lesson
    structure
  - `build_lesson()` builds the lesson into a static website
  - `build_portable_lesson()` builds the lesson into a portable static
    website
  - `fetch_lesson()` fetches the static website from the lesson
    repository
  - `get_episode()` reads in an episode as an XML object

**Continuous Integration Utilities**

  - `ci_deploy()` builds and deploys the lesson on CI from the source
    files
  - `ci_deploy_site()` deploys the lesson on CI from pre-rendered
    markdown files
  - `ci_release()` builds and deploys the lesson on CI from the source
    files and adds a release tag

## Usage

There are five use-cases for {sandpaper}:

1.  Creating lessons
2.  Contributing to lessons
3.  Maintaining lessons
4.  Rendering a portable site
5.  Rendering a site with GitHub actions.

### Creating a lesson

To create a lesson with {sandpaper}, use the `create_lesson()` function:

``` r
sandpaper::create_lesson("~/Desktop/r-intermediate-penguins")
```

This will create folder on your desktop called `r-intermediate-penguins`
with the following structure:

    |-- .gitignore               # - Ignore everything in the site/ folder
    |-- .github/                 # 
    |   `-- workflows/           #
    |       `-- workshop.yaml    # - Automatically build the source files on github pages
    |-- episodes/                # - PUT YOUR MARKDOWN FILES IN THIS FOLDER
    |   |-- data/                # - Data for your lesson goes here
    |   |-- extras/              # - Supplemental lesson material goes here
    |   |-- figures/             # - All static figures and diagrams are here
    |   |-- files/               # - Additional files (e.g. handouts) 
    |   `-- 00-introducition.Rmd # - Lessons start with a two-digit number
    |-- site/                    # - This folder is where the rendered markdown files and static site will live
    |   `-- README.md            #
    |-- config.yaml              # - Use this to configure commonly used variables
    |-- CODE_OF_CONDUCT.md       # - Carpentries Code of Conduct (REQUIRED)
    `-- README.md                # - Use this to tell folks how to contribute

Once you have your site set up, you can add your RMarkdown files in the
episodes folder. The only thing controling how these files will appear
is the name of the file themselves, no config necessary :)

When you want to preview your site, use the following:

``` r
sandpaper::build_lesson()
```

This will create the website structure inside of the the `site/` folder,
render the RMarkdown files to markdown (for inspection and quick
rendering), render the markdown files to HTML, and then enable a preview
within your browser window.

### Contributing to a Lesson

To contribute to a lesson, you can either fork the lesson to your own
repository and clone it to your computer manually from GitHub, or you
can use the {usethis} package to automate it. For example, This is how
you can create a copy of [**Programming With
R**](http://swcarpentry.github.io/r-novice-inflammation/) to your
computer’s Desktop.

``` r
usethis::create_from_github(
  repo = "swcarpentry/r-novice-gapminder", 
  destdir = "~/Desktop/r-novice-gampinder",
  fork = TRUE
)
```

This will copy all of the source files to your computer and move you to
the directory.

Note that the rendered website will not be immediately available. To
download the site as it currently appears on the web, use:

``` r
sandpaper::fetch_lesson(markdown = TRUE, site = TRUE)
```

This will download the site and the rendered markdown files into the
`site/` folder. To save bandwidth, you can choose to just download the
markdown files and artifacts by settin `site = FALSE`. Now, you can edit
the Rmarkdown files in `episodes/` and quickly render the site.

To upload changes to the lesson repository, you can use the follow

### Maintaining a Lesson

When you are maintaining a lesson, there is a high likelihood that you
will already have a copy on your machine. If not, follow the
instructions in the [contributing to a
lesson](#contributing-to-a-lesson) section above.

The typical workflow will look like this:

1.  open the sandpaper project in RStudio and make edits to files in the
    `episodes/` folder
2.  in the R console run the following

<!-- end list -->

``` r
sandpaper::check_lesson() # validates the structure of the input files
sandpaper::build_lesson() # builds and validates lesson
```

### Rendering a portable site

To render a portable site, you can follow the instructions for
[contributing to a lesson](#contributing-to-a-lesson) or [maintaining a
lesson](#maintaining-a-lesson) to set up. Once you have the lesson set
up, you can use the following command:

``` r
sandpaper::build_portable_lesson(version = "current")
```

This will render a fully portable lesson site as a zip file in the
`site/` folder. You can distribute this lesson to learners who do not
have reliable internet access for use offline without sacrificing any of
the styling.

### Rendering with GitHub actions

Ultimately, there should be a minimal number of functions that handle
this situation because writing CI configuration files is maddening. The
most straihtforward function is:

``` r
sandpaper::ci_deploy(md_branch = "md-outputs", site_branch = "gh-pages")
```

This will render the markdown files in the `vignettes/` folder of the
“md-outputs” branch and then build the site from that folder and
deploy it to the “gh-pages” branch using the
[{pkgdown}](https://pkgdown.r-lib.org/) machinery.

Because css and js libraries may need updating before any lesson
material does, a step can be created just for rebuilding the site that
uses:

``` r
sandpaper::ci_deploy_site(branch = "gh-pages")
```

When a lesson is given a release, the current site folder needs to be
duplicated to a versioned folder and a tag needs to be added to the
“md-outputs” branch:

``` r
sandpaper::ci_release(tag = "0.1", md_branch = "md-outputs", site_branch = "gh-pages")
```
