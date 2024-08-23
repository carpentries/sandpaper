# sandpaper 0.16.6 (2024-08-23)

## BUG FIXES

* Regression fix for update to pkgdown resulting in 
  duplicated untranslated h2 anchors for sections (@froggleston #600)
* Fix various action warnings and issues relating to 
  old Node.js versions (@jhlegarreta #596)
* Update core actions to v4 (@Bisaloo #577)

## NEW FEATURES

* Allow custom carpentry config types, and associated alt-text descriptions to 
  support alternative logos/theming of lessons (@milanmlft #585, @ErinBecker)
* Add support for French translations of core lesson components/sections (@Bisaloo #595)


# sandpaper 0.16.5 (2024-06-18)

## BUG FIXES

* Fix for empty divs when checking for headers
  (reported: @dmgatti, #581; fixed @froggleston)
* Fix for spacing in callout titles when they have
  inner tags, e.g. `<code>`
  (reported: @abostroem, #562; fixed @froggleston)

## NEW FEATURES

* Add support for including the Carpentries matomo
  tracker, a custom user-supplied tracker script, or
  no tracking 
  (reported: @tbyhdgs, @fiveop https://github.com/carpentries/varnish/issues/37,
   @zkamvar https://github.com/carpentries/sandpaper/issues/438,
   implemented: @froggleston
  )


# sandpaper 0.16.4 (2024-04-10)

## NEW FEATURES

* The lesson page footer now supports either a CITATION or CITATION.cff file
  (reported: @tobyhodges, implemented: @froggleston, #572; @tobyhodges, 
  https://github.com/carpentries/varnish/pull/122)
* Add support for tabbed content in lessons
  (reported: @astroDimitrios,
   implemented: @astroDimitrios, @froggleston,
   https://github.com/carpentries/sandpaper/pull/571,
   https://github.com/carpentries/varnish/pull/121,
   https://github.com/carpentries/pegboard/pull/148
  ). 


# sandpaper 0.16.3 (2024-03-12)

## BUG FIX

* Hotfix for pandoc2-to-pandoc3 bump that resulted in CSS deduplication
  of section classes for callout blocks
  (reported: @bencomp, #470; @ndporter https://github.com/carpentries/workbench/issues/81; 
  fixed: @froggleston, #574)

# sandpaper 0.16.2 (2023-12-19)

## MISC

* JSON metadata now contains the `inLanguage` key.

## DOCUMENTATION

* A list of translatable strings has now been added to 
  `vignette("translations", package = "sandpaper")`

## INTERNAL

* Translation strings now are unduplicated and live in a single file
  (`R/utils-translate.R`). This will make finding and updating these strings
  easier for maintainer and translators.
* Translations now live in the global environment called `these$translations`
* A new documentation page called `?translate` contains details of how
  translations of template elements are rendered.
- `tr_src()` helper function provides access to the source strings of the
  translations.
- `tr_get()`, `tr_varnish()`, and `tr_computed()` helper functions provide
  access top the lists of translated strings. These have replaced the `tr_()`
  strings at the point of generation.

# sandpaper 0.16.1 (2023-12-14)

## BUG FIX

* Callout headings with markup in the titles will no longer have text duplicated
  (reported: @zkamvar, #556; fixed: @zkamvar, #557)

# sandpaper 0.16.0 (2023-12-13)

## NEW FEATURES

* It is now possible to build lessons in languages other than English so that
  the website elements are also localised to that language (reported: @zkamvar,
  #205, @joelnitta, #544; fixed: @joelnitta and @zkamvar, #546). 
* `known_languages()` is a function that will return the language codes that are
  known by {sandpaper}. 

## DOCUMENTATION

* A new vignette `vignette("translation", package = "sandpaper")` describes how
  translation of template components works and how to submit new/update
  translations (added: @zkamvar, #546).
- A new vignette about data flow `vignette("data-flow", package = "sandpaper")`
  describes how templating, translations, and lesson metadata flows from
  {sandpaper} to {varnish} (added: @zkamvar, #553)

## BUG FIX

* The spelling of keypoints is now consistent between the menu item and the
  callout blocks (reported: @clarallebot, 
  https://github.com/carpentries/workbench/issues/44; fixed: @zkamvar, #546)

## DEPENDENCIES

* The {withr} package has been upgraded to an import from a suggested package.

## LANGUAGES

* Japanese (ja) (added: @joelnitta, #546)
* Spanish (es) (added: @yabellini, #552)

## MISC

* Added @yabellini as a contributor and translator
* Added @joelnitta as an author and translator


# sandpaper 0.15.0 (2023-11-29)

## NEW FEATURES

* Using `handout: true` in `config.yaml` will cause a handout to be generated
  for the lesson website under `/files/code-handout.R`. At the moment, this is
  only relevant for R-based lessons (implemented: @froggleston, #527,
  reviewed: @zkamvar) and supersedes the need for specifying
  `options(sandpaper.handout = TRUE)`
* Content for learners now accessible through instructor view. The instructor
  view "More" dropdown menu item will now have links to learner view items
  appended. Note that when clicking these links, the user will remain in
  instructor view. This behaviour may change in future iterations (reported:
  @karenword, #394; fixed: @ErinBecker, #530, reviewed: @zkamvar)
* `create_episode()` will now open new episodes for editing in interactive
  sessions (implemented: @milanmlft, #534, reviewed: @zkamvar)
* The `site/` folder is now customisable to any writable directory on your
  system by setting the experimental `SANDPAPER_SITE` environment variable to
  any valid and empty folder. This is most useful in the context of Docker
  containers, where file permissions to mounted volumes are not always
  guaranteed (reported: @fherreazcue #536; implemented: @zkamvar, #537)
* DOI badges can now be displayed when paired with {varnish} version 0.4.0 by
  adding the `doi:` key to the `config.yaml` file with either the raw DOI or
  the URL to the DOI (reported: @tobyhodges, carpentries/workbench#67;
  fixed: @tobyhodges, #535).

## BUG FIX

* Internal `build_status()` function: make sure `root_path()` always points 
  to lesson root (reported: @milanmlft, #531; fixed: @milanmlft, #532)

## MISC

* Added @milanmlft as contributor

# sandpaper 0.14.1 (2023-11-09)

## BUG FIX

* `mailto:` links are no longer prepended with the URL (reported: @apirogov,
  #538; fixed: @zkamvar, #539)

# sandpaper 0.14.0 (2023-10-02)

## NEW FEATURES

* all internal folders can contain the standard `files`, `fig`, and `data`
  folders with the cautionary note that duplicate file names to other folders
  will cause an error.
- `validate_lesson()` now reports invalid elements of child documents
- A new vignette `vignette("include-child-documents", package = "sandpaper")`
  demonstrates and describes the caveats about using child documents.

## BUG FIX

* overview child files are no longer built as if they are top-level files.

## MISC

* R Markdown episodes with further nested child documents (grand children and
  beyond) will now trigger an episode to rebuild (fixed: @zkamvar, #513)
* Child file detection functionality has been moved to the {pegboard} package

## DEPENDENCIES

* {pegboard} minimum version is now 0.7.0

# sandpaper 0.13.3 (2023-09-22)

## BUG FIX

* References to heading in `setup.md` will now be reflected in the website. 
  (reported: @tobyhodges, @fnattino, and @zkamvar, #521; fixed: @ErinBecker and
  @zkamvar, #522). 
- A regression from #514 where empty menus would cause a failure in deployment
  with the 404 page has been fixed (reported: @tobyhodges and @zkamvar, #519;
  fixed: @zkamvar, #520).

# sandpaper 0.13.2 (2023-09-20)

## BUG FIX

* Users with duplicated `init.defaultBranch` declarations in their git config
  will no longer fail the default branch check (reported: @tesaunders, #516;
  fixed: @zkamvar, #517)

# sandpaper 0.13.1 (2023-09-19)

## BUG FIX

* Aggregate pages will no longer fail if an episode has a prefix that is the
  same as that aggregate page (e.g. `images.html` will no longer fail if there
  is an episode that starts with `images-`) (reported: @mwhamgenomics, #511;
  fixed: @zkamvar, #512)
* 404 page index link will point to the default index page of the site instead
  of the relative index page, which would result in a 404 for nested links that
  did not exist (reported: @kaijagahm and @zkamvar, #498; fixed @zkamvar, #514)

# sandpaper 0.13.0 (2023-09-06)

## NEW FEATURES

* Overview style lessons that do not have episodic content can now be processed,
  analysed, and built by {sandpaper}. To make your lesson an overview lesson,
  you can add `overview: true` to your `config.yaml` (reported: @zkamvar,
  https://github.com/carpentries/workbench/issues/65; 
  implemented: @zkamvar, #496)
* The new `spoiler` class of fenced div will allow authors to specify an
  expandable section of content that is collapsed by default. This replaces the
  former paradigm of using "floating solution" blocks to present options for
  installation on different platforms. (implemented: @tobyhodges, #502)

## BUG FIX

* Internal function `root_path()` will no longer fail if the `episodes/` folder
  does not exist as long as one of the other four folders (`site/`, `learners/`,
  `instructors/`, `profiles/`) exists (fixed: @zkamvar, #496)
* `set_config()` can now properly process logical values into `true` and `false`
* R Markdown documents with modificiations to child documents will now take into
  account changes to the child documents (reported @jcolomb, #497; fixed
  @zkamvar, #498). 
* A broken test from the development version of {renv} fixed. This was a change
  in output and not functionality, so there will be no user-visible changes
  (reported: @zkamvar, #484; fixed: @zkamvar, #487).
* Broken snapshot tests from upstream R-devel have been fixed by ensuring that
  version comparisons always use characters and not numbers (which is
  ergonomically weird, but whatever) (reported: @zkamvar #487; fixed: @zkamvar
  #487)
* Blank instructor notes pages no longer fail to build 
  (reported: @apirogov, #505; fixed: @klbarnes20, #509)
* Tests for {renv} post 1.0.0 fixed so that they no longer run forever
  interactively (reported: @zkamvar #500; fixed: @zkamvar, #501)

## MISC

* We are now testing against pandoc 2.19.2 in continuous integration.
* The discussion list link for the new lesson contributing template has been
  fixed.
* examples have been modified to not use R Markdown lessons unless necessary,
  reducing output and time needed to build the examples.

## CONTINUOUS INTEGRATION

* The README file has been updated to fix a typo.


## DEPENDENCIES

* {pegboard} minimum version is now 0.6.0
* {varnish} minimum version is now 0.3.0

# sandpaper 0.12.4 (2023-06-16)

## BUG FIX

* A bug in walled systems where templated pages (e.g. 404) could not be written
  due to permissions issues has been fixed (reported: @ocaisa, #479; fixed:
  @zkamvar, #482).

# sandpaper 0.12.3 (2023-06-01)

## BUG FIX

* A bug where the git credentials are accidentally changed when a lesson is
  built is fixed by no longer querying git author when the lesson is built.
  (reported: @joelnitta, @velait, and @zkamvar, #449; fixed: @zkamvar, #476).

# sandpaper 0.12.2 (2023-05-29)

## BUG FIX

* A bug where the sidebar for non-episode pages had extra commas was fixed
  (reported: @zkamvar, #473; fixed: @zkamvar, #474)

# sandpaper 0.12.1 (2023-05-26)

## BUG FIX

* The current page of the sidebar no longer hides the episode number. 
  (reported: @cynthiaftw, https://github.com/carpentries/workbench/issues/42 and
  #432; fixed: @zkamvar, #472)
- metadata for episodes with titles containing markup no longer include that
  markup in the metadata (@zkamvar, #472)

## MISC

* The internal function `sandpaper:::check_pandoc()` now points to the correct
  URL to download RStudio, which moved after the migration to posit (@zkamvar,
  #471) 

# sandpaper 0.12.0 (2023-05-19)

## NEW FEATURES

* Aggregate instructor notes now have headings that link back to the source
  instructor note (reported: @tobyhodges, #463; fixed: @zkamvar, #468)
* The internal function `sandpaper:::render_html()` now explicitly sets the
  pandoc version before running the subprocess. This allows lesson developers to
  use the {pandoc} package to set their pandoc versions. (reported: @zkamvar,
  #465; fixed: @zkamvar, #465)

## BUG FIX

* Callout block anchor links now point to the correct ID of the block derived
  from the title of the block (as opposed to the generic ID). 
  (reported: @debpaul, 
  https://github.com/datacarpentry/OpenRefine-ecology-lesson/issues/292 and
  @bencomp, #454; fixed: @zkamvar, #467).
* Inline images no longer automatically transform to figure blocks
  (reported: @ostephens, #445; fixed: @zkamvar, #446). This bug was preventing
  image links (e.g. MyBinder badges) from being rendered as links with images
  in them. This fixes that issue. It also helps distinguish inline images
  between figures in the DOM.

# sandpaper 0.11.17 (2023-05-16)

## NEW FEATURES

* `sandpaper::serve()` gains the `quiet` argument, defaulting to `TRUE` for
  interactive sessions and `FALSE` for command line sessions 
* `sandpaper::serve()` gains the `...` argument to pass options to 
  `servr::server_config()` for setting ports and hosts (reported:
  @twrightsman, https://github.com/carpentries/workbench/issues/50 and #459;
  fixed: @zkamvar, #461).

## BUG FIX

* Break timing is now included in the overall schedule. (reported: @karenword,
  #437; fixed: @bencomp, #455).


## TEST SUITE

* An upstream feature in {renv}, forcing it to be silent when testing caused
  some expectations to fail. This has been fixed in specific tests by turning
  verbosity on in those tests (reported: @zkamvar, #457; fixed: @zkamvar, #458)

# sandpaper 0.11.16 (2023-05-05)

## BUG FIX

* A failure to incrementally build the lesson with `sandpaper::serve()` has been
  fixed (reported: @zkamvar, #450; fixed: @zkamvar, #451)

## MISC

* Lessons with markdown documents no longer use `callr::r()` as an intermediary
  (reported: @zkamvar, #442, fixed: @zkamvar, #452)

# sandpaper 0.11.15 (2023-04-05)

## BUG FIX

* The 404 page will now have proper styling applied when the site is deployed
  via one of the `ci_` functions (reported: @zkamvar, #430; fixed: @zkamvar,
  #431).
* `sandpaper::serve()` will no longer error if a different directory is used.

# sandpaper 0.11.14 (2023-04-04)

## BUG FIX

* A 404 page has been added (reported: @fmichonneau, #268; fixed: 
  @zkamvar, #429)

## DEPENDENCIES

* The minimum version of {pegboard} has been set to 0.5.1

## TEMPLATES

* The README, LICENSE, CONTRIBUTING, and SETUP templates have been fixed to work
  with {pegboard} version 0.5.1
* The LICENSE and CONTRIBUTING templates now refer to The Carpentries as a
  whole and provides correct links to community forums. 

# sandpaper 0.11.13 (2023-03-25)

## WORKAROUND

* Fix an issue for {renv} version 0.17.2 where it was unable to provision
  packages that were being used in the parent environment. This was a problem
  in environments where the version of {sandpaper} was controlled by {renv}. 
  (reported: https://github.com/rstudio/renv/issues/1177, @zkamvar; fixed
  #423, @zkamvar). Note that this fix is ONLY applicable to {renv} 0.17.2
  and will be fixed with newer versions of {renv}.

# sandpaper 0.11.12 (2023-03-22)

## CONTINUOUS INTEGRATION

* workflow files now have explicit permissions to comment on pull requests or
  create new branches when called. This fixes an issue where new lessons would
  not have the ability to preview pull requests or update workflows.
  (reported: #420, @zkamvar; fixed #421, @zkamvar)
* the `create-pull-request` action is now coming from a fork in The Carpentries
  organisation for security. 

## MISC

* A typo has been fixed in the package cache vignette
- The CONTRIBUTING boilerplate has been updated to fix formatting issues

# sandpaper 0.11.11 (2023-03-17)

## BUG FIX

* `update_cache()` will now work with {renv} version 0.17.1, which lost a
  print method for the `renv_updates` class (reported: @zkamvar, #415; 
  fixed: @zkamvar, #416 and 
  https://github.com/zkamvar/vise/commit/ee4798701a958ee48429980eb970266885f8265b

## MISC

* @jcolomb has been added as a contributor in the DESCRIPTION.

# sandpaper 0.11.10 (2023-03-16)

## BUG FIX

* New lessons will now provision `learners/resources.md`, which will allow the
  glossary link to work (reported: @elichad, #404 and 
  @ManonMarchand,
  https://github.com/carpentries/workbench-template-md/issues/20; 
  fixed: @zkamvar, #410)
- default CONTRIBUTING file is better suited to The Workbench and no longer
  references the now-defunct lesson-example repository (reported and fixed:
  @jcolomb, #407)

# sandpaper 0.11.9 (2023-03-14)

## BUG FIX

* Links to assets in instructor view no longer render a 404. (reported:
  @brownsarahm, #404; fixed: @zkamvar, #409)

## CONTINUOUS INTEGRATION

* Lessons with files that have spaces in their names (e.g as a learning tool)
  no longer fail to comment on pull request previews (reported: @zkamvar, #399;
  fixed: @zkamvar, #400)

# sandpaper 0.11.8 (2023-03-09)

## BUG FIX

* Excessive output from `renv::diagnostics()` during building of R Markdown
  documents has been suppressed.

# sandpaper 0.11.7 (2023-03-09)

## MISC INTERNAL FIXES

* We now build {sandpaper} against the development version of {renv} to avoid
  bugs that come from {renv} version 0.17.0. See #406 for details.
* The internal function `message_package_cache()` no longer fails with {renv}
  version 0.17.0.

# sandpaper 0.11.6 (2023-02-15)

## NEW FEATURE

* blank or character timing estimates (e.g. XX) will now be treated as unknown
  and an estimate of 5 minutes will be used for each missing element. A 
  warning will be issued listing which episodes have missing timings.
  (reported: @zkamvar, #395; fixed: @zkamvar, #396)

## BUG FIX

* `manage_deps()` will now attempt to recover errors from "missing" bioconductor
  packages. Note that this is a provisional solution because it treats
  BioConductor packages as an afterthought. The full fix for this should be
  when {renv} bootstraps BioConductor repositories (reported: @zkamvar, #365 and
  https://github.com/rstudio/renv/issues/1110; fixed: @zkamvar, #397)

# sandpaper 0.11.5 (2023-02-09)

## BUG FIX

- `update_cache()` and `pin_version()` will now find the root path of the
  lesson before checking and manipulating dependencies. This will circumvent
  the issue where a user could accidentally create a `episodes/renv` folder by
  running `update_cache()` from the `episodes/` directory (discovered:
  @sarahkaspar; reported: @zkamvar, #391; fixed: @zkamvar, #392).

# sandpaper 0.11.4 (2023-01-26)

## BUG FIX

- The setup page will always be provisioned for lessons regardless if it
  exists in the `learners:` field in `config.yaml`
  (reported: @zkamvar, #386; fixed: @zkamvar #387).

## PANDOC

- This updates {sandaper} to be used by pandoc version 3, which no longer
  implements the `pandoc.Null()` constructor for Lua filters (reported:
  @zkamvar, #380; fixed: @zkamvar: #385)

# sandpaper 0.11.3 (2022-12-16)

## CONTINUOUS INTEGRATION

- Pull Request workflows will now automatically cancel if several commits are
  sent in succession. Specifically, the workflows `pr-recieve.yaml` and
  `pr-comment.yaml` are given separate `concurrency` parameters based on the
  branch name and the pull request number. These concurrencies will prevent
  false alarms as found in
  [https://github.com/carpentries/lesson-development-training/pull/165#issuecomment-1337182275](https://github.com/carpentries/lesson-development-training/pull/165#issuecomment-1337182275).
  (discovered: @anenadic; reported: @zkamvar, #374; fixed: @zkamvar, #376)

# sandpaper 0.11.2 (2022-12-06)

## MISC

- The `create_syllabus()` function no longer uses `pkgdown::as_pkgdown()` and
  assumes a flat file structure when creating the syllabus. This provides a
  further fix for #371.
- The downlit shim has been updated to modify the function bodies while
  preserving the function signatures.

- workflows for testing on Windows has been fixed by setting the git config
  `autocrlf` to `false` before checkout (thanks to @assignUser for the tip).
- The test coverage workflow has been updated to avoid long build times.

# sandpaper 0.11.1 (2022-12-05)

## BUG FIX

- A bug in deployment where GitHub deployments fail due to an error that says
  "Error: Can't find DESCRIPTION" has been fixed (reported: @tobyhodges, #371;
  fixed, @zkamvar, #372)

## MISC

- code inside of main `build_` functions cleaned up. Unused variables removed
  and narrative comments added to provide context.

# sandpaper 0.11.0 (2022-12-01)

- Documentation for internal storage objects updated.
- Page progress indicators reflect estimated percentage progress through the
  lesson based on the timings recorded in each episode as opposed to fraction
  of pages (reported: anonymous, #369; fixed @zkamvar, #370).

# sandpaper 0.10.8 (2022-11-15)

## MISC

- schedule/syllabus timings are now displayed as XXh XXm to clarify the scope of
  the timing (requested: @tobyhodges, #361; fixed @zkamvar, #363).
- Documentation for automated pull requests updated to reflect bots should have
  `public_repo` scope.

## BUG FIX

- A bug where the index page title was the same for both instructor and learner
  view has been fixed (reported: @tobyhodges, #361; fixed @zkamvar, #366)

# sandpaper 0.10.7 (2022-11-02)

## CONTINUOUS INTEGRATION

- pandoc is now set to use the default version for r-lib/setup-pandoc (at the
  time of this update, it is version 2.19.2.
- Workflows that update workflows and packages will now push to single branches
  called `update/workflows` and `update/packages`, respectively. This will avoid
  the issue with #350

- Workflows no longer use the deprecated `set-output` command (reported:
  @zkamvar, #349; fixed @zkamvar, #356)
- Versions of external actions have been updated to include `actions/core@1.10.0`

# sandpaper 0.10.6 (2022-10-25)

## NEW FEATURES

- Interactive functions to modify lesson structure (`move_episode()`,
  `set_episode()`, etc) will now display a message if the user does not specify
  `write = TRUE`. This message will present a command that, when executed, will
  make the desired change (requested: @tobyhodges, #345, fixed: @zkamvar, #352)

# sandpaper 0.10.5 (2022-10-24)

## MISC

- The the `source` config parameter will have the trailing `/` trimmed off when
  passed to the site so that the URL does not have two consectutive slashes.

# sandpaper 0.10.4 (2022-10-07)

## BUG FIX

- `renv/sandbox` no longer required in `.gitignore`. A new bug introduced in
  0\.10.2 caused all lessons built before 0.10.2 to fail when rebuilt on CI.
  This was due to the assumption that the .gitignore item `renv/sandbox` was
  strictly necessary with no clear method to automatically update a file like
  this (reported: @zkamvar, #347; fixed: @zkamvar, #348).

# sandpaper 0.10.3 (2022-10-05)

## BUG FIX

- An accidental commit of `sandpaper-version.txt` in version 0.8.0 inside the
  workflow templates folder was causing workflow update script to create pull
  requests for the workflows every week when they should have been much less
  frequent (the irony of this commit is that it will trigger another pull
  request) (fixed: @zkamvar, #346).

# sandpaper 0.10.2 (2022-10-04)

## BUG FIX

- The default `.gitignore` now has `renv/sandbox` to avoid a sandbox directory
  from being tracked by git. (see [https://github.com/rstudio/renv/issues/1088](https://github.com/rstudio/renv/issues/1088))
  (reported: @zkamvar; #344, fixed: @zkamvar, #343)

## CONTINUOUS INTEGRATION

- The `deploy-aws.yaml` workflow has been removed as plans for its use is
  relegated to the beta stage of the workbench.

# sandpaper 0.10.1 (2022-09-28)

## NEW FEATURES

- If the `index.md (or Rmd)` file has a `title` YAML element, this will take
  precedence over the default title of "Summary and Setup".
  (requested: @SaraMorsy, #339; fixed: @zkamvar #342)

## BUG FIX

- Titles in navigation bar now have Markdown parsed correctly.

# sandpaper 0.10.0 (2022-09-19)

## NEW FEATURES

- The default behavior of `create_episode()` and `create_lesson()` is to use
  episodes *without* numbered prefixes and will now automatically add episodes
  to the schedule (requested: @tobyhodges, #330; fixed @zkamvar, #333)
- New function `move_episode()` allows the lesson contributor to move an episode
  in the schedule (requested: @tobyhodges, #330, fixed: @zkamvar, #333)
- New functions `draft_lesson_md()` and `draft_lesson_rmd()` perform the task of
  `create_lesson(add = FALSE)`.
- Helper function `strip_prefix()` will automatically strip the prefixes for all
  episodes in the schedule.

## BUG FIX

- `get_config()` now has a default `path` argument.
- A bug where anchors for callout headings with generic names (e.g. "discussion"
  or "keypoints") were missing was fixed.

# sandpaper 0.9.6 (2022-09-15)

## BUG FIX

- A minor bug is fixed. It originated from the most recent update in {cli}
  where newlines in a span are collapsed. This will fix (reported: @zkamvar,
  \#336; fixed @zkamvar #337)

## DEPENDENCIES

- The minimum version of CLI has been updated to version 3.4.0

## CONTINUOUS INTEGRATION

- Pull request response workflows have been updated to make sure their
  conditionals do not always default to TRUE (see
  [https://github.com/carpentries/actions/pull/56](https://github.com/carpentries/actions/pull/56))

# sandpaper 0.9.5 (2022-08-30)

- css and js can now be embedded into individual pages for custom styling
  (see [https://bookdown.org/yihui/rmarkdown-cookbook/html-css.html](https://bookdown.org/yihui/rmarkdown-cookbook/html-css.html) for
  implementation details).
- The pandoc extension `link_attributes` has been added to process custom link
  classes (see [https://pandoc.org/MANUAL.html#extension-link\_attributes](https://pandoc.org/MANUAL.html#extension-link_attributes) for
  details).

# sandpaper 0.9.4 (2022-08-26)

- The CLI styling of an important message about {renv} has been fixed to be more
  readable (reported: @zkamvar, #331; fixed: @zkamvar, #332).
- The bioschemas metadata version has been updated to 1.0
  (reported: @zkamvar, #329; fixed @zkamvar, #332).

# sandpaper 0.9.3 (2022-08-12)

## MISC

- A test that was failing on the R-universe has been skipped
- documentation has been updated to detail the expected and optional values in
  config.yaml in `set_dropdown()`
- The template for the code of conduct has been updated to reflect our style guide

# sandpaper 0.9.2 (2022-08-09)

## CONTINUOUS INTEGRATION

- The version of the s3-sync action has been corrected. This only affects lessons
  that deploy to AWS

# sandpaper 0.9.1 (2022-08-09)

## MISC

- Anchor links are now included in all sections and callouts for easy navigation
  to sections. Thanks to @fiveop and @anenadic for requesting this feature.
  requested in #285 and [https://github.com/carpentries/workbench/issues/28](https://github.com/carpentries/workbench/issues/28);
  fixed in #325

# sandpaper 0.9.0 (2022-07-12)

## MISC

- `set_config()` gains the option `create`, which will create new variables if
  they do not exist.

## CONTINUOUS INTEGRATION

- A new workflow called `deploy-aws.yaml` has been created to deploy a site to
  AWS when the right secrets from AWS are available. Because this workflow
  does not affect normal use, I am relegating this to a patch release.

# sandpaper 0.8.0 (2022-07-06)

## CONTINUOUS INTEGRATION

- A new workflow called `pr-preflight.yaml` has been created to perform a quick
  pre-flight check on the pull request to ensure that there is no malicious
  activity on the lesson itself, which may look like modifying both workflow
  and lesson files in the same pull request. For lessons that transition to the
  workbench from styles in official and community-developed lessons, an extra
  check is added that will validate the branch of the incoming PR does not
  contain invalid commits.

- Pull Request workflows have been simplified.

# sandpaper 0.7.1 (2022-07-05)

## BUG FIX

- A bug where `fail_on_error` defaulted to `true` has been fixed. This will
  default to `false` if they key is not present in `config.yaml` (#314, @zkamvar).

# sandpaper 0.7.0 (2022-07-01)

## NEW FEATURE

- Placing `fail_on_error: true` in `config.yaml` will set the global chunk
  option `error = FALSE` for R Markdown documents, meaning that if an error
  is produced from a chunk, the build will fail unless that chunk explicitly
  uses the `error = TRUE` option. (requested: #306 by @davidps, implemented:
  \#310 by @zkamvar)

# sandpaper 0.6.2 (2022-06-24)

## BUG FIX

- The sidebar navigation in mobile and tablet views now includes all the
  information that was included in the navigation bar for the desktop mode.
  (reported: [https://github.com/carpentries/workbench/issues/16#issuecomment-1165307355](https://github.com/carpentries/workbench/issues/16#issuecomment-1165307355) by @Athanasiamo and #306, fixed: #309 by @zkamvar)
- the downit shims have been updated to be resiliant to upstream changes

# sandpaper 0.6.1 (2022-06-22)

## MISC

- the `config.yaml` template has been updated to default to incubator lessons
  and has more helpful information included about formatting (@tobyhodges, #302)

# sandpaper 0.6.0 (2022-06-10)

## NEW FEATURES

- `create_lesson()` gains the `rmd` parameter, which is a logical indicator that
  the lesson should use R Markdown (`TRUE` by default). When this is `FALSE`, a
  markdown lesson is created and no package cache is initialised.
- `create_episode()` gains the `ext` parameter, which allows users to create
  plain markdown episodes if they do not need R Markdown functionality
  (see [https://github.com/carpentries/sandpaper/issues/296](https://github.com/carpentries/sandpaper/issues/296)).

## BUG FIX

- `create_episode()` will now slugify titles so that they only contain lowercase
  ASCII letters, numbers and UTF-8 characters with words separated by single
  hyphens (see [https://github.com/carpentries/sandpaper/issues/294](https://github.com/carpentries/sandpaper/issues/294)).

## MISC

- The internal `check_episode()` function has been removed as it was over-
  engineered with marginal value.

# sandpaper 0.5.8 (2022-06-06)

## CONTINUOUS INTEGRATION

- Running the main workflow from GitHub's actions tab now uses a checkbox to
  indicate if the markdown file cache should be cleared.
- The README file for the workflows no longer contains a link to an image that
  does not exist.

# sandpaper 0.5.7 (2022-05-27)

## CONTINUOUS INTEGRATION

- Workflows that update lesson elements will now report a more obvious summary
  of next steps to take with an invalid token (see [https://github.com/carpentries/actions/pull/45](https://github.com/carpentries/actions/pull/45))

# sandpaper 0.5.6 (2022-05-25)

## CONTINUOUS INTEGRATION

- Pull requests will now report on elements of the lesson that do not pass
  checks.

# sandpaper 0.5.5 (2022-05-23)

## MISC

- New YAML items can now be added at-will and will be available to varnish in
  a `{{#yaml}}` context.
- internal function `set_dropdown()` will preserve the yaml items that are not
  explicitly coded in the config menu.

# sandpaper 0.5.4 (2022-05-18)

## BUG FIX

- `build_episode_md()` argument `workenv` now defaults to `globalenv()` to avoid
  S3 dispatch issues that can occur in `new.env()` (see [https://github.com/carpentries/sandpaper/issues/288](https://github.com/carpentries/sandpaper/issues/288))

# sandpaper 0.5.3 (2022-05-18)

## BUG FIX

- Episodes with ampersands in their titles no longer break the aggregate page
  building.

# sandpaper 0.5.2 (2022-05-16)

## TEMPORARY BUG FIX

- {downlit} shim has been updated to no longer fail when parsing BASH globs.
  (see [https://github.com/r-lib/downlit/pull/138](https://github.com/r-lib/downlit/pull/138))

# sandpaper 0.5.1 (2022-05-03)

## NEW FEATURES

- The sidebar now enumerates episodes so it is easier for instructors and
  learners to indicate episode by number instead of by name (suggested by
  @fiveop in #276). (@zkamvar, #277)

## NEW SUGGESTS

- {mockr} is now a suggested package (aka soft-dependency) to facilitate testing
  functions that do not need an entire lesson set up to test their functionality

## CONTINUOUS INTEGRATION

- `setup-r` and `setup-pandoc` actions have been pinned to version 2
- `setup-r` action now uses the default R installation on GitHub's runner,
  which decreases build times by ~ 1 minute.
- All R actions will use the RStudio Package Manager, which should avoid overly
  lengthy build times.
- explicit permissions have been set for the deploy workflow (@zkamvar, #279)

# sandpaper 0.5.0 (2022-04-22)

## NEW FEATURES

- `images.html` is built with internal function `build_images()`, collecting
  all images and displaying alt text for non-screen reader users (while
  marking those paragraphs as `aria-hidden` so that screen reader users do not
  have it read twice).
- `instructor-notes.html` is now built with the internal function
  `build_instructor_notes()` and now collects instructor notes from the
  episodes in a section called `aggregate-instructor-notes`.

## MISC

- The internal `build_agg_page()` has a new argument, `append`, which takes an
  XPath expression of what node should have children appended. Defaults to
  `"self::node()"`. An example of alternate usage is in
  `build_instructor_notes()`, which uses
  `section[@id='aggregate-instructor-notes']`.

# sandpaper 0.4.1 (2022-04-21)

## MISC

- The All in One page and Keypoints page have been redesigned. These now both
  use the underlying internal function `build_agg_page()` (build aggregate
  page). This allows slow templating processes to be performed once and cached
  instead of repeated for each page. It provides a framework for future
  aggregate pages (such as figures, instructor notes, glossary, etc).
- A message is now printed when Keypoints and All-in-one pages are written to
  disk if `quiet = FALSE`.

# sandpaper 0.4.0 (2022-04-13)

## NEW FEATURES

- An all-in-one page is now available for lesson websites at `/aio.html` and
  `instructor/aio.html`.

## MISC

- Provisioning of the global lesson element cache (metadata, AST, and global
  variables for varnish) is now all executed via `this_lesson()`, which is run
  during `validate_lesson()`. This simplifies the setup a bit, and provides the
  same method of cache invalidation (checking git outputs) for all of these
  elements

# sandpaper 0.3.6 (2022-04-09)

## MISC

- custom sandpaper and varnish engines will be properly linked to the footer
  of the lesson pages via this version and varnish 0.1.8.
- testthat tests have been updated.
- a diagram in the vingettes has been updated to reflect the parallel roles of
  sandpaper and pegboard to a lesson.

# sandpaper 0.3.5 (2022-03-04)

## BUG FIX

- `keypoints.html` is now rendered as `key-points.html` to fix navigation error
  with varnish.

# sandpaper 0.3.4 (2022-03-02)

## CONTINUOUS INTEGRATION

- pr-receive.yaml has been updated to not report errors for workflow updates.
  See [https://github.com/carpentries/sandpaper/issues/263](https://github.com/carpentries/sandpaper/issues/263) for details

# sandpaper 0.3.3 (2022-02-28)

## BUG FIXES

- Links from the index page to the setup or any episodes now correctly render
- Links to the setup page now redirect to `index.html#setup` (@zkamvar, #262)
- The setup page is now included in the instructor view after the schedule
- The setup in the index page is now a separate section with the id "setup"
- The schedule in the instructor index page is now in a separate section with
  the id "schedule"

## DEPENDENCIES

- The minimum version of {varnish} required is now 0.1.5

## CONTINUOUS INTEGRATION

- A small bug in the update cache workflow that caused a silent error with no
  detremental effect was fixed (@zkamvar, #250)

# sandpaper 0.3.2 (2022-02-25)

## DEPENDENCIES

- The minimum version for {pegboard} should be at least 0.2.3 to accomodate
  div validation (@sstevens2, #259)
- The minimuim version for {varnish} should be at least 1.5.0.

# sandpaper 0.3.1 (2022-02-23)

## BUG FIXES

- Documents with footnotes without trailing newlines will now parse the external
  links correctly by adding a newline between the document and the links.

# sandpaper 0.3.0 (2022-02-22)

## NEW FEATURES

- Common links for markdown lessons can be included via a file at the top of the
  lesson called `links.md`. If this file exists, it will be concatenated on each
  markdown file before it is rendered to HTML. Thanks to @sstevens2 for bringing
  this feature up (@zkamvar, #257)
- `create_lesson()` now includes `links.md` in main directory.
- A new help page called `?sandpaper.options` provides documentation on the
  global options used in a sandpaper lesson (subject to change).

# sandpaper 0.2.0 (2022-02-18)

## NEW FEATURES

- `validate_lesson()` will perform checks on links and fenced divs in your
  lesson. This is now included in calls to `build_lesson()`, `ci_deploy()` and
  `serve()` (@zkamvar, #255)

## DEPENDENCIES

- the minimum pegboard version is now 0.2.0

## BUG FIXES

- internal function `this_lesson()` will now properly invalidate and reset if
  there is a change in commit (e.g. the lesson to build has switched).

# sandpaper 0.1.6 (2022-02-14)

## BUG FIX

- `set_dropdown()` no longer fails with {cli} version 3.2.0

# sandpaper 0.1.5 (2022-02-11)

## INTERNAL

- metadata is now processed more consistently across page types, which will
  first and foremost reduces some of the code complexity, and second, allows
  for more rapid development of future page types. In some instances, this will
  result in a marginal improvement of build times, but it will not likely be
  noticable.

# sandpaper 0.1.4 (2022-02-10)

## BUG FIX

- `sandpaper::build_lesson()` no longer creates an infinite loop when called
  after `sandpaper::serve()` (@zkamvar, #247)

# sandpaper 0.1.3 (2022-02-03)

## MISC

- Clarify license information to specify the copyright is held by The Carpentries

# sandpaper 0.1.2 (2022-02-02)

## BUG FIX

- invalid sitemaps have been fixed to have the correct namespace and include a
  slash in the site name.
- a test requring pandoc 2.11 has been suppressed on systems without that
  version of pandoc.

# sandpaper 0.1.1 (2022-02-01)

## DEPENDENCIES

- The {pegboard} package is now required to be 0.1.0 or greater due to a fix for
  generating the keypoints page ([https://github.com/carpentries/pegboard/pull/76](https://github.com/carpentries/pegboard/pull/76))

## METADATA

- The metadata included in the lesson footer now correctly states the `@type`
  as `TrainingMaterial` (@zkamvar, #236)
- A basic sitemap is now constructed for the lesson (@zkamvar, #243)

## BUG FIX

- Empty pages will no longer throw errors in rendering and they will not be
  included in the output (@zkamvar, #237)

# sandpaper 0.1.0 (2022-02-01)

## BUG FIXES

- the internal function `render_html()` now passes the `--preserve-tabs`
  parameter to prevent pandoc from removing educationally relevant information
  from the lessons.
- when rebuilding a lesson with `ci_deploy(..., rebuild = TRUE)`, detritus in
  the lesson site will be cleaned (@zkamvar, #91).

## BREAKING CHANGES

- Add support for the updated frontend in {varnish}. This means that you will
  need varnish 0.1.0 installed in order to use this update. This change includes
  modifications to the lua filters along with the general handling of the HTML
  elements which means that older versions of varnish will cease to work.
- code blocks will no longer contain package links. While the links may have
  been handy for sighted users to explore documentation, these may represent
  objstructions for users who rely on screen-readers.

## INSTRUCTOR VIEW

There are now two views of the lesson: instructor view and learner view. The
biggest difference is that instructor view gains the `instructor-note` sections
(if they exist).

- Static pages for each view. This means that you can toggle between the pages
  without needing javascript.
- Removed timings on the learner view (to avoid discouraging our learners)
- Setup page replaces the schedule on the index page
- There are additional buttons included on the instructor view that do not yet
  work, but will work at some point!

The only downside at the moment is that building the lesson takes *a bit* longer
due to the fact that we now have to render two pages for each change.

## NAVIGATION

A persistant sidebar with links for the main content of the lesson will be
present on all pages of the lesson. The navigation bar will prioritise items
used most frequently by the respective audiences:

- Learners: Key Points, Glossary, Learner Profiles, "Additional Information"
  (dropdown)
- Instructors: Key Points, Instructor Notes, Extract All Images, "More"
  (dropdown)

## MISC

- The build database now gains a "date" column which will indicate the date
  the file was last rendered to markdown. This allows the "last updated on" to
  better reflect the state of the contents from the rendered files.
- The default configuration file now includes a `keywords:` item where you can
  place a comma-separated list of keywords to include in the site's metadata
- The configuration file now also includes an example of what provisioned
  navigation looks like
- The default episode template now refers to the correct documentation links and
  provides examples of how to represent code blocks that are not evaluated.
- The setup page now contains a structured example setup page that shows how to
  provide dropdown menus for different operating systems (@zkamvar, #28).
- If the user does not have a github PAT and we can not detect the name of the
  repository from the git setup, then the source goes to an example.com link.

# sandpaper 0.0.0.9075

## BUG FIX

- Episodes with missing timing metadata will no longer fail if they also contain
  questions and objectives blocks. (@zkamvar, #222).

# sandpaper 0.0.0.9074

## BUG FIX

- Internal function `renv_cache_available()` continues to work with {renv}
  0\.15.0.  This new version of {renv} changed the default value of a
  configuration setting for the system cache from a logical to NULL, which
  casued a logical operation to fail. (@zkamvar, #223)

# sandpaper 0.0.0.9073

## DEPENDENCY UPDATE

- {renv} is pinned to version 0.14.0 as version 0.13.2 would throw an error when
  checking for consent.

# sandpaper 0.0.0.9072

## NEW FUNCTION

- `serve()` now allows you to work on your lesson and have it automatically
  rebuild whenever you save your files to disk.

## NEW DEPENDENCIES

- {servr} is now used in the `serve()` function.

# sandpaper 0.0.0.9071

## NEW FEATURE

- Lesson blocks are now treated the same as other blocks. This is a placeholder
  for us to better test the separation of the lesson veiw from the default
  learner view.

# sandpaper 0.0.0.9070

## BUG FIX

- Lessons that have readonly zlib compressed files (read: git objects) can now
  have their websites built. (@zkamvar, #214)

# sandpaper 0.0.0.9069

## MISC

- `build_handout()` is now an officially exported function.
- The pkgdown documentation has been updated

# sandpaper 0.0.0.9068

## CONTINUOUS INTEGRATION

- Workflows have been updated to use `ubuntu-latest` instead of `macOS-11`.
  The macOS runners were often ~ 1 minute faster than the ubuntu runners, but
  the tradeoff was potential failures when packages were not available as
  binary versions and would need compilation with external C libraries (along
  with runs failing due to brew timeouts). This update coincides with an update
  for the github actions, which will now check and install the ubuntu
  dependencies before updating/installing packages. (@zkamvar, #184)

# sandpaper 0.0.0.9067

## BUG FIX

- A situation where git would fail if it could not remove everything was fixed
  (#206, @zkamvar)
- Addressed CLI failures due to glue version 1.5.0
  ([https://github.com/r-lib/cli/issues/370#issuecomment-965496848](https://github.com/r-lib/cli/issues/370#issuecomment-965496848))

# sandpaper 0.0.0.9066

## API CHANGE

- `set_config()` now takes a named vector/list instead of a pair of vectors.

# sandpaper 0.0.0.9065

## NEW FEATURES

- `set_config()` will set singular items in the configuration file (@zkamvar, #193)

# sandpaper 0.0.0.9064

## BUG FIX

- Package discovery now respects the lesson environment, which was unfixed from
  0\.0.0.9063

# sandpaper 0.0.0.9063

## BUG FIX

- The package cache can now be built from external {renv} environments
  (@zkamvar, #197).

# sandpaper 0.0.0.9062

## BUG FIX

- New lessons that specify custom titles will have them reflected in the config
  file (@zkamvar, #195).

# sandpaper 0.0.0.9061

## BUG FIX

- lessons with colons in the title are now correctly processed (@zkamvar, #192)
- code injection in yaml is now protected against by setting `eval.expr = FALSE`
  in all yaml parsing calls.

# sandpaper 0.0.0.9060

## BUG FIX

- The title of the lesson will now appear in the index page.

## MISC

- The translation script no longer lives in the lesson repo and has been moved
  (and modified) to [https://data-lessons/lesson-transition/](https://data-lessons/lesson-transition/)

# sandpaper 0.0.0.9059

## CONTINUOUS INTEGRATION

- The scheduler for `update-cache.yaml` has been fixed to run strictly on the
  first Tuesday of the month instead of the first seven days of the month AND on
  Tuesdays.

# sandpaper 0.0.0.9058

## CONTINUOUS INTEGRATION

- `update-cache.yaml` has been simplified to pull from the carpentries/actions
  repository and now updates packages that were not previously included in the
  lockfile (#185).

# sandpaper 0.0.0.9057

## CONTINUOUS INTEGRATION

- `update-cache.yaml` has been fixed from a regression introduced with
  4b8b14d088d03a8a9c6c90e974bb53c35691fb49 where the workflow would not run
  because it did not check out the repository beforehand.

# sandpaper 0.0.0.9056

## BUG FIX

- `update_github_workflows()` now sets `clean = "*.yaml"` by default to align
  with the behavior of the GitHub workflow and to prevent stale workflows from
  being present in the repository. (#181, @zkamvar)

# sandpaper 0.0.0.9055

## CONTINUOUS INTEGRATION

- `sandpaper-main.yaml` and `pr-receive.yaml` have been simplified by using
  composite actions hosted in `carpentries/actions/setup-sandpaper` and
  `carpentries/actions/setup-deps`.
- The caching mechanism for R packages and the package cache can now be
  reset by modifying a per-repository secret called `CACHE_VERSION`.

## BUG FIX

- A bug introduced in 0.0.0.9054 where dependencies were not discovered was
  fixed.

# sandpaper 0.0.0.9054

## MISC

- `manage_deps()` runs slightly faster now that it no longer runs
  `renv::hydrate()` if no new packages have been added in the lesson.

# sandpaper 0.0.0.9053

## NEW FEATURES

- setting `option(sandpaper.handout = TRUE)` will create a code handout for R
  lessons that will live in `/files/code-handout.R` on your site.

## MISC

- An internal caching mechanism has been added for `pegboard::Lesson` objects
  that we use for extracting components for the syllabus and the handout. See
  `?lesson_storage` for details.

# sandpaper 0.0.0.9052

## CONTINUOUS INTEGRATION

- `pr-receive.yaml` has fixed spelling.
- `pr-receive.yaml` has changed to short-cut the invalid PR messages and no
  longer build the lesson if the PR is invalid. Instead, it will emit the same
  warning message without building artifacts.
- `pr-comment.yaml` will no longer fail when no artifacts exist (which would
  cause extraneous emails for users).

## DOCUMENTATION

- Documentation for test fixtures has been improved to include branch functions.

# sandpaper 0.0.0.9051

## MISC

The template for the pull request message reverts back to two-dot diff notation
between branches, which is temporary until #169 can be addressed. Linebreaks
within paragraphs have been removed to avoid github formatting them as
linebreaks.

# sandpaper 0.0.0.9050

This update for {sandpaper} brings in dependency management for lessons with
generated content which will make collaboration between these lessons much
easier and less invasive by establishing a package cache and lockfile via the
{renv} R package.

## DEPENDENCY MANAGEMENT

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

## NEW FEATURES

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

## CONTINOUS INTEGRATION

- unexported function `ci_deploy()` will now automatically check and set the
  git user and email.
- `sandpaper-main.yaml` and `pr-receive.yaml` have been updated to include
  the {renv} cache, but they will skip these steps for markdown lessons.
- `update-cache.yaml` is a new workflow that will update the package cache
  lockfile and create a pull request to trigger new builds if the lesson uses
  {renv}.
- `update-workflows.yaml` now produces more informative instructions for
  creating a repository secret.

## MISC

- some of the {callr} functions have been made non-anonymous and moved to a
  separate file so they could be tested independently.

## BUG FIX

- changes to `config.yaml` are now reflected on the lesson site without
  rebuilding (fixes #75)
- knitr option `root.dir` has been set to the output directory to avoid
  generated content from entering the source.

# sandpaper 0.0.0.9049

This is a placeholder for the testing of 0.0.0.9050.

# sandpaper 0.0.0.9048

## BUG FIX

- pandoc lua filter no longer errors on raw div HTML elements with no class
  (@zkamvar, #166)

# sandpaper 0.0.0.9047

## CONTINUOUS INTEGRATION

- The `update-workflows.yaml` workflow now checks if the `SANDPAPER_WORKFLOW`
  secret is valid. If not, it provides instructions for creating a new secret.

# sandpaper 0.0.0.9046

## CONTINUOUS INTEGRATION

- Weekly run pull requests now default to "weekly run" for "who triggered this
  pull request"

# sandpaper 0.0.0.9045

## CONTINUOUS INTEGRATION

- Weekly run has been added for the workflows action
- Actions have been updated to reflect the zkamvar -> carpenteries repository
  transfer (@zkamvar, #156)

# sandpaper 0.0.0.9044

## CONTIUOUS INTEGRATION

- The `update-workflow.yaml` parameters have been fixed to not use wildcards

## MISC

- `update_github_workflows()` gains a `clean` argument and now will print
  status reports at the end.

# sandpaper 0.0.0.9043

## CONTINUOUS INTEGRATION

- The `update-workflow.yaml` workflow has been updated to use the github action
  hosted on `zkamvar/actions` (soon to be transferred to The Carpentries account
- The names of the actions displayed on GitHub have been updated to be more
  descriptive.
- The script in `inst/scripts/update-workflows.sh` has been removed in favor of
  the github action.

# sandpaper 0.0.0.9042

## CONTINUOUS INTEGRATION

- An experimental `update-workflow.yaml` workflow has been created which will
  create a pull request that will update the workflows. It is still *very*
  experimental and it requires a scoped with repo and scope, but,
  nevertheless, the concept is currently valid.

# sandpaper 0.0.0.9041

## MISC

- `fetch_github_workflows()` has been renamed to `update_github_workflows()`
- github workflows are no longer downloaded from an external source; they
  now live in inst/workflows. This will reduce the internet connection
  requirements for setting up a lesson and testing sandpaper.
- `create_lesson()` now reports progress as it goes along
- tests were updated to use the fixtures

# sandpaper 0.0.0.9040

## CONTINUOUS INTEGRATION

- `ci_deploy()` gains the `reset` argument, which can be used to clear the
  cache for a clean build of the lesson.
- `ci_deploy()` now uses `ci_build_markdown()` and `ci_build_site()`,
  internally

# sandpaper 0.0.0.9039

## CONTINUOUS INTEGRATION

- `ci_session_info()` will report the session information, which will help
  clean up the workflow files.

# sandpaper 0.0.0.9038

## CONTINUOUS INTEGRATION

- Fix broken deploy process on continuous integration caused by attempting to
  fetch all branches in a shallow clone (@zkamvar, #142)

# sandpaper 0.0.0.9037

## CONTINUOUS INTEGRATION

- Output of `ci_bundle_pr_artifacts()` no longer escapes HTML-like output in
  the diff summary.
- remove {xml2} from explicit dependencies

# sandpaper 0.0.0.9036

## CONTINUOUS INTEGRATION

- Documentation for `git_worktree_setup()` has been added for future versions
  of the maintainer and future contributors.
- `ci_bundle_pr_artifacts()` is a new internal function that will create
  artifacts for GitHub to upload upon receipt of a pull request. This will
  replace clunky shell code that lived inside a YAML configuration file.
  (@zkamvar, #139)
- add {brio} to soft dependencies (for testing, but maybe could speed up???)

# sandpaper 0.0.0.9035

## CONTINUOUS INTEGRATION

- Tests for git operations were added to be more robust (@zkamvar, #137)
- new test fixtures for a local remote repository was added to aid the above
  git tests.

# sandpaper 0.0.0.9034

## NEW FEATURES

- Authors can now cross-link between files within the lesson as they appear in
  the lesson instead of trying to guess how the link would appear on the
  website. For example, if you wanted to reference `learners/setup.md` in
  `episodes/introduction.md`, you would write `[setup](../learners/setup.md)`
  and it will be automatically converted to the correct URL in the website
  (#43). This is still backwards compatible with the previous iteration of
  writing the flattened link (as it would appear on the website).

# sandpaper 0.0.0.9033

## NEW FEATURES

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

## MISC

- The internal `get_resource_list()` function has been modified to incorporate
  the features of `get_dropdown()`. This means that all `get_dropdown()`
  functions will only report the files in the dropdown menus that actually
  exist in the directory (#134).
- A persistant test fixture is now included to speed up testing time (#132 via
  \#134)

# sandpaper 0.0.0.9031

## MISC

- The {cli} package is now an official import of the package
- The warning message issued from the internal `warn_schedule()` function has
  been changed exclusively use cli messages and can be suppressed with
  `suppressMessages()`.
- The internal `sandpaper_cli_theme()` is used to style CLI messages.

# sandpaper 0.0.0.9030

## MISC

- A test that caused problems with a new version of {pegboard} was fixed

# sandpaper 0.0.0.9029

## MISC

- The internal database is updated to use relative instead of absolute paths.
  This fixes #129

# sandpaper 0.0.0.9028

## NEW IMPORTS

The {pingr} package is now being imported to check for online access, which will
marginally decrease data usage (@fmichonneau, #127).

# sandpaper 0.0.0.9027

## MISC

- `create_schedule()` (internal function) no longer uses pegboard's extensions
  for fixing reference links.

# sandpaper 0.0.0.9026

## MISC

- callout blocks with headers greater than h3 are now rendered properly and no
  longer forced to h3
- tests now clean up after themselves and no longer change the working directory
  by default
- {varnish} version bumped to 0.0.0.9005
- tests that require pandoc will be skipped if pandoc is not available
- tests for the presences of multiple files will use setequal instead of equal
  to allow for alternate sorting orders.

# sandpaper 0.0.0.9025

## DEPENDENCY UPDATE

- required {pegboard} has been bumped to version 0.0.0.9014
- {renv} and {sessioninfo} added to Suggested packages.

# sandpaper 0.0.0.9024

## BUG FIX

- `create_lesson()` will now enforce "main" or the default branch (if
  init.defaultBranch is set) as the default branch for the new lesson. It will
  also try to make the URL match the project name and user name (but the latter
  is limited to users who have GitHub PAT set up that {gh} recognises).

# sandpaper 0.0.0.9023

## BUG FIX

- `build_episode_md()` now sets the `knitr.pandoc.to` knit option to allow for
  the chunk option `fig.cap` to be rendered as a caption. This fixes #114.

## NEW FEATURES

- `set_dropdown()` is now generalized to set any item in the dropdown menu
  (though this will likely be wrapped into a better-named function for
  generalized editing).
- `system.file("transform.R", pacakge = "sandpaper")` points to a file that
  will be used for transforming styles-repo era lessons to sandpaper lessons.
- read/write cycles were reduced in markdown generation because we are no longer
  interfering with the manipulation of the files at this stage (and haven't been
  for a while now).

# sandpaper 0.0.0.9022

## BUG FIX

- `build_markdown(rebuild = TRUE)` now actually rebuilds the lesson
- Changing an episode suffix will no longer result in a build error. This was
  due to `build_markdown()` trying to clean *after* building the output instead
  of before. It's a situation of throwing the baby out with the bathwater. In
  any case, this fixes #102.

# sandpaper 0.0.0.9021

## BUG FIX

- the template will be initialized with ALL folders with placeholders inside
  of the `instructor/` and `profile/` menus. This fixes #103.

# sandpaper 0.0.0.9020

## BUG FIX

- the `set_*()` functions no longer mess up yaml lists in `config.yaml`. This
  fixes #53.

# sandpaper 0.0.0.9019

- The required version of {pegboard} has been bumped to 0.0.0.9012, which gives
  better error messages and allows us to read in {sandpaper} lessons with the
  Lesson object.

# sandpaper 0.0.0.9018

- The episode template has been rearranged slightly and given level 2 headers.

# sandpaper 0.0.0.9017

## ENGINE UPDATE

- The version of pandoc will be explicitly checked to ensure that the version
  used is at least 2.11.

# sandpaper 0.0.0.9016

## BUG FIX

- `create_episode()` with `make_prefix = FALSE` will no longer create episodes
  prefixed with `-` (see #93).

# sandpaper 0.0.0.9015

## NEW FEATURES

- `fetch_github_workflows()` will download and update the GitHub workflows from
  the Carpentries actions repository.
- `update_varnish()` will download and update the {varnish} styling package to
  your local repository.

# sandpaper 0.0.0.9014

## BUG FIX

- Episode order is retained in the HTML navigation (#85)
- index.md is recorded in the site/build/ directory, and thus in the md-pages
  branch on deployment.

## ENGINE UPDATE

The caching mechanism is now similar to that of {blogdown} where a database of
source files and their checksum hashes is kept and only the updated files are
built. This provides two advantages, the first is that we no longer have to peek
at the top of the files to check if they need to be updated and the second is
that we can keep the files in the right order (see #85)

Importantly, the workflow itself should not be affected, but there will be
changes in what gets displayed on the github diff of the md-outputs branch.

# sandpaper 0.0.0.9013

## NEW FEATURES

- In RStudio, the **knit button works** :tada: (fix #77; @zkamvar, #82)
- `sandpaper_site()` is a site generator function that allows {rmarkdown} to
  use the {sandpaper} machinery to build the site from
  `rmarkdown::render_site()`
- `build_site()` gains a `slug` argument that tailors the previewed content.
- `create_lesson()` will now create a blank `index.md` with `site: sandpaper_site` as the only YAML item.
- HTML accidentally rendered to the source directories are silently removed
  when the site is built. (fix #78, @zkamvar, #84)

# sandpaper 0.0.0.9012

## NEW FEATURES

- Inline and reference-based footnotes are now supported.

# sandpaper 0.0.0.9011

## BUG FIX

- Bare links and text emoji (e.g. :wink:) are now rendered (fix #67).
- Objectives and Questions headings will now no longer be rendered (fix #64).

# sandpaper 0.0.0.9010

## BUG FIX

- If `index.md` exists at the top level, it will be used instead of `README.md`
  for the lesson index page (fix #56).

# sandpaper 0.0.0.9009

## BUG FIX

- The lua filter responsible for creating the Objectives summary block at the
  beginning of episodes now uses native pandoc divs instead of HTML block shims.
  This ensures that the content is not corrupted by pandoc's section divs
  extension. This addresses issue #64
- All aside elements will be forced to have level 3 headers (this fixes an issue
  with pandocs --section-divs where it couldn't understand when an HTML block
  contained only the start of an aside tag and decided to end the section right
  after it.
- The Objectives and Questions blocks will no longer include their headers in
  the initial summary block.
- A bug introduced in version 0.0.0.9008 was fixed. This bug improperly used
  regex resulting in the accidental removal of cached rendered images. This
  fixes issue #49
- Rendered images now have the prefix of `{SOURCE}-rendered-` in the
  `site/built/fig/` subdir.

# sandpaper 0.0.0.9008

## BUG FIX

- files that were removed from the source are now also removed in the site/built
  directory. This fixes issue #47

# sandpaper 0.0.0.9007

- HTML will now be processed with pandoc lua filters that will do the following:
  
  - overview block will be constructed from the teaching and exercises metadata
    with the question and objectives blocks
  - instructor and callout divs will be converted to `<aside>` tags
  - divs without H2 level headers will have them automatically inserted
  - divs with incorrect level headers will have them converted to H2
  - only divs in our list of carpentries divs will be converted

- README updated to reflect API changes

# sandpaper 0.0.0.9006

Continuous integration functions added:

- `ci_deploy()` will build the markdown source and the site and commit them to
  separate branches, including information about their source.
- `ci_build_markdown()` will build the markdown source files and commit them
  to a separate branch, including information about the source commit.
- `ci_build_site()` will build the site directly from the markdown branch,
  bypassing re-rendering the markdown files.

Miscellaneous additions

- {dovetail} no longer in suggests
- new internal function `build_site()` compartmentalizes the conversion from
  markdown to html
- any files or folders named `.git` in the episodes directory will not be
  copied over to the website.

# sandpaper 0.0.0.9005

- sandpaper now requires and uses additional folders and files:
  - CODE\_OF\_CONDUCT.md
  - learners/Setup.md
  - instructors/
  - profiles/
  - LICENSE.md
- `_schedule()` functions have been renamed to `_episodes()`.
- `clean_*()` functions are now renamed to `reset_*()`
- Generic `set/get/reset_dropdown()` functions have been created to facilitate
  modification/access of folders that are dropdown menus inside of the lesson
- questionable practices with directories mucking about.
- `build_markdown()` will now generate artifacts in the `site/built/assets/`
  directory instead of `episodes/` directory to prevent generated artifacts from
  being included in git (See [https://github.com/carpentries/sandpaper/issues/24](https://github.com/carpentries/sandpaper/issues/24))

# sandpaper 0.0.0.9004

- Internal `html_from_md()` renamed to `render_html()`
- Internal `build_episode()` renamed to `build_episode_html()` and exported,
  but documentation still internal
- Internal `build_single_episode()` renamed to `build_episode_md()` and exported,
  but documentation still internal

# sandpaper 0.0.0.9003

- A regression in `build_markdown()` due to being called in a separate process
  was fixed.
- Internal functions for setting {knitr} options were migrated to live inside
  `build_markdown()`

# sandpaper 0.0.0.9002

- Migrate template to use fenced divs instead of {dovetail}.
- `build_lesson()` will now render HTML in episode titles.
- {callr} is now imported to protect the processes building markdown and HTML
  files.

# sandpaper 0.0.0.9001

- Add `override` argument to `build_lesson()`. This gets passed on to
  `pkgdown::as_pkgdown()` for more control over where the site gets built.
- Update dependency of {pegboard} to 0.0.0.9006, which includes the $questions
  field to make parsing the ever shifting landscape a bit easier.
- First tracking version with NEWS


