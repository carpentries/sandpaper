# Validation and Integration Workflows for {sandpaper}

Because this package uses {renv} internally to provision packages, it follows a
modified R CMD check workflow with the following modifications:

## Integration Tests

We want to make sure that the new version of {sandpaper} does not destroy 
rendering of current lessons, so we provide an integration test on MacOS that
will re-render https://carpentries.github.io/sandpaper-docs locally to see if
any errors pop up.


## The {renv} cache

The {renv} cache root path is explicitly set as the environment variable
`RENV_PATHS_ROOT`. By default, the {testthat} package provisions a temporary
directory for this when testing to preserve the cache that might be used for
the package itself. This cache, however, seems to get destroyed periodically on
linux and causes testing times to baloon out of control to be > 10 or even > 20
minutes!!!

The one catch is that we cannot run tests on windows for whatever reason, the
cache does not behave well, so we have disabled the cache running in Windows in
both GitHub Actions, in the functions, and in the tests themselves by setting
`options(sandpaper.use_renv = FALSE)` explicitly in `tests/testthat/setup.R` if
the tests are running on Windows.

We have also added a catch in `ci_build_markdown()` to not run on Windows if it
is currently in a test.

### New Steps

#### Restore {renv} cache

This restores the cache in `RENV_PATHS_ROOT` by evaluating if
`.github/workflows/R-CMD-check.yaml` has changed (note: that this should 
probably change to evaluate if the cache itself has changed, but whatevs).

#### Prime {renv} Cache

For some reason, the cache is not preserved after running the tests, so we prime
the cache before testing to make sure that it still exists after the tests run.







