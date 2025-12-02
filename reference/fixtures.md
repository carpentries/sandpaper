# Test fixture functions for sandpaper

This suite of functions are for use during testing of `{sandpaper}` and
are designed to create/work with a temporary lesson and associated
remote repository (locally) that persists throughout the test suite.
These functions are used in `tests/testthat/setup.R`. For more
information, see the [package scope section of testthat article on Test
Fixtures](https://testthat.r-lib.org/articles/test-fixtures.html#package).

## Usage

``` r
create_test_lesson()

generate_restore_fixture(repo)

setup_local_remote(
  repo,
  remote = tempfile(),
  name = "sandpaper-local",
  verbose = FALSE
)

make_branch(repo, branch = NULL, name = "sandpaper-local", verbose = FALSE)

clean_branch(repo, branch = NULL, name = "sandpaper-local", verbose = FALSE)

remove_local_remote(repo, name = "sandpaper-local")
```

## Arguments

- repo:

  path to a git repository

- remote:

  path to an empty or uninitialized directory. Defaults to a tempfile

- name:

  of the remote, defaults to "sandpaper-local"

- verbose:

  if `TRUE`, messages and output from git will be printed to screen.
  Defaults to `FALSE`.

- branch:

  the name of the new branch to be deleted

## Value

(`generate_restore_fixture`) a function that will restore the test
fixture

(`setup_local_remote()`) the repo, invisibly

(`remove_local_remote()`) FALSE indicating an error or a string
indicating the path to the remote

## Details

### `create_test_lesson()`

This creates the test lesson and calls `generate_restore_fixture()` with
the path of the new test lesson.

### `generate_restore_fixture()`

This creates a function that will restore a lesson to its previous
commit.

### `setup_local_remote()`

Creates a local remote repository in a separate temporary folder, linked
to the fixture lesson.

### `make_branch()`

create a branch in the local repository and push it to the remote
repository.

### `clean_branch()`

delete a branch in the local and remote repository.

### `remove_local_remote()`

Destorys the local remote repository and removes it from the fixture
lesson

## Note

These are implemented in tests/testthat/setup.md
