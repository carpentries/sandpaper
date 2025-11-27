# copy a sandpaper template file to a path with data

copy a sandpaper template file to a path with data

## Usage

``` r
copy_template(template, path = NULL, name = NULL, values = NULL)
```

## Arguments

- template:

  the base of a valid template function (e.g. "episode" for
  [`template_episode()`](https://carpentries.github.io/sandpaper/dev/reference/template.md))

- path:

  the folder in which to write the file. Defaults to `NULL`, which will
  return the filled template as a character vector

- name:

  the name of the file. Defaults to `NULL`

- values:

  the values to fill in the template (if any). Consult the files in the
  `templates/` folder of your sandpaper installation for details.

## Value

a character vector if `path` or `name` is `NULL`, otherwise, this is
used for its side effect of creating a file.
