# List Storage Generator

This is a function that will generate an object that can serve as
persistant storage for pre-computed values. Each object contains a list
called `.this_list` embedded within the enviroment it was created in.

## Usage

``` r
.list_store()
```

## Value

a list with five functions the all operate on the internal `.this_list`
list object:

- [`get()`](https://rdrr.io/r/base/get.html) returns the value of
  `.this_list`

- `update(value)` updates `.this_list` with a modified list `value`.
  Useful for adding several pieces of information at once.

- `set(key, value)` sets a given `key` (vector, with each element
  representing a level of nesting) to a particular value (can be a
  vector or list). If the `key` is `NULL`, `.this_list` is replaced with
  `value`

- `clear()` sets `.this_list` to `NULL`

- `copy()` creates an independent copy of the object for modification.

## Examples

``` r
if (FALSE) {
  # note: asNamespace() gives access to internal functions. This is for
  # demonstration purposes only. There is no guarantee for these functions to
  # work.
  global_list <- asNamespace("sandpaper")$.list_store()
  global_list$set(key = NULL, list(a = 1, b = list(2)))
  global_list$set(key = "c", "three")
  global_list$get()
  global_list$update(list(c = "THREE", d = global_list$get()))
  global_list$get()
}
```
