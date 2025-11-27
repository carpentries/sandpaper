# Apply template items to translated strings

Apply template items to translated strings

## Usage

``` r
fill_translation_vars(the_data)
```

## Arguments

- the_data:

  a list of global variables (either `learner_globals` or
  `instructor_globals`) that also contains a "translate" element
  containing a list of translated strings.

## Value

the translated list with templated data filled out

## Details

There are two kinds of templating we use:

1.  variable templating indicated by `{key}` where `key` represents a
    variable that exists within the global data and is replaced.

2.  link templating indicated by `<(text to wrap)>` where we replace the
    `<()>` with a known URL or HTML markup. This allows the translators
    to translate text without having to worry about HTML markup.

## Examples

``` r
dat <- list(
  a = "a barn",
  b = "a bee",
  minutes = 5,
  translate = list(
     one = "a normal translated string (pretend it's translated from another language)",
     two = "a question: are you (A) {a}, (B) {b}",
     EstimatedTime = "Estimated time: {icons$clock} {minutes}",
     license = "Licensed under {license} by the authors",
     ThisLessonCoC = "This lesson operates under our <(Code of Conduct)>"
  )
)
asNamespace("sandpaper")$fill_translation_vars(dat)
#> $one
#> [1] "a normal translated string (pretend it's translated from another language)"
#> 
#> $two
#> a question: are you (A) a barn, (B) a bee
#> 
#> $EstimatedTime
#> Estimated time: <i aria-hidden="true" data-feather="clock"></i> 5
#> 
#> $license
#> Licensed under <a href="LICENSE.html">CC-BY 4.0</a> by the authors
#> 
#> $ThisLessonCoC
#> [1] "This lesson operates under our <a href=\"CODE_OF_CONDUCT.html\">Code of Conduct</a>"
#> 
```
