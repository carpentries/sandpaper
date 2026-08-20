# Compute a combined hash over all active snippet config and snippet files

Compute a combined hash over all active snippet config and snippet files

## Usage

``` r
get_snippets_hash(path)
```

## Arguments

- path:

  the path to an episode or lesson directory

## Value

a single string hash that changes whenever:

- The active base or custom snippets config YAML changes

- Any file inside the active snippet directories changes

- The `base_snippets` or `custom_snippets` keys in config.yaml change
  (because `get_lesson_customization()` re-reads config.yaml)

Returns `NULL` when snippets are not configured.
