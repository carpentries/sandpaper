# Including Child Documents

## Introduction

Writing a lesson using The Workbench consists of writing your lesson in
markdown or R Markdown files, placing them in the `episodes/` directory
and defining the order of those files in the `config.yaml` file. If you
want to author a lesson that contains content that is repeated across
episodes, before {sandpaper} version 0.14, you had to copy and paste the
content across these documents, which would be frustrating to update
down the line. This is where [child
documents](https://bookdown.org/yihui/rmarkdown-cookbook/child-document.html)
come in. You can save a repeated snippet of markdown inside of a
separate file and have R Markdown render the parent as if it had that
snippet embedded the whole time.

The only difference between child documents and the regular episodic
content is that these documents are not independent episodes in their
own right. They do not need to have a title, they do not need to be
listed in the `config.yaml`, they do not need any callout blocks. They
only exist to be used by other markdown documents. Because of this, it
is NOT recommended to make these documents overly complex.

## An Example: One Child Document

You can define these using the `child` attribute in code chunks in R
Markdown files (note: this requires R Markdown). You can use as many
child documents as you wish, but when you create child files, be sure
the following two rules apply:

1.  The child documents live in the `files/` folder under their parent
    folders
2.  The reference to child files is *relative* to the parent file.

For example, you have a file structure like this:

    # ./episodes/
    # ├── data
    # ├── fig
    # ├── files
    # │   └── child.Rmd
    # └── introduction.Rmd

The last few lines of `episodes/introduction.Rmd` looks like this:

```` markdown

Cool, right?

```{r si, child="files/child.Rmd"}
```

::::::::::::::::::::::::::::::::::::: keypoints

- Use `.md` files for episodes when you want static content
- Use `.Rmd` files for episodes when you need to generate output
- Run `sandpaper::check_lesson()` to identify any issues with your lesson
- Run `sandpaper::build_lesson()` to preview your lesson locally

::::::::::::::::::::::::::::::::::::::::::::::::
````

You can see there the declaration of the child document is an empty code
chunk:

```` default
```{r si, child = "files/child.Rmd"}
```
````

This tells {knitr} to take a detour and render the contents of
`files/child.Rmd`(relative to the current working directory, which is
the episodes folder). The entire document of `episodes/files/child.Rmd`
looks like this:

```` markdown
## Session Information

The following is the session information of this R session

```{r sessioninfo}
sessionInfo()
```
````

This means that when `episodes/introduction.Rmd` is built,
`episodes/files/child.Rmd` will also be built, evaulating the
[`sessionInfo()`](https://rdrr.io/r/utils/sessionInfo.html). So the
resulting markdown document will look like this:

```` markdown
`$\alpha = \dfrac{1}{(1 - \beta)^2}$` becomes: $\\alpha = \\dfrac{1}{(1 - \\beta)^2}$

Cool, right?

## Session Information

The following is the session information of this R session

```r
sessionInfo()
```

```output
R version 4.5.2 (2025-10-31)
Platform: x86_64-pc-linux-gnu
Running under: Ubuntu 24.04.3 LTS

Matrix products: default
BLAS:   /usr/lib/x86_64-linux-gnu/openblas-pthread/libblas.so.3 
LAPACK: /usr/lib/x86_64-linux-gnu/openblas-pthread/libopenblasp-r0.3.26.so;  LAPACK version 3.12.0

locale:
 [1] LC_CTYPE=C.UTF-8       LC_NUMERIC=C           LC_TIME=C.UTF-8       
 [4] LC_COLLATE=C.UTF-8     LC_MONETARY=C.UTF-8    LC_MESSAGES=C.UTF-8   
 [7] LC_PAPER=C.UTF-8       LC_NAME=C              LC_ADDRESS=C          
[10] LC_TELEPHONE=C         LC_MEASUREMENT=C.UTF-8 LC_IDENTIFICATION=C   

time zone: UTC
tzcode source: system (glibc)

attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods   base     

loaded via a namespace (and not attached):
[1] compiler_4.5.2 cli_3.6.5      tools_4.5.2    otel_0.2.0     knitr_1.51    
[6] xfun_0.56      rlang_1.1.7    evaluate_1.0.5
```

::::::::::::::::::::::::::::::::::::: keypoints

- Use `.md` files for episodes when you want static content
- Use `.Rmd` files for episodes when you need to generate output
- Run `sandpaper::check_lesson()` to identify any issues with your lesson
- Run `sandpaper::build_lesson()` to preview your lesson locally

::::::::::::::::::::::::::::::::::::::::::::::::
````

## Workspace consideration

The {sandpaper} machinery aims to keep the working space as clean as
possible while still allowing authors to write in a way that feels
natural. During processing, assets (all `.R` files, everything in
`files/`, `fig/`, and `data/`) are copied over from their source folders
to `site/built/`. This allows us to build the R Markdown files using
`site/built/` as the working directory which accomplishes two things:

1.  The default sandpaper folder structure is flattened for the website.
2.  any files the R Markdown document creates or deletes will not affect
    the source files of the project

For example, let’s say we added a chunk to our source R Markdown folder
that will create a file in the `data/` directory called “time.txt” and
then reads in the contents of that file.

```` markdown
---
title: 'introduction'
teaching: 10
exercises: 2
---

```{r setup, echo=FALSE}
writeLines(format(Sys.time()), 'data/time.txt')
cat(paste0('The time is: ', readLines('data/time.txt')))
```
````

When the lesson gets built, the `episodes/` directory will continue to
like this:

    # ./episodes/
    # ├── data
    # ├── fig
    # ├── files
    # │   └── child.Rmd
    # └── introduction.Rmd

Notice that there is no file called `data/time.txt`. This is because
that file was built inside the `site/built` directory. The contents of
this directory contains the output *along with all of the other files in
the lesson*:

    # ./site/built/
    # ├── CODE_OF_CONDUCT.md
    # ├── LICENSE.md
    # ├── config.yaml
    # ├── data
    # │   └── time.txt
    # ├── fig
    # │   └── introduction-rendered-pyramid-1.png
    # ├── files
    # │   └── child.Rmd
    # ├── index.md
    # ├── instructor-notes.md
    # ├── introduction.md
    # ├── learner-profiles.md
    # ├── links.md
    # ├── md5sum.txt
    # ├── reference.md
    # └── setup.md

You can see in `data/`, it now contains `time.txt`. The rendered
Markdown file `site/built/introduction.md` reflects the updates:

```` markdown
---
title: 'introduction'
teaching: 10
exercises: 2
---

```output
The time is: 2026-01-19 11:27:54
```
````

## Child document assets

When you use a child file, it is best to avoid relying on assets
external to the child document itself. If you do decide to reference
other assets, **child documents need to have assets written as if they
were already embedded in the *build parent***. In this case, when I say
*build parent*, I am refering to the final parent of the child document
where the output will eventually end up.

Let’s say you wanted to refererence a figure `episodes/fig/one.png` and
a link to a document for learners `learners/info.md` from the child
document, but instead it’s located at
`episodes/files/children/child.Rmd`, which is built by
`episodes/introduction.Rmd`.

    # ./episodes/
    # ├── data
    # ├── fig
    # │   └── one.png
    # ├── files
    # │   └── children
    # │       └── child.Rmd
    # └── introduction.Rmd

The parent document (`episodes/introduction.Rmd`) referencing the child
document would look like this:

```` markdown

Cool, right?

```{r si, child="files/children/child.Rmd"}
```

::::::::::::::::::::::::::::::::::::: keypoints

- Use `.md` files for episodes when you want static content
- Use `.Rmd` files for episodes when you need to generate output
- Run `sandpaper::check_lesson()` to identify any issues with your lesson
- Run `sandpaper::build_lesson()` to preview your lesson locally

::::::::::::::::::::::::::::::::::::::::::::::::
````

In `episodes/files/children/child.Rmd`, under [internal link
rules](https://carpentries.github.io/sandpaper-docs/episodes.html#internal-links)),
you you should reference these resources with `fig/one.png` and
`../learners/info.md`, which are *in the context of the build parent
directory (in this case, `episodes/`)*, as demonstrated here:

```` markdown
Here is a link to [the info document](../learners/info.md)

![example](fig/one.png){alt='example figure'}

## Session Information

The following is the session information of this R session

```{r sessioninfo}
sessionInfo()
```
````

Again, the reason for this is because when the document gets built, the
result is all in the context of the parent document in the `site/built`
directory[¹](#fn1):

    # ./site/built/
    # ├── CODE_OF_CONDUCT.md
    # ├── LICENSE.md
    # ├── config.yaml
    # ├── data
    # │   └── time.txt
    # ├── fig
    # │   ├── introduction-rendered-pyramid-1.png
    # │   └── one.png
    # ├── files
    # │   └── children
    # │       └── child.Rmd
    # ├── index.md
    # ├── info.md
    # ├── instructor-notes.md
    # ├── introduction.md
    # ├── learner-profiles.md
    # ├── links.md
    # ├── md5sum.txt
    # ├── reference.md
    # └── setup.md

Which makes sense in `site/built/introduction.md`:

```` markdown

Cool, right?

Here is a link to [the info document](../learners/info.md)

![example](fig/one.png){alt='example figure'}

## Session Information

The following is the session information of this R session

```r
sessionInfo()
```

```output
R version 4.5.2 (2025-10-31)
Platform: x86_64-pc-linux-gnu
Running under: Ubuntu 24.04.3 LTS

Matrix products: default
BLAS:   /usr/lib/x86_64-linux-gnu/openblas-pthread/libblas.so.3 
LAPACK: /usr/lib/x86_64-linux-gnu/openblas-pthread/libopenblasp-r0.3.26.so;  LAPACK version 3.12.0

locale:
 [1] LC_CTYPE=C.UTF-8       LC_NUMERIC=C           LC_TIME=C.UTF-8       
 [4] LC_COLLATE=C.UTF-8     LC_MONETARY=C.UTF-8    LC_MESSAGES=C.UTF-8   
 [7] LC_PAPER=C.UTF-8       LC_NAME=C              LC_ADDRESS=C          
[10] LC_TELEPHONE=C         LC_MEASUREMENT=C.UTF-8 LC_IDENTIFICATION=C   

time zone: UTC
tzcode source: system (glibc)

attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods   base     

loaded via a namespace (and not attached):
[1] compiler_4.5.2 cli_3.6.5      tools_4.5.2    otel_0.2.0     knitr_1.51    
[6] xfun_0.56      rlang_1.1.7    evaluate_1.0.5
```

::::::::::::::::::::::::::::::::::::: keypoints

- Use `.md` files for episodes when you want static content
- Use `.Rmd` files for episodes when you need to generate output
- Run `sandpaper::check_lesson()` to identify any issues with your lesson
- Run `sandpaper::build_lesson()` to preview your lesson locally

::::::::::::::::::::::::::::::::::::::::::::::::
````

### What happens if we use relative links here?

If you use relative links in the child document, you will find warnings
about missing files during validation:

    #> ── Validating Fenced Divs ──────────────────────────────────────────────
    #> ── Validating Internal Links and Images ────────────────────────────────
    #> ! There were errors in 2/39 links and images
    #> ◌ Some linked internal files do not exist <https://carpentries.github.io/sandpaper/articles/include-child-documents.html#workspace-consideration>
    #> 
    #> ::warning file=episodes/files/children/child.Rmd,line=1:: [missing file (relative to episodes/)]: [the info document](../../../learners/info.md)
    #> ::warning file=episodes/files/children/child.Rmd,line=3:: [missing file (relative to episodes/)]: [example](../../fig/one.png)

## Child documents of child documents

It is also possible to reference *other child documents* within the
child document, but again, these **child documents paths must be
relative to the build parent path**

Thus, if you have a child document calling a second child document, you
must write the relative path from the build parent. This means that if
you want to reference `episodes/files/child-two.md` from
`episodes/files/child-one.Rmd`, you must write it this way: in
`episodes/files/child-one.Rmd`:

```` default
```{r child='files/child-two.md'}
```
````

------------------------------------------------------------------------

1.  there is a caveat to this paradigm, on translation to HTML, all
    links that begin with `../[folder]/` prefixes have those stripped in
    the final version of the site.
