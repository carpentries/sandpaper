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
