# (Experimental) Work with the package cache

This function is designed so that you can work on your lesson inside the
package cache without overwriting your personal library.

## Usage

``` r
work_with_cache(profile = "lesson-requirements")
```

## Value

a function that will reset your R environment to its original state

## Examples

``` r
if (interactive() && fs::dir_exists("episodes")) {
  library("sandpaper")
  done <- work_with_cache()
  print(.libPaths())
  # install.packages("cowsay") # install cowsay to your lesson cache
  # cowsay::say() # hello world
  # detach('package:cowsay') # detach the package from your current session
  done() # finish the session
  # try(cowsay::say()) # this fails because it's not in your global library
  print(.libPaths())
}
```
