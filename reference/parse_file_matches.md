# Subset file matches to the order they appear in the config file

Subset file matches to the order they appear in the config file

## Usage

``` r
parse_file_matches(reality, hopes = NULL, warn = FALSE, subfolder)
```

## Arguments

- reality:

  a list of paths that exist in the lesson

- hopes:

  a list of files in the order they should appear in the lesson

- warn:

  a boolean. If `TRUE` and the `sandpaper.show_draft` option is set to
  TRUE, then the files that are not in `hopes` are shown to the screen
  as drafts

- subfolder:

  a character. The folder where we should find the files in `hopes`.
  This is only used for creating an error message.

## Value

a character vector of `reality` subset in the order of `hopes`

## Examples

``` r
# setup ----------------------------------------------------
#
# NOTE: we need to define our namespace here because using `:::`
# in example calls is illegal.
snd <- asNamespace("sandpaper")
print(need <- c("a", "bunch", "of", "silly", "files"))
#> [1] "a"     "bunch" "of"    "silly" "files"
print(exists <- fs::path("path", "to", sample(need)))
#> path/to/bunch path/to/of    path/to/files path/to/a     path/to/silly 

# Rearrange files ------------------------------------------
snd$parse_file_matches(reality = exists, hopes = need,
  subfolder = "episodes")
#> path/to/a     path/to/bunch path/to/of    path/to/silly path/to/files 

# a subset of files ----------------------------------------
snd$parse_file_matches(reality = exists,
  hopes = need[4:5], subfolder = "episodes")
#> path/to/silly path/to/files 

# a subset of files with a warning -------------------------
op <- getOption("sandpaper.show_draft")
options(sandpaper.show_draft = TRUE)
on.exit(options(sandpaper.show_draft = op))
snd$parse_file_matches(reality = exists,
  hopes = need[-(4:5)], warn = TRUE, subfolder = "episodes")
#> path/to/a     path/to/bunch path/to/of    

# files that do not exist give an error --------------------
try(snd$parse_file_matches(reality = exists,
  hopes = c("these", need[4:5]), subfolder = "episodes"))
#> episodes:
#> - ✖ these
#> - silly
#> - files
#> Error in error_missing_config(hopes, real_files, subfolder) : 
#>   All files in config.yaml must exist
#> • Files marked with ✖ are not present
```
