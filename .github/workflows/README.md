# Validation and Integration Workflows for {sandpaper}

Because this package uses {renv} internally to provision packages, it follows a
modified R CMD check workflow with the following modifications:

1. The {renv} cache root path is explicitly set as the environment variable
   `RENV_PATHS_ROOT`. By default, the {testthat} package provisions a temporary
   directory for this when testing to preserve the cache that might be used for
   the package itself. 
