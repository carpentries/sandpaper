# This will strip existing episode prefixes and set the schedule

Episode order for Carpentries lessons originally used a strategy of
prefixing files by a two-digit number to force a specific order by
filename. This function will strip these numbers from the filename and
set the schedule according to the original order.

## Usage

``` r
strip_prefix(path = ".", write = FALSE)
```

## Arguments

- path:

  the path to the lesson (defaults to the current working directory)

- write:

  defaults to `FALSE`, which will show the potential changes. If `TRUE`,
  the schedule will be modified and written to `config.yaml`

## Value

when `write = TRUE`, the modified list of episodes. When
`write = FALSE`, the modified call is returned.

## Note

git will recognise this as deleting a file and then adding a new file in
the stage. If you run `git add`, it should recognise that it is a
rename.

## See also

[`create_episode()`](https://carpentries.github.io/sandpaper/dev/reference/create_episode.md)
for creating new episodes,
[`move_episode()`](https://carpentries.github.io/sandpaper/dev/reference/move_episode.md)
for moving individual episodes around.

## Examples

``` r
if (FALSE) {
  strip_prefix() # test if the function is doing what you want it to do
  strip_prefix(write = TRUE) # rewrite the episode names
}
```
