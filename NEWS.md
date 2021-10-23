# sandpaper 0.0.0.9063

BUG FIX
-------

* The package cache can now be built from external {renv} environments
  (@zkamvar, #197).


# sandpaper 0.0.0.9062

BUG FIX
-------

* New lessons that specify custom titles will have them reflected in the config
  file (@zkamvar, #195).

# sandpaper 0.0.0.9061

BUG FIX
-------

* lessons with colons in the title are now correctly processed (@zkamvar, #192)
* code injection in yaml is now protected against by setting `eval.expr = FALSE`
  in all yaml parsing calls.

# sandpaper 0.0.0.9060

BUG FIX
-------

* The title of the lesson will now appear in the index page.

MISC
----

* The translation script no longer lives in the lesson repo and has been moved
  (and modified) to https://data-lessons/lesson-transition/

# sandpaper 0.0.0.9059

CONTINUOUS INTEGRATION
----------------------

* The scheduler for `update-cache.yaml` has been fixed to run strictly on the
  first Tuesday of the month instead of the first seven days of the month AND on
  Tuesdays.

# sandpaper 0.0.0.9058

CONTINUOUS INTEGRATION
----------------------

* `update-cache.yaml` has been simplified to pull from the carpentries/actions
  repository and now updates packages that were not previously included in the
  lockfile (#185).

# sandpaper 0.0.0.9057

CONTINUOUS INTEGRATION
----------------------

* `update-cache.yaml` has been fixed from a regression introduced with
  4b8b14d088d03a8a9c6c90e974bb53c35691fb49 where the workflow would not run 
  because it did not check out the repository beforehand.

# sandpaper 0.0.0.9056

BUG FIX
-------

* `update_github_workflows()` now sets `clean = "*.yaml"` by default to align
  with the behavior of the GitHub workflow and to prevent stale workflows from
  being present in the repository. (#181, @zkamvar)

# sandpaper 0.0.0.9055

CONTINUOUS INTEGRATION
----------------------

* `sandpaper-main.yaml` and `pr-receive.yaml` have been simplified by using 
  composite actions hosted in `carpentries/actions/setup-sandpaper` and
  `carpentries/actions/setup-deps`.
* The caching mechanism for R packages and the package cache can now be
  reset by modifying a per-repository secret called `CACHE_VERSION`.

BUG FIX
-------

 * A bug introduced in 0.0.0.9054 where dependencies were not discovered was
   fixed.

# sandpaper 0.0.0.9054

MISC
----

* `manage_deps()` runs slightly faster now that it no longer runs
  `renv::hydrate()` if no new packages have been added in the lesson.

# sandpaper 0.0.0.9053

NEW FEATURES
------------

* setting `option(sandpaper.handout = TRUE)` will create a code handout for R
  lessons that will live in `/files/code-handout.R` on your site.

MISC
----

* An internal caching mechanism has been added for `pegboard::Lesson` objects
  that we use for extracting components for the syllabus and the handout. See
  `?lesson_storage` for details.

# sandpaper 0.0.0.9052

CONTINUOUS INTEGRATION
----------------------

* `pr-receive.yaml` has fixed spelling.
* `pr-receive.yaml` has changed to short-cut the invalid PR messages and no
  longer build the lesson if the PR is invalid. Instead, it will emit the same
  warning message without building artifacts.
* `pr-comment.yaml` will no longer fail when no artifacts exist (which would 
  cause extraneous emails for users).

DOCUMENTATION
-------------

* Documentation for test fixtures has been improved to include branch functions.

# sandpaper 0.0.0.9051

MISC
----

The template for the pull request message reverts back to two-dot diff notation
between branches, which is temporary until #169 can be addressed. Linebreaks
within paragraphs have been removed to avoid github formatting them as
linebreaks.

# sandpaper 0.0.0.9050

This update for {sandpaper} brings in dependency management for lessons with
generated content which will make collaboration between these lessons much 
easier and less invasive by establishing a package cache and lockfile via the 
{renv} R package.

DEPENDENCY MANAGEMENT
---------------------

### Introduction

We use the {renv} package for controlling dependency management in the lesson,
which is contained in a {renv} profile called "lesson-requirements". We have
implemented this as a profile instead of the default {renv} environment to give
the maintainers flexibility of whether or not they want to use the package cache.

### Consent for Using the Package Cache

 - `getOption('sandpaper.use_renv')` will be set when {sandpaper} loads to
   detect if the contributor has previously consented to use the {renv} package.
   If this is `TRUE`, the lesson will use a package cache, otherwise, the lesson
   will use the default library.
 - `use_package_cache()` will give consent to {sandpaper} to create and use a
   package cache via {renv}. Internally, this enforces that
   `options(sandpaper.use_renv = TRUE)`.
 - `no_package_cache()` does the opposite of `use_package_cache()` and revokes
   consent to use the package cache in a lesson temporarily. This can be useful
   in situtations where the cache is mis-behaving or you want to test the lesson
   using a newer set of packages. Internally, this enforces that
   `options(sandpaper.use_renv = FALSE)`.
 - `package_cache_trigger(TRUE)` allows you to trigger a full rebuild when the
   lockfile changes. This is set to `TRUE` by default on `ci_build_markdown()`

### Managing the Package Cache

 - `manage_deps()` is a new function that will manage dependencies for a lesson.
   This is called both in `create_lesson()` and `build_markdown()` to ensure
   that the correct dependencies for the lesson are installed. This explicitly
   calls `use_package_cache()` when it runs.
 - `update_cache()` will bring in updates for the lesson cache.
 - `pin_version()` will pin packages to a specific version, allowing authors to
   upgrade or downgrade packages at will.

NEW FEATURES
------------

 - `create_lesson()` now additionally will create a {renv} profile called
   "packages" in the lesson repository if `getOption('sandpaper.use_renv')` is 
   `TRUE`. This will make the lesson more portable.
 - index and README files can now be Rmd files (though it is recommended to use
   .renvignore for these files if they are to avoid {sandpaper} becoming part of
   the package cache).
 - internal function `ci_deploy()` will set `sandpaper.use_renv` option to 
   `TRUE`
 - `build_markdown()` and thus `build_lesson()` will now cache `config.yaml` and
   `renv.lock`. It will no longer step through the build process if no markdown
   files need to be rebuilt. This will cause any project built with previous
   versions of sandpaper to be fully rebuilt. 
 - `sandpaper_site()` (and thus, `build_lesson()`) now can take in a single file
   for rendering and render that specific file regardless if it is present in
   the cache without rendering other files. This further addresses #77. (n.b.
   this involved changes to `build_markdown()`, `build_site()`, and 
   `build_status()`).
 - `varnish_vars()` is a list that contains commonly used variables in the
   lesson that can not be contained in the config.yaml
 - `build_episode()` and `build_home()` now supply default variables to varnish.

CONTINOUS INTEGRATION
---------------------

 - unexported function `ci_deploy()` will now automatically check and set the
   git user and email.
 - `sandpaper-main.yaml` and `pr-receive.yaml` have been updated to include
   the {renv} cache, but they will skip these steps for markdown lessons.
 - `update-cache.yaml` is a new workflow that will update the package cache
   lockfile and create a pull request to trigger new builds if the lesson uses
   {renv}.
 - `update-workflows.yaml` now produces more informative instructions for
   creating a repository secret.

MISC
----

 - some of the {callr} functions have been made non-anonymous and moved to a
   separate file so they could be tested independently.

BUG FIX
-------

 - changes to `config.yaml` are now reflected on the lesson site without
   rebuilding (fixes #75)
 - knitr option `root.dir` has been set to the output directory to avoid
   generated content from entering the source.

# sandpaper 0.0.0.9049

This is a placeholder for the testing of 0.0.0.9050.

# sandpaper 0.0.0.9048

BUG FIX
-------

* pandoc lua filter no longer errors on raw div HTML elements with no class
  (@zkamvar, #166)

# sandpaper 0.0.0.9047

CONTINUOUS INTEGRATION
----------------------

 - The `update-workflows.yaml` workflow now checks if the `SANDPAPER_WORKFLOW`
   secret is valid. If not, it provides instructions for creating a new secret.

# sandpaper 0.0.0.9046

CONTINUOUS INTEGRATION
----------------------

 - Weekly run pull requests now default to "weekly run" for "who triggered this
   pull request"

# sandpaper 0.0.0.9045

CONTINUOUS INTEGRATION
----------------------

 - Weekly run has been added for the workflows action
 - Actions have been updated to reflect the zkamvar -> carpenteries repository
   transfer (@zkamvar, #156)

# sandpaper 0.0.0.9044

CONTIUOUS INTEGRATION
---------------------

 - The `update-workflow.yaml` parameters have been fixed to not use wildcards

MISC
----

 - `update_github_workflows()` gains a `clean` argument and now will print
   status reports at the end. 


# sandpaper 0.0.0.9043

CONTINUOUS INTEGRATION
----------------------

 - The `update-workflow.yaml` workflow has been updated to use the github action
   hosted on `zkamvar/actions` (soon to be transferred to The Carpentries account
 - The names of the actions displayed on GitHub have been updated to be more
   descriptive.
 - The script in `inst/scripts/update-workflows.sh` has been removed in favor of
   the github action.

# sandpaper 0.0.0.9042

CONTINUOUS INTEGRATION
----------------------

 - An experimental `update-workflow.yaml` workflow has been created which will
   create a pull request that will update the workflows. It is still _very_
   experimental and it requires a scoped with repo and scope, but,
   nevertheless, the concept is currently valid.

# sandpaper 0.0.0.9041

MISC
----

 - `fetch_github_workflows()` has been renamed to `update_github_workflows()`
 - github workflows are no longer downloaded from an external source; they
   now live in inst/workflows. This will reduce the internet connection 
   requirements for setting up a lesson and testing sandpaper.
 - `create_lesson()` now reports progress as it goes along
 - tests were updated to use the fixtures

# sandpaper 0.0.0.9040

CONTINUOUS INTEGRATION
----------------------

 - `ci_deploy()` gains the `reset` argument, which can be used to clear the 
   cache for a clean build of the lesson.
 - `ci_deploy()` now uses `ci_build_markdown()` and `ci_build_site()`, 
   internally

# sandpaper 0.0.0.9039

CONTINUOUS INTEGRATION
----------------------

 - `ci_session_info()` will report the session information, which will help 
   clean up the workflow files.

# sandpaper 0.0.0.9038

CONTINUOUS INTEGRATION
----------------------

 - Fix broken deploy process on continuous integration caused by attempting to
   fetch all branches in a shallow clone (@zkamvar, #142)

# sandpaper 0.0.0.9037

CONTINUOUS INTEGRATION
----------------------

 - Output of `ci_bundle_pr_artifacts()` no longer escapes HTML-like output in
   the diff summary. 
 - remove {xml2} from explicit dependencies

# sandpaper 0.0.0.9036

CONTINUOUS INTEGRATION
----------------------

 - Documentation for `git_worktree_setup()` has been added for future versions
   of the maintainer and future contributors.
 - `ci_bundle_pr_artifacts()` is a new internal function that will create
   artifacts for GitHub to upload upon receipt of a pull request. This will
   replace clunky shell code that lived inside a YAML configuration file.
   (@zkamvar, #139)
 - add {brio} to soft dependencies (for testing, but maybe could speed up???)

# sandpaper 0.0.0.9035

CONTINUOUS INTEGRATION
----------------------

 - Tests for git operations were added to be more robust (@zkamvar, #137)
 - new test fixtures for a local remote repository was added to aid the above
   git tests.

# sandpaper 0.0.0.9034

NEW FEATURES
------------

 - Authors can now cross-link between files within the lesson as they appear in
   the lesson instead of trying to guess how the link would appear on the
   website. For example, if you wanted to reference `learners/setup.md` in 
   `episodes/introduction.md`, you would write `[setup](../learners/setup.md)`
   and it will be automatically converted to the correct URL in the website
   (#43). This is still backwards compatible with the previous iteration of
   writing the flattened link (as it would appear on the website).

# sandpaper 0.0.0.9033

NEW FEATURES
------------

 - `get_drafts()` will report any markdown files that are not currently 
   published in the lesson.
 - Draft alert notifications are controlled by the `"sandpaper.show_draft"`
   option. To turn off these messages, use 
   `options(sandpaper.show_draft = FALSE)`
 - The `set_dropdown()` family of functions will now throw an error if an 
   author attempts to add a file that does not exist
 - An error will occurr if the files listed in `config.yaml` do not exist in the
   lesson with an informative message highlighting the files that are missing.

# sandpaper 0.0.0.9032

MISC
----

 - The internal `get_resource_list()` function has been modified to incorporate
   the features of `get_dropdown()`. This means that all `get_dropdown()`
   functions will only report the files in the dropdown menus that actually
   exist in the directory (#134).
 - A persistant test fixture is now included to speed up testing time (#132 via
   #134)

# sandpaper 0.0.0.9031

MISC
---

 - The {cli} package is now an official import of the package
 - The warning message issued from the internal `warn_schedule()` function has
   been changed exclusively use cli messages and can be suppressed with 
   `suppressMessages()`.
 - The internal `sandpaper_cli_theme()` is used to style CLI messages. 

# sandpaper 0.0.0.9030

MISC
----

 - A test that caused problems with a new version of {pegboard} was fixed

# sandpaper 0.0.0.9029

MISC
----

 - The internal database is updated to use relative instead of absolute paths. 
   This fixes #129

# sandpaper 0.0.0.9028

NEW IMPORTS
-----------

The {pingr} package is now being imported to check for online access, which will
marginally decrease data usage (@fmichonneau, #127).

# sandpaper 0.0.0.9027

MISC
----

* `create_schedule()` (internal function) no longer uses pegboard's extensions
  for fixing reference links. 

# sandpaper 0.0.0.9026

MISC
----

* callout blocks with headers greater than h3 are now rendered properly and no
  longer forced to h3
* tests now clean up after themselves and no longer change the working directory
  by default
* {varnish} version bumped to 0.0.0.9005
* tests that require pandoc will be skipped if pandoc is not available
* tests for the presences of multiple files will use setequal instead of equal
  to allow for alternate sorting orders. 

# sandpaper 0.0.0.9025

DEPENDENCY UPDATE
-----------------

 * required {pegboard} has been bumped to version 0.0.0.9014
 * {renv} and {sessioninfo} added to Suggested packages.

# sandpaper 0.0.0.9024

BUG FIX
-------

 * `create_lesson()` will now enforce "main" or the default branch (if 
   init.defaultBranch is set) as the default branch for the new lesson. It will
   also try to make the URL match the project name and user name (but the latter
   is limited to users who have GitHub PAT set up that {gh} recognises).

# sandpaper 0.0.0.9023

BUG FIX
-------

* `build_episode_md()` now sets the `knitr.pandoc.to` knit option to allow for
  the chunk option `fig.cap` to be rendered as a caption. This fixes #114.

NEW FEATURES
------------

* `set_dropdown()` is now generalized to set any item in the dropdown menu
  (though this will likely be wrapped into a better-named function for
  generalized editing).
* `system.file("transform.R", pacakge = "sandpaper")` points to a file that 
  will be used for transforming styles-repo era lessons to sandpaper lessons.
* read/write cycles were reduced in markdown generation because we are no longer
  interfering with the manipulation of the files at this stage (and haven't been
  for a while now).

# sandpaper 0.0.0.9022

BUG FIX
-------

* `build_markdown(rebuild = TRUE)` now actually rebuilds the lesson
* Changing an episode suffix will no longer result in a build error. This was
  due to `build_markdown()` trying to clean _after_ building the output instead
  of before. It's a situation of throwing the baby out with the bathwater. In
  any case, this fixes #102.

# sandpaper 0.0.0.9021

BUG FIX
-------

* the template will be initialized with ALL folders with placeholders inside
  of the `instructor/` and `profile/` menus. This fixes #103.

# sandpaper 0.0.0.9020

BUG FIX
-------

* the `set_*()` functions no longer mess up yaml lists in `config.yaml`. This
  fixes #53. 

# sandpaper 0.0.0.9019

* The required version of {pegboard} has been bumped to 0.0.0.9012, which gives
  better error messages and allows us to read in {sandpaper} lessons with the
  Lesson object. 

# sandpaper 0.0.0.9018

* The episode template has been rearranged slightly and given level 2 headers.

# sandpaper 0.0.0.9017

ENGINE UPDATE
-------------

* The version of pandoc will be explicitly checked to ensure that the version
  used is at least 2.11.

# sandpaper 0.0.0.9016

BUG FIX
-------

 * `create_episode()` with `make_prefix = FALSE` will no longer create episodes
   prefixed with `-` (see #93).

# sandpaper 0.0.0.9015

NEW FEATURES
------------

* `fetch_github_workflows()` will download and update the GitHub workflows from
  the Carpentries actions repository. 
* `update_varnish()` will download and update the {varnish} styling package to
  your local repository. 

# sandpaper 0.0.0.9014

BUG FIX
-------

* Episode order is retained in the HTML navigation (#85)
* index.md is recorded in the site/build/ directory, and thus in the md-pages
  branch on deployment.

ENGINE UPDATE
-------------

The caching mechanism is now similar to that of {blogdown} where a database of
source files and their checksum hashes is kept and only the updated files are
built. This provides two advantages, the first is that we no longer have to peek
at the top of the files to check if they need to be updated and the second is
that we can keep the files in the right order (see #85)

Importantly, the workflow itself should not be affected, but there will be
changes in what gets displayed on the github diff of the md-outputs branch.

# sandpaper 0.0.0.9013

NEW FEATURES
------------

* In RStudio, the **knit button works** :tada: (fix #77; @zkamvar, #82)
* `sandpaper_site()` is a site generator function that allows {rmarkdown} to
  use the {sandpaper} machinery to build the site from
  `rmarkdown::render_site()`
* `build_site()` gains a `slug` argument that tailors the previewed content.
* `create_lesson()` will now create a blank `index.md` with `site:
  sandpaper_site` as the only YAML item. 
* HTML accidentally rendered to the source directories are silently removed
  when the site is built. (fix #78, @zkamvar, #84)

# sandpaper 0.0.0.9012

NEW FEATURES
------------

* Inline and reference-based footnotes are now supported.

# sandpaper 0.0.0.9011

BUG FIX
-------

* Bare links and text emoji (e.g. :wink:) are now rendered (fix #67).
* Objectives and Questions headings will now no longer be rendered (fix #64).

# sandpaper 0.0.0.9010

BUG FIX
-------

* If `index.md` exists at the top level, it will be used instead of `README.md`
  for the lesson index page (fix #56). 

# sandpaper 0.0.0.9009

BUG FIX
-------

* The lua filter responsible for creating the Objectives summary block at the
  beginning of episodes now uses native pandoc divs instead of HTML block shims.
  This ensures that the content is not corrupted by pandoc's section divs 
  extension. This addresses issue #64
* All aside elements will be forced to have level 3 headers (this fixes an issue
  with pandocs --section-divs where it couldn't understand when an HTML block
  contained only the start of an aside tag and decided to end the section right
  after it.
* The Objectives and Questions blocks will no longer include their headers in 
  the initial summary block.
* A bug introduced in version 0.0.0.9008 was fixed. This bug improperly used 
  regex resulting in the accidental removal of cached rendered images. This
  fixes issue #49
* Rendered images now have the prefix of `{SOURCE}-rendered-` in the 
  `site/built/fig/` subdir. 


# sandpaper 0.0.0.9008

BUG FIX
-------

* files that were removed from the source are now also removed in the site/built
  directory. This fixes issue #47

# sandpaper 0.0.0.9007

* HTML will now be processed with pandoc lua filters that will do the following:
  - overview block will be constructed from the teaching and exercises metadata
    with the question and objectives blocks
  - instructor and callout divs will be converted to `<aside>` tags
  - divs without H2 level headers will have them automatically inserted
  - divs with incorrect level headers will have them converted to H2
  - only divs in our list of carpentries divs will be converted

* README updated to reflect API changes

# sandpaper 0.0.0.9006

Continuous integration functions added:

* `ci_deploy()` will build the markdown source and the site and commit them to
  separate branches, including information about their source. 
* `ci_build_markdown()` will build the markdown source files and commit them
  to a separate branch, including information about the source commit.
* `ci_build_site()` will build the site directly from the markdown branch,
  bypassing re-rendering the markdown files. 

Miscellaneous additions

* {dovetail} no longer in suggests
* new internal function `build_site()` compartmentalizes the conversion from 
  markdown to html 
* any files or folders named `.git` in the episodes directory will not be
  copied over to the website.


# sandpaper 0.0.0.9005

* sandpaper now requires and uses additional folders and files:
  - CODE_OF_CONDUCT.md
  - learners/Setup.md
  - instructors/
  - profiles/
  - LICENSE.md 
* `_schedule()` functions have been renamed to `_episodes()`.
* `clean_*()` functions are now renamed to `reset_*()`
* Generic `set/get/reset_dropdown()` functions have been created to facilitate
  modification/access of folders that are dropdown menus inside of the lesson
* questionable practices with directories mucking about. 
* `build_markdown()` will now generate artifacts in the `site/built/assets/`
  directory instead of `episodes/` directory to prevent generated artifacts from
  being included in git (See https://github.com/carpentries/sandpaper/issues/24)

# sandpaper 0.0.0.9004

* Internal `html_from_md()` renamed to `render_html()`
* Internal `build_episode()` renamed to `build_episode_html()` and exported,
  but documentation still internal
* Internal `build_single_episode()` renamed to `build_episode_md()` and exported,
  but documentation still internal


# sandpaper 0.0.0.9003

* A regression in `build_markdown()` due to being called in a separate process
  was fixed.
* Internal functions for setting {knitr} options were migrated to live inside
  `build_markdown()`

# sandpaper 0.0.0.9002

* Migrate template to use fenced divs instead of {dovetail}. 
* `build_lesson()` will now render HTML in episode titles. 
* {callr} is now imported to protect the processes building markdown and HTML
  files. 

# sandpaper 0.0.0.9001

* Add `override` argument to `build_lesson()`. This gets passed on to 
  `pkgdown::as_pkgdown()` for more control over where the site gets built.
* Update dependency of {pegboard} to 0.0.0.9006, which includes the $questions
  field to make parsing the ever shifting landscape a bit easier. 
* First tracking version with NEWS
