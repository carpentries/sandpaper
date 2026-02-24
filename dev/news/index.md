# Changelog

## sandpaper 0.18.6.9000 \[\]

### BUG FIXES

- Fix ORCiD image display on both learner and instructor citation.html
  pages (reported, fixed [@tobyhodges](https://github.com/tobyhodges) PR
  [705](https://github.com/carpentries/sandpaper/pull/705))
- Add lang-code input to build-and-deploy workflow, in preparation for
  harmonising workflows across translated and non-translated lessons.

## sandpaper 0.18.5 \[2026-02-02\]

### WORKFLOW HOTFIXES

- Revert to previous PAT requirement due to complexity of managing the
  manual vs automated triggers. Whilst this is frustrating to revert
  changes, it’s more reliable and less confusing for repo maintainers.

## sandpaper 0.18.4 \[2026-01-22\]

### NEW DOCKER WORKFLOW OPTIONS

- Add support for a BUILD_RESET repo variable to docker_build_deploy,
  where `true` will force sandpaper to reset any previous built markdown
  every build step. Default/omitted is `false`.
- Add support for a AUTO_MERGE_CONTAINER_VERSION_UPDATE repo variable to
  docker_build_deploy, where `false` will stop auto-merging the
  workbench-docker-version.txt file update PR. Default/omitted is
  `true`.

## sandpaper 0.18.3 \[2026-01-19\]

### HOTFIX RELEASE

- Fix more triggers

## sandpaper 0.18.2 \[2026-01-19\]

### HOTFIX RELEASE

- Fix remaining workflow typos
- Improve workflow trigger conditions

## sandpaper 0.18.1 \[2026-01-17\]

### HOTFIX RELEASE

- Due to high chance of Dockerhub rate limiting the pulling of the
  workbench-docker image by anonymous accounts when building lessons
  (all on a Tuesday at the same time!), move to GHCR for workflows. GHCR
  has no rate limits for public packages.
- Fix some problematic trigger logic in workflows.

## sandpaper 0.18.0 \[2026-01-16\]

### DOCKER WORKFLOWS RELEASE

- Replace the existing GitHub Actions workflows with Docker versions -
  PR [650](https://github.com/carpentries/sandpaper/pull/650)

## sandpaper 0.17.3 \[2025-12-03\]

### HOTFIX RELEASE

- Make {cffr} an Import not Suggests, improve warning message when cffr
  not available - PR
  [684](https://github.com/carpentries/sandpaper/pull/684)

## sandpaper 0.17.2 \[2025-12-02\]

### NEW FEATURES

- Check for packages on GitHub if the renv lockfile specifies them.
  Previously, packages that weren’t linked through hydration would only
  be attempted to be installed through a repo, and not checked on
  GitHub - PR [682](https://github.com/carpentries/sandpaper/pull/682)
  ([reported](https://github.com/carpentries/sandpaper/issues/680)
  [@chrbknudsen](https://github.com/chrbknudsen))
- Implementation of Cite This Lesson pages, built dynamically from
  CITATION.cff files in a lesson repo. Current brehaviour is unchanged
  if CITATION file exists (links to GitHub), or no file exists - PR
  [679](https://github.com/carpentries/sandpaper/pull/679)
  ([reported](https://github.com/carpentries/sandpaper/issues/508)
  [@apirogov](https://github.com/apirogov))
- Add cute parrot icons for referenced Glosario terms - PR
  [673](https://github.com/carpentries/sandpaper/pull/673)

### BUG FIXES

- Fix glosario placeholders using non-existent slugs (reported
  [@ErinBecker](https://github.com/ErinBecker)
  [\#674](https://github.com/carpentries/sandpaper/issues/674), fixed 1
  [\#676](https://github.com/carpentries/sandpaper/issues/676))
- Fix empty md processing, and improve md header detection
  ([reported](https://github.com/carpentries/workbench/issues/80)
  [@tobyhodges](https://github.com/tobyhodges), fixed 1
  [\#677](https://github.com/carpentries/sandpaper/issues/677))

### MISC

- Add use_site_libs option to manage_deps - allows environments to use
  any preinstalled site library packages by adding those paths to
  .libPaths(). This is envisaged to be of use where already constrained
  environments are in use, e.g. Workbench Docker containers, including
  GHA builds (which should be faster as a result) - PR
  [675](https://github.com/carpentries/sandpaper/pull/675)
- Allow CI to bypass the forced manage_deps in renv consent - adds the
  skip_manage_deps flag to
  [`build_markdown()`](https://carpentries.github.io/sandpaper/dev/reference/build_markdown.md)
  and also to
  [`ci_deploy()`](https://carpentries.github.io/sandpaper/dev/reference/ci_deploy.md).
  This is in preparation for the Dockerised Workbench workflows, where
  dependency management happens before this part of the codebase is run,
  so is superfluous. In the dockerised version of the workflows, this
  will be set to TRUE, but in the normal sandpaper workflows this will
  be FALSE, so current behaviour is maintained - PR
  [678](https://github.com/carpentries/sandpaper/pull/678)
- Add test snapshots for pandoc 3.1.11

## sandpaper 0.17.1 \[2025-08-08\]

### HOTFIX

- {varnish} minimum version is now 1.0.7 due to callout header changes
  (reported and fixed
  [@matthewfeickert](https://github.com/matthewfeickert)
  [\#668](https://github.com/carpentries/sandpaper/issues/668))

### MISC

- Add [@matthewfeickert](https://github.com/matthewfeickert) and
  [@brownsarahm](https://github.com/brownsarahm) as contributors -
  welcome!

## sandpaper 0.17.0 \[2025-08-07\]

### NEW FEATURES

- Initial implementation of Glosario integration - PR
  [612](https://github.com/carpentries/sandpaper/pull/612) (1)
- Support pages with multiple tab groups - PR
  [658](https://github.com/carpentries/sandpaper/pull/658)
  ([@astroDimitrios](https://github.com/astroDimitrios))
- Add distintive callout headers - PR
  [663](https://github.com/carpentries/sandpaper/pull/663)
  ([reported](https://github.com/carpentries/varnish/issues/160)
  [@jfrost-mo](https://github.com/jfrost-mo), implemented 1)

### MISC

- Fix pak install when trying to parse .editorconfig files (1)
- Update machine user links - PR
  [664](https://github.com/carpentries/sandpaper/pull/664)
  ([@brownsarahm](https://github.com/brownsarahm))

## sandpaper 0.16.12 \[2025-05-06\]

### BUG FIXES

- Fix tests and snapshots for bioschemas type PR
  [649](https://github.com/carpentries/sandpaper/pull/649)
  1.  
- Improve error message when git and/or withr is not installed (reported
  [@fmarotta](https://github.com/fmarotta)
  [\#638](https://github.com/carpentries/sandpaper/issues/638), fixed 1
  [\#647](https://github.com/carpentries/sandpaper/issues/647))
- Improve YAML parsing and provide warnings/errors when logging issues
  (1)
- Explicit language setting required for Ubuntu 24.04
  ([\#630](https://github.com/carpentries/sandpaper/issues/630), 1
  [\#632](https://github.com/carpentries/sandpaper/issues/632))
- Improve checks that lessons are overviews, including when full
  rebuilds (1
  [\#648](https://github.com/carpentries/sandpaper/issues/648))

### LANGUAGES

- Provide Italian translation ([@Lisanna](https://github.com/Lisanna)
  [\#631](https://github.com/carpentries/sandpaper/issues/631))

## sandpaper 0.16.11 \[2025-01-17\]

### BUG FIXES

- The website preview feature which automatically opens a web browser
  after running
  [`build_lesson()`](https://carpentries.github.io/sandpaper/dev/reference/build_lesson.md)
  has been fixed to work with the latest version of pkgdown
  ([@Bisaloo](https://github.com/Bisaloo),
  [\#627](https://github.com/carpentries/sandpaper/issues/627))
- Fix build failures if `instructor-notes.[R]md` is missing or not
  listed in the `config.yaml` (reported
  [@jhidding](https://github.com/jhidding)
  [\#622](https://github.com/carpentries/sandpaper/issues/622), fixed 1
  [\#626](https://github.com/carpentries/sandpaper/issues/626))

### NEW FEATURES

- Users can now provide a `disable_sidebar_numbering` option in a lesson
  `config.yaml` to turn off automatic episode numbering if they want to
  use their own, e.g. specifying their own numbering manually in episode
  title blocks (reported [@anenadic](https://github.com/anenadic)
  [\#623](https://github.com/carpentries/sandpaper/issues/623),
  implemented 1
  [\#624](https://github.com/carpentries/sandpaper/issues/624))
- Add a new `config_yaml` option `license_url` so that users can supply
  custom license URLs for lesson footers (reported
  [@chrbknudsen](https://github.com/chrbknudsen)
  [\#619](https://github.com/carpentries/sandpaper/issues/619),
  implemented 1
  [\#620](https://github.com/carpentries/sandpaper/issues/620))

## sandpaper 0.16.10 \[2024-11-11\]

### NEW FEATURES

- Add caution callout ([@MttArmstrong](https://github.com/MttArmstrong)
  [\#613](https://github.com/carpentries/sandpaper/issues/613))

### MISC

- Add [@MttArmstrong](https://github.com/MttArmstrong) as a
  contributor - welcome!

## sandpaper 0.16.9 (2024-10-15)

### BUG FIXES

- Pin remaining workflows to ubuntu-22.04 instead of ubuntu-latest (1
  [\#610](https://github.com/carpentries/sandpaper/issues/610))
- Add compiled potools translation for German

## sandpaper 0.16.8 (2024-10-11)

### BUG FIXES

- Pin workflow to ubuntu-22.04 instead of ubuntu-latest (reported
  [@chrbknudsen](https://github.com/chrbknudsen)
  [\#605](https://github.com/carpentries/sandpaper/issues/605), fixed 1
  [\#606](https://github.com/carpentries/sandpaper/issues/606))
- Update notes to remove excessive build warnings
  ([@milanmlft](https://github.com/milanmlft)
  [\#599](https://github.com/carpentries/sandpaper/issues/599))

### LANGUAGES

- Add `R-de.po` for German translations of lesson elements
  ([@martin-raden](https://github.com/martin-raden)
  [\#607](https://github.com/carpentries/sandpaper/issues/607))

### MISC

- Added [@martin-raden](https://github.com/martin-raden) as a
  contributor and translator - welcome!

## sandpaper 0.16.7 (2024-09-04)

### BUG FIXES

- Add overwrite option to pr workflow to fix change in default from
  [update-artifact action v3 to
  v4](https://github.com/actions/upload-artifact#breaking-changes)
  ([@milanmlft](https://github.com/milanmlft)
  [\#602](https://github.com/carpentries/sandpaper/issues/602))

## sandpaper 0.16.6 (2024-08-23)

### BUG FIXES

- Regression fix for update to pkgdown resulting in duplicated
  untranslated h2 anchors for sections (1
  [\#600](https://github.com/carpentries/sandpaper/issues/600))
- Fix various action warnings and issues relating to old Node.js
  versions ([@jhlegarreta](https://github.com/jhlegarreta)
  [\#596](https://github.com/carpentries/sandpaper/issues/596))
- Update core actions to v4 ([@Bisaloo](https://github.com/Bisaloo)
  [\#577](https://github.com/carpentries/sandpaper/issues/577))

### NEW FEATURES

- Allow custom carpentry config types, and associated alt-text
  descriptions to support alternative logos/theming of lessons
  ([@milanmlft](https://github.com/milanmlft)
  [\#585](https://github.com/carpentries/sandpaper/issues/585),
  [@ErinBecker](https://github.com/ErinBecker))
- Add support for French translations of core lesson components/sections
  ([@Bisaloo](https://github.com/Bisaloo)
  [\#595](https://github.com/carpentries/sandpaper/issues/595))

## sandpaper 0.16.5 (2024-06-18)

### BUG FIXES

- Fix for empty divs when checking for headers (reported:
  [@dmgatti](https://github.com/dmgatti),
  [\#581](https://github.com/carpentries/sandpaper/issues/581); fixed 1)
- Fix for spacing in callout titles when they have inner tags,
  e.g. `<code>` (reported: [@abostroem](https://github.com/abostroem),
  [\#562](https://github.com/carpentries/sandpaper/issues/562); fixed 1)

### NEW FEATURES

- Add support for including the Carpentries matomo tracker, a custom
  user-supplied tracker script, or no tracking (reported:
  [@tbyhdgs](https://github.com/tbyhdgs),
  [@fiveop](https://github.com/fiveop)
  <https://github.com/carpentries/varnish/issues/37>,
  [@zkamvar](https://github.com/zkamvar)
  <https://github.com/carpentries/sandpaper/issues/438>, implemented: 1
  )

## sandpaper 0.16.4 (2024-04-10)

### NEW FEATURES

- The lesson page footer now supports either a CITATION or CITATION.cff
  file (reported: [@tobyhodges](https://github.com/tobyhodges),
  implemented: 1,
  [\#572](https://github.com/carpentries/sandpaper/issues/572);
  [@tobyhodges](https://github.com/tobyhodges),
  <https://github.com/carpentries/varnish/pull/122>)
- Add support for tabbed content in lessons (reported:
  [@astroDimitrios](https://github.com/astroDimitrios), implemented:
  [@astroDimitrios](https://github.com/astroDimitrios), 1,
  <https://github.com/carpentries/sandpaper/pull/571>,
  <https://github.com/carpentries/varnish/pull/121>,
  <https://github.com/carpentries/pegboard/pull/148> ).

## sandpaper 0.16.3 (2024-03-12)

### BUG FIX

- Hotfix for pandoc2-to-pandoc3 bump that resulted in CSS deduplication
  of section classes for callout blocks (reported:
  [@bencomp](https://github.com/bencomp),
  [\#470](https://github.com/carpentries/sandpaper/issues/470);
  [@ndporter](https://github.com/ndporter)
  <https://github.com/carpentries/workbench/issues/81>; fixed: 1,
  [\#574](https://github.com/carpentries/sandpaper/issues/574))

## sandpaper 0.16.2 (2023-12-19)

### MISC

- JSON metadata now contains the `inLanguage` key.

### DOCUMENTATION

- A list of translatable strings has now been added to
  [`vignette("translations", package = "sandpaper")`](https://carpentries.github.io/sandpaper/dev/articles/translations.md)

### INTERNAL

- Translation strings now are unduplicated and live in a single file
  (`R/utils-translate.R`). This will make finding and updating these
  strings easier for maintainer and translators.
- Translations now live in the global environment called
  `these$translations`
- A new documentation page called `?translate` contains details of how
  translations of template elements are rendered.
- [`tr_src()`](https://carpentries.github.io/sandpaper/dev/reference/translations.md)
  helper function provides access to the source strings of the
  translations.
- [`tr_get()`](https://carpentries.github.io/sandpaper/dev/reference/translations.md),
  [`tr_varnish()`](https://carpentries.github.io/sandpaper/dev/reference/translations.md),
  and
  [`tr_computed()`](https://carpentries.github.io/sandpaper/dev/reference/translations.md)
  helper functions provide access top the lists of translated strings.
  These have replaced the `tr_()` strings at the point of generation.

## sandpaper 0.16.1 (2023-12-14)

### BUG FIX

- Callout headings with markup in the titles will no longer have text
  duplicated (reported: [@zkamvar](https://github.com/zkamvar),
  [\#556](https://github.com/carpentries/sandpaper/issues/556); fixed:
  [@zkamvar](https://github.com/zkamvar),
  [\#557](https://github.com/carpentries/sandpaper/issues/557))

## sandpaper 0.16.0 (2023-12-13)

### NEW FEATURES

- It is now possible to build lessons in languages other than English so
  that the website elements are also localised to that language
  (reported: [@zkamvar](https://github.com/zkamvar),
  [\#205](https://github.com/carpentries/sandpaper/issues/205),
  [@joelnitta](https://github.com/joelnitta),
  [\#544](https://github.com/carpentries/sandpaper/issues/544); fixed:
  [@joelnitta](https://github.com/joelnitta) and
  [@zkamvar](https://github.com/zkamvar),
  [\#546](https://github.com/carpentries/sandpaper/issues/546)).
- [`known_languages()`](https://carpentries.github.io/sandpaper/dev/reference/known_languages.md)
  is a function that will return the language codes that are known by
  {sandpaper}.

### DOCUMENTATION

- A new vignette `vignette("translation", package = "sandpaper")`
  describes how translation of template components works and how to
  submit new/update translations (added:
  [@zkamvar](https://github.com/zkamvar),
  [\#546](https://github.com/carpentries/sandpaper/issues/546)).
- A new vignette about data flow
  [`vignette("data-flow", package = "sandpaper")`](https://carpentries.github.io/sandpaper/dev/articles/data-flow.md)
  describes how templating, translations, and lesson metadata flows from
  {sandpaper} to {varnish} (added:
  [@zkamvar](https://github.com/zkamvar),
  [\#553](https://github.com/carpentries/sandpaper/issues/553))

### BUG FIX

- The spelling of keypoints is now consistent between the menu item and
  the callout blocks (reported:
  [@clarallebot](https://github.com/clarallebot),
  <https://github.com/carpentries/workbench/issues/44>; fixed:
  [@zkamvar](https://github.com/zkamvar),
  [\#546](https://github.com/carpentries/sandpaper/issues/546))

### DEPENDENCIES

- The {withr} package has been upgraded to an import from a suggested
  package.

### LANGUAGES

- Japanese (ja) (added: [@joelnitta](https://github.com/joelnitta),
  [\#546](https://github.com/carpentries/sandpaper/issues/546))
- Spanish (es) (added: [@yabellini](https://github.com/yabellini),
  [\#552](https://github.com/carpentries/sandpaper/issues/552))

### MISC

- Added [@yabellini](https://github.com/yabellini) as a contributor and
  translator
- Added [@joelnitta](https://github.com/joelnitta) as an author and
  translator

## sandpaper 0.15.0 (2023-11-29)

### NEW FEATURES

- Using `handout: true` in `config.yaml` will cause a handout to be
  generated for the lesson website under `/files/code-handout.R`. At the
  moment, this is only relevant for R-based lessons (implemented: 1,
  [\#527](https://github.com/carpentries/sandpaper/issues/527),
  reviewed: [@zkamvar](https://github.com/zkamvar)) and supersedes the
  need for specifying `options(sandpaper.handout = TRUE)`
- Content for learners now accessible through instructor view. The
  instructor view “More” dropdown menu item will now have links to
  learner view items appended. Note that when clicking these links, the
  user will remain in instructor view. This behaviour may change in
  future iterations (reported:
  [@karenword](https://github.com/karenword),
  [\#394](https://github.com/carpentries/sandpaper/issues/394); fixed:
  [@ErinBecker](https://github.com/ErinBecker),
  [\#530](https://github.com/carpentries/sandpaper/issues/530),
  reviewed: [@zkamvar](https://github.com/zkamvar))
- [`create_episode()`](https://carpentries.github.io/sandpaper/dev/reference/create_episode.md)
  will now open new episodes for editing in interactive sessions
  (implemented: [@milanmlft](https://github.com/milanmlft),
  [\#534](https://github.com/carpentries/sandpaper/issues/534),
  reviewed: [@zkamvar](https://github.com/zkamvar))
- The `site/` folder is now customisable to any writable directory on
  your system by setting the experimental `SANDPAPER_SITE` environment
  variable to any valid and empty folder. This is most useful in the
  context of Docker containers, where file permissions to mounted
  volumes are not always guaranteed (reported:
  [@fherreazcue](https://github.com/fherreazcue)
  [\#536](https://github.com/carpentries/sandpaper/issues/536);
  implemented: [@zkamvar](https://github.com/zkamvar),
  [\#537](https://github.com/carpentries/sandpaper/issues/537))
- DOI badges can now be displayed when paired with {varnish} version
  0.4.0 by adding the `doi:` key to the `config.yaml` file with either
  the raw DOI or the URL to the DOI (reported:
  [@tobyhodges](https://github.com/tobyhodges),
  carpentries/workbench#67; fixed:
  [@tobyhodges](https://github.com/tobyhodges),
  [\#535](https://github.com/carpentries/sandpaper/issues/535)).

### BUG FIX

- Internal
  [`build_status()`](https://carpentries.github.io/sandpaper/dev/reference/build_status.md)
  function: make sure `root_path()` always points to lesson root
  (reported: [@milanmlft](https://github.com/milanmlft),
  [\#531](https://github.com/carpentries/sandpaper/issues/531); fixed:
  [@milanmlft](https://github.com/milanmlft),
  [\#532](https://github.com/carpentries/sandpaper/issues/532))

### MISC

- Added [@milanmlft](https://github.com/milanmlft) as contributor

## sandpaper 0.14.1 (2023-11-09)

### BUG FIX

- `mailto:` links are no longer prepended with the URL (reported:
  [@apirogov](https://github.com/apirogov),
  [\#538](https://github.com/carpentries/sandpaper/issues/538); fixed:
  [@zkamvar](https://github.com/zkamvar),
  [\#539](https://github.com/carpentries/sandpaper/issues/539))

## sandpaper 0.14.0 (2023-10-02)

### NEW FEATURES

- all internal folders can contain the standard `files`, `fig`, and
  `data` folders with the cautionary note that duplicate file names to
  other folders will cause an error.
- [`validate_lesson()`](https://carpentries.github.io/sandpaper/dev/reference/validate_lesson.md)
  now reports invalid elements of child documents
- A new vignette
  [`vignette("include-child-documents", package = "sandpaper")`](https://carpentries.github.io/sandpaper/dev/articles/include-child-documents.md)
  demonstrates and describes the caveats about using child documents.

### BUG FIX

- overview child files are no longer built as if they are top-level
  files.

### MISC

- R Markdown episodes with further nested child documents (grand
  children and beyond) will now trigger an episode to rebuild (fixed:
  [@zkamvar](https://github.com/zkamvar),
  [\#513](https://github.com/carpentries/sandpaper/issues/513))
- Child file detection functionality has been moved to the {pegboard}
  package

### DEPENDENCIES

- {pegboard} minimum version is now 0.7.0

## sandpaper 0.13.3 (2023-09-22)

### BUG FIX

- References to heading in `setup.md` will now be reflected in the
  website. (reported: [@tobyhodges](https://github.com/tobyhodges),
  [@fnattino](https://github.com/fnattino), and
  [@zkamvar](https://github.com/zkamvar),
  [\#521](https://github.com/carpentries/sandpaper/issues/521); fixed:
  [@ErinBecker](https://github.com/ErinBecker) and
  [@zkamvar](https://github.com/zkamvar),
  [\#522](https://github.com/carpentries/sandpaper/issues/522)).
- A regression from
  [\#514](https://github.com/carpentries/sandpaper/issues/514) where
  empty menus would cause a failure in deployment with the 404 page has
  been fixed (reported: [@tobyhodges](https://github.com/tobyhodges) and
  [@zkamvar](https://github.com/zkamvar),
  [\#519](https://github.com/carpentries/sandpaper/issues/519); fixed:
  [@zkamvar](https://github.com/zkamvar),
  [\#520](https://github.com/carpentries/sandpaper/issues/520)).

## sandpaper 0.13.2 (2023-09-20)

### BUG FIX

- Users with duplicated `init.defaultBranch` declarations in their git
  config will no longer fail the default branch check (reported:
  [@tesaunders](https://github.com/tesaunders),
  [\#516](https://github.com/carpentries/sandpaper/issues/516); fixed:
  [@zkamvar](https://github.com/zkamvar),
  [\#517](https://github.com/carpentries/sandpaper/issues/517))

## sandpaper 0.13.1 (2023-09-19)

### BUG FIX

- Aggregate pages will no longer fail if an episode has a prefix that is
  the same as that aggregate page (e.g. `images.html` will no longer
  fail if there is an episode that starts with `images-`) (reported:
  [@mwhamgenomics](https://github.com/mwhamgenomics),
  [\#511](https://github.com/carpentries/sandpaper/issues/511); fixed:
  [@zkamvar](https://github.com/zkamvar),
  [\#512](https://github.com/carpentries/sandpaper/issues/512))
- 404 page index link will point to the default index page of the site
  instead of the relative index page, which would result in a 404 for
  nested links that did not exist (reported:
  [@kaijagahm](https://github.com/kaijagahm) and
  [@zkamvar](https://github.com/zkamvar),
  [\#498](https://github.com/carpentries/sandpaper/issues/498); fixed
  [@zkamvar](https://github.com/zkamvar),
  [\#514](https://github.com/carpentries/sandpaper/issues/514))

## sandpaper 0.13.0 (2023-09-06)

### NEW FEATURES

- Overview style lessons that do not have episodic content can now be
  processed, analysed, and built by {sandpaper}. To make your lesson an
  overview lesson, you can add `overview: true` to your `config.yaml`
  (reported: [@zkamvar](https://github.com/zkamvar),
  <https://github.com/carpentries/workbench/issues/65>; implemented:
  [@zkamvar](https://github.com/zkamvar),
  [\#496](https://github.com/carpentries/sandpaper/issues/496))
- The new `spoiler` class of fenced div will allow authors to specify an
  expandable section of content that is collapsed by default. This
  replaces the former paradigm of using “floating solution” blocks to
  present options for installation on different platforms. (implemented:
  [@tobyhodges](https://github.com/tobyhodges),
  [\#502](https://github.com/carpentries/sandpaper/issues/502))

### BUG FIX

- Internal function `root_path()` will no longer fail if the `episodes/`
  folder does not exist as long as one of the other four folders
  (`site/`, `learners/`, `instructors/`, `profiles/`) exists (fixed:
  [@zkamvar](https://github.com/zkamvar),
  [\#496](https://github.com/carpentries/sandpaper/issues/496))
- [`set_config()`](https://carpentries.github.io/sandpaper/dev/reference/set_config.md)
  can now properly process logical values into `true` and `false`
- R Markdown documents with modificiations to child documents will now
  take into account changes to the child documents (reported
  [@jcolomb](https://github.com/jcolomb),
  [\#497](https://github.com/carpentries/sandpaper/issues/497); fixed
  [@zkamvar](https://github.com/zkamvar),
  [\#498](https://github.com/carpentries/sandpaper/issues/498)).
- A broken test from the development version of {renv} fixed. This was a
  change in output and not functionality, so there will be no
  user-visible changes (reported:
  [@zkamvar](https://github.com/zkamvar),
  [\#484](https://github.com/carpentries/sandpaper/issues/484); fixed:
  [@zkamvar](https://github.com/zkamvar),
  [\#487](https://github.com/carpentries/sandpaper/issues/487)).
- Broken snapshot tests from upstream R-devel have been fixed by
  ensuring that version comparisons always use characters and not
  numbers (which is ergonomically weird, but whatever) (reported:
  [@zkamvar](https://github.com/zkamvar)
  [\#487](https://github.com/carpentries/sandpaper/issues/487); fixed:
  [@zkamvar](https://github.com/zkamvar)
  [\#487](https://github.com/carpentries/sandpaper/issues/487))
- Blank instructor notes pages no longer fail to build (reported:
  [@apirogov](https://github.com/apirogov),
  [\#505](https://github.com/carpentries/sandpaper/issues/505); fixed:
  [@klbarnes20](https://github.com/klbarnes20),
  [\#509](https://github.com/carpentries/sandpaper/issues/509))
- Tests for {renv} post 1.0.0 fixed so that they no longer run forever
  interactively (reported: [@zkamvar](https://github.com/zkamvar)
  [\#500](https://github.com/carpentries/sandpaper/issues/500); fixed:
  [@zkamvar](https://github.com/zkamvar),
  [\#501](https://github.com/carpentries/sandpaper/issues/501))

### MISC

- We are now testing against pandoc 2.19.2 in continuous integration.
- The discussion list link for the new lesson contributing template has
  been fixed.
- examples have been modified to not use R Markdown lessons unless
  necessary, reducing output and time needed to build the examples.

### CONTINUOUS INTEGRATION

- The README file has been updated to fix a typo.

### DEPENDENCIES

- {pegboard} minimum version is now 0.6.0
- {varnish} minimum version is now 0.3.0

## sandpaper 0.12.4 (2023-06-16)

### BUG FIX

- A bug in walled systems where templated pages (e.g. 404) could not be
  written due to permissions issues has been fixed (reported:
  [@ocaisa](https://github.com/ocaisa),
  [\#479](https://github.com/carpentries/sandpaper/issues/479); fixed:
  [@zkamvar](https://github.com/zkamvar),
  [\#482](https://github.com/carpentries/sandpaper/issues/482)).

## sandpaper 0.12.3 (2023-06-01)

### BUG FIX

- A bug where the git credentials are accidentally changed when a lesson
  is built is fixed by no longer querying git author when the lesson is
  built. (reported: [@joelnitta](https://github.com/joelnitta),
  [@velait](https://github.com/velait), and
  [@zkamvar](https://github.com/zkamvar),
  [\#449](https://github.com/carpentries/sandpaper/issues/449); fixed:
  [@zkamvar](https://github.com/zkamvar),
  [\#476](https://github.com/carpentries/sandpaper/issues/476)).

## sandpaper 0.12.2 (2023-05-29)

### BUG FIX

- A bug where the sidebar for non-episode pages had extra commas was
  fixed (reported: [@zkamvar](https://github.com/zkamvar),
  [\#473](https://github.com/carpentries/sandpaper/issues/473); fixed:
  [@zkamvar](https://github.com/zkamvar),
  [\#474](https://github.com/carpentries/sandpaper/issues/474))

## sandpaper 0.12.1 (2023-05-26)

### BUG FIX

- The current page of the sidebar no longer hides the episode number.
  (reported: [@cynthiaftw](https://github.com/cynthiaftw),
  <https://github.com/carpentries/workbench/issues/42> and
  [\#432](https://github.com/carpentries/sandpaper/issues/432); fixed:
  [@zkamvar](https://github.com/zkamvar),
  [\#472](https://github.com/carpentries/sandpaper/issues/472))
- metadata for episodes with titles containing markup no longer include
  that markup in the metadata ([@zkamvar](https://github.com/zkamvar),
  [\#472](https://github.com/carpentries/sandpaper/issues/472))

### MISC

- The internal function `sandpaper:::check_pandoc()` now points to the
  correct URL to download RStudio, which moved after the migration to
  posit ([@zkamvar](https://github.com/zkamvar),
  [\#471](https://github.com/carpentries/sandpaper/issues/471))

## sandpaper 0.12.0 (2023-05-19)

### NEW FEATURES

- Aggregate instructor notes now have headings that link back to the
  source instructor note (reported:
  [@tobyhodges](https://github.com/tobyhodges),
  [\#463](https://github.com/carpentries/sandpaper/issues/463); fixed:
  [@zkamvar](https://github.com/zkamvar),
  [\#468](https://github.com/carpentries/sandpaper/issues/468))
- The internal function `sandpaper:::render_html()` now explicitly sets
  the pandoc version before running the subprocess. This allows lesson
  developers to use the {pandoc} package to set their pandoc versions.
  (reported: [@zkamvar](https://github.com/zkamvar),
  [\#465](https://github.com/carpentries/sandpaper/issues/465); fixed:
  [@zkamvar](https://github.com/zkamvar),
  [\#465](https://github.com/carpentries/sandpaper/issues/465))

### BUG FIX

- Callout block anchor links now point to the correct ID of the block
  derived from the title of the block (as opposed to the generic ID).
  (reported: [@debpaul](https://github.com/debpaul),
  <https://github.com/datacarpentry/OpenRefine-ecology-lesson/issues/292>
  and [@bencomp](https://github.com/bencomp),
  [\#454](https://github.com/carpentries/sandpaper/issues/454); fixed:
  [@zkamvar](https://github.com/zkamvar),
  [\#467](https://github.com/carpentries/sandpaper/issues/467)).
- Inline images no longer automatically transform to figure blocks
  (reported: [@ostephens](https://github.com/ostephens),
  [\#445](https://github.com/carpentries/sandpaper/issues/445); fixed:
  [@zkamvar](https://github.com/zkamvar),
  [\#446](https://github.com/carpentries/sandpaper/issues/446)). This
  bug was preventing image links (e.g. MyBinder badges) from being
  rendered as links with images in them. This fixes that issue. It also
  helps distinguish inline images between figures in the DOM.

## sandpaper 0.11.17 (2023-05-16)

### NEW FEATURES

- [`sandpaper::serve()`](https://carpentries.github.io/sandpaper/dev/reference/serve.md)
  gains the `quiet` argument, defaulting to `TRUE` for interactive
  sessions and `FALSE` for command line sessions
- [`sandpaper::serve()`](https://carpentries.github.io/sandpaper/dev/reference/serve.md)
  gains the `...` argument to pass options to
  [`servr::server_config()`](https://rdrr.io/pkg/servr/man/server_config.html)
  for setting ports and hosts (reported:
  [@twrightsman](https://github.com/twrightsman),
  <https://github.com/carpentries/workbench/issues/50> and
  [\#459](https://github.com/carpentries/sandpaper/issues/459); fixed:
  [@zkamvar](https://github.com/zkamvar),
  [\#461](https://github.com/carpentries/sandpaper/issues/461)).

### BUG FIX

- Break timing is now included in the overall schedule. (reported:
  [@karenword](https://github.com/karenword),
  [\#437](https://github.com/carpentries/sandpaper/issues/437); fixed:
  [@bencomp](https://github.com/bencomp),
  [\#455](https://github.com/carpentries/sandpaper/issues/455)).

### TEST SUITE

- An upstream feature in {renv}, forcing it to be silent when testing
  caused some expectations to fail. This has been fixed in specific
  tests by turning verbosity on in those tests (reported:
  [@zkamvar](https://github.com/zkamvar),
  [\#457](https://github.com/carpentries/sandpaper/issues/457); fixed:
  [@zkamvar](https://github.com/zkamvar),
  [\#458](https://github.com/carpentries/sandpaper/issues/458))

## sandpaper 0.11.16 (2023-05-05)

### BUG FIX

- A failure to incrementally build the lesson with
  [`sandpaper::serve()`](https://carpentries.github.io/sandpaper/dev/reference/serve.md)
  has been fixed (reported: [@zkamvar](https://github.com/zkamvar),
  [\#450](https://github.com/carpentries/sandpaper/issues/450); fixed:
  [@zkamvar](https://github.com/zkamvar),
  [\#451](https://github.com/carpentries/sandpaper/issues/451))

### MISC

- Lessons with markdown documents no longer use
  [`callr::r()`](https://callr.r-lib.org/reference/r.html) as an
  intermediary (reported: [@zkamvar](https://github.com/zkamvar),
  [\#442](https://github.com/carpentries/sandpaper/issues/442), fixed:
  [@zkamvar](https://github.com/zkamvar),
  [\#452](https://github.com/carpentries/sandpaper/issues/452))

## sandpaper 0.11.15 (2023-04-05)

### BUG FIX

- The 404 page will now have proper styling applied when the site is
  deployed via one of the `ci_` functions (reported:
  [@zkamvar](https://github.com/zkamvar),
  [\#430](https://github.com/carpentries/sandpaper/issues/430); fixed:
  [@zkamvar](https://github.com/zkamvar),
  [\#431](https://github.com/carpentries/sandpaper/issues/431)).
- [`sandpaper::serve()`](https://carpentries.github.io/sandpaper/dev/reference/serve.md)
  will no longer error if a different directory is used.

## sandpaper 0.11.14 (2023-04-04)

### BUG FIX

- A 404 page has been added (reported:
  [@fmichonneau](https://github.com/fmichonneau),
  [\#268](https://github.com/carpentries/sandpaper/issues/268); fixed:
  [@zkamvar](https://github.com/zkamvar),
  [\#429](https://github.com/carpentries/sandpaper/issues/429))

### DEPENDENCIES

- The minimum version of {pegboard} has been set to 0.5.1

### TEMPLATES

- The README, LICENSE, CONTRIBUTING, and SETUP templates have been fixed
  to work with {pegboard} version 0.5.1
- The LICENSE and CONTRIBUTING templates now refer to The Carpentries as
  a whole and provides correct links to community forums.

## sandpaper 0.11.13 (2023-03-25)

### WORKAROUND

- Fix an issue for {renv} version 0.17.2 where it was unable to
  provision packages that were being used in the parent environment.
  This was a problem in environments where the version of {sandpaper}
  was controlled by {renv}. (reported:
  <https://github.com/rstudio/renv/issues/1177>,
  [@zkamvar](https://github.com/zkamvar); fixed
  [\#423](https://github.com/carpentries/sandpaper/issues/423),
  [@zkamvar](https://github.com/zkamvar)). Note that this fix is ONLY
  applicable to {renv} 0.17.2 and will be fixed with newer versions of
  {renv}.

## sandpaper 0.11.12 (2023-03-22)

### CONTINUOUS INTEGRATION

- workflow files now have explicit permissions to comment on pull
  requests or create new branches when called. This fixes an issue where
  new lessons would not have the ability to preview pull requests or
  update workflows. (reported:
  [\#420](https://github.com/carpentries/sandpaper/issues/420),
  [@zkamvar](https://github.com/zkamvar); fixed
  [\#421](https://github.com/carpentries/sandpaper/issues/421),
  [@zkamvar](https://github.com/zkamvar))
- the `create-pull-request` action is now coming from a fork in The
  Carpentries organisation for security.

### MISC

- A typo has been fixed in the package cache vignette
- The CONTRIBUTING boilerplate has been updated to fix formatting issues

## sandpaper 0.11.11 (2023-03-17)

### BUG FIX

- [`update_cache()`](https://carpentries.github.io/sandpaper/dev/reference/dependency_management.md)
  will now work with {renv} version 0.17.1, which lost a print method
  for the `renv_updates` class (reported:
  [@zkamvar](https://github.com/zkamvar),
  [\#415](https://github.com/carpentries/sandpaper/issues/415); fixed:
  [@zkamvar](https://github.com/zkamvar),
  [\#416](https://github.com/carpentries/sandpaper/issues/416) and
  <https://github.com/zkamvar/vise/commit/ee4798701a958ee48429980eb970266885f8265b>

### MISC

- @jcolomb has been added as a contributor in the DESCRIPTION.

## sandpaper 0.11.10 (2023-03-16)

### BUG FIX

- New lessons will now provision `learners/resources.md`, which will
  allow the glossary link to work (reported:
  [@elichad](https://github.com/elichad),
  [\#404](https://github.com/carpentries/sandpaper/issues/404) and
  [@ManonMarchand](https://github.com/ManonMarchand),
  <https://github.com/carpentries/workbench-template-md/issues/20>;
  fixed: [@zkamvar](https://github.com/zkamvar),
  [\#410](https://github.com/carpentries/sandpaper/issues/410))
- default CONTRIBUTING file is better suited to The Workbench and no
  longer references the now-defunct lesson-example repository (reported
  and fixed: [@jcolomb](https://github.com/jcolomb),
  [\#407](https://github.com/carpentries/sandpaper/issues/407))

## sandpaper 0.11.9 (2023-03-14)

### BUG FIX

- Links to assets in instructor view no longer render a 404. (reported:
  [@brownsarahm](https://github.com/brownsarahm),
  [\#404](https://github.com/carpentries/sandpaper/issues/404); fixed:
  [@zkamvar](https://github.com/zkamvar),
  [\#409](https://github.com/carpentries/sandpaper/issues/409))

### CONTINUOUS INTEGRATION

- Lessons with files that have spaces in their names (e.g as a learning
  tool) no longer fail to comment on pull request previews (reported:
  [@zkamvar](https://github.com/zkamvar),
  [\#399](https://github.com/carpentries/sandpaper/issues/399); fixed:
  [@zkamvar](https://github.com/zkamvar),
  [\#400](https://github.com/carpentries/sandpaper/issues/400))

## sandpaper 0.11.8 (2023-03-09)

### BUG FIX

- Excessive output from
  [`renv::diagnostics()`](https://rstudio.github.io/renv/reference/diagnostics.html)
  during building of R Markdown documents has been suppressed.

## sandpaper 0.11.7 (2023-03-09)

### MISC INTERNAL FIXES

- We now build {sandpaper} against the development version of {renv} to
  avoid bugs that come from {renv} version 0.17.0. See
  [\#406](https://github.com/carpentries/sandpaper/issues/406) for
  details.
- The internal function `message_package_cache()` no longer fails with
  {renv} version 0.17.0.

## sandpaper 0.11.6 (2023-02-15)

### NEW FEATURE

- blank or character timing estimates (e.g. XX) will now be treated as
  unknown and an estimate of 5 minutes will be used for each missing
  element. A warning will be issued listing which episodes have missing
  timings. (reported: [@zkamvar](https://github.com/zkamvar),
  [\#395](https://github.com/carpentries/sandpaper/issues/395); fixed:
  [@zkamvar](https://github.com/zkamvar),
  [\#396](https://github.com/carpentries/sandpaper/issues/396))

### BUG FIX

- [`manage_deps()`](https://carpentries.github.io/sandpaper/dev/reference/dependency_management.md)
  will now attempt to recover errors from “missing” bioconductor
  packages. Note that this is a provisional solution because it treats
  BioConductor packages as an afterthought. The full fix for this should
  be when {renv} bootstraps BioConductor repositories (reported:
  [@zkamvar](https://github.com/zkamvar),
  [\#365](https://github.com/carpentries/sandpaper/issues/365) and
  <https://github.com/rstudio/renv/issues/1110>; fixed:
  [@zkamvar](https://github.com/zkamvar),
  [\#397](https://github.com/carpentries/sandpaper/issues/397))

## sandpaper 0.11.5 (2023-02-09)

### BUG FIX

- [`update_cache()`](https://carpentries.github.io/sandpaper/dev/reference/dependency_management.md)
  and
  [`pin_version()`](https://carpentries.github.io/sandpaper/dev/reference/dependency_management.md)
  will now find the root path of the lesson before checking and
  manipulating dependencies. This will circumvent the issue where a user
  could accidentally create a `episodes/renv` folder by running
  [`update_cache()`](https://carpentries.github.io/sandpaper/dev/reference/dependency_management.md)
  from the `episodes/` directory (discovered:
  [@sarahkaspar](https://github.com/sarahkaspar); reported:
  [@zkamvar](https://github.com/zkamvar),
  [\#391](https://github.com/carpentries/sandpaper/issues/391); fixed:
  [@zkamvar](https://github.com/zkamvar),
  [\#392](https://github.com/carpentries/sandpaper/issues/392)).

## sandpaper 0.11.4 (2023-01-26)

### BUG FIX

- The setup page will always be provisioned for lessons regardless if it
  exists in the `learners:` field in `config.yaml` (reported:
  [@zkamvar](https://github.com/zkamvar),
  [\#386](https://github.com/carpentries/sandpaper/issues/386); fixed:
  [@zkamvar](https://github.com/zkamvar)
  [\#387](https://github.com/carpentries/sandpaper/issues/387)).

### PANDOC

- This updates {sandaper} to be used by pandoc version 3, which no
  longer implements the `pandoc.Null()` constructor for Lua filters
  (reported: [@zkamvar](https://github.com/zkamvar),
  [\#380](https://github.com/carpentries/sandpaper/issues/380); fixed:
  [@zkamvar](https://github.com/zkamvar):
  [\#385](https://github.com/carpentries/sandpaper/issues/385))

## sandpaper 0.11.3 (2022-12-16)

### CONTINUOUS INTEGRATION

- Pull Request workflows will now automatically cancel if several
  commits are sent in succession. Specifically, the workflows
  `pr-recieve.yaml` and `pr-comment.yaml` are given separate
  `concurrency` parameters based on the branch name and the pull request
  number. These concurrencies will prevent false alarms as found in
  <https://github.com/carpentries/lesson-development-training/pull/165#issuecomment-1337182275>.
  (discovered: [@anenadic](https://github.com/anenadic); reported:
  [@zkamvar](https://github.com/zkamvar),
  [\#374](https://github.com/carpentries/sandpaper/issues/374); fixed:
  [@zkamvar](https://github.com/zkamvar),
  [\#376](https://github.com/carpentries/sandpaper/issues/376))

## sandpaper 0.11.2 (2022-12-06)

### MISC

- The `create_syllabus()` function no longer uses
  [`pkgdown::as_pkgdown()`](https://pkgdown.r-lib.org/reference/as_pkgdown.html)
  and assumes a flat file structure when creating the syllabus. This
  provides a further fix for
  [\#371](https://github.com/carpentries/sandpaper/issues/371).

- The downlit shim has been updated to modify the function bodies while
  preserving the function signatures.

- workflows for testing on Windows has been fixed by setting the git
  config `autocrlf` to `false` before checkout (thanks to
  [@assignUser](https://github.com/assignUser) for the tip).

- The test coverage workflow has been updated to avoid long build times.

## sandpaper 0.11.1 (2022-12-05)

### BUG FIX

- A bug in deployment where GitHub deployments fail due to an error that
  says “Error: Can’t find DESCRIPTION” has been fixed (reported:
  [@tobyhodges](https://github.com/tobyhodges),
  [\#371](https://github.com/carpentries/sandpaper/issues/371); fixed,
  [@zkamvar](https://github.com/zkamvar),
  [\#372](https://github.com/carpentries/sandpaper/issues/372))

### MISC

- code inside of main `build_` functions cleaned up. Unused variables
  removed and narrative comments added to provide context.

## sandpaper 0.11.0 (2022-12-01)

- Documentation for internal storage objects updated.
- Page progress indicators reflect estimated percentage progress through
  the lesson based on the timings recorded in each episode as opposed to
  fraction of pages (reported: anonymous,
  [\#369](https://github.com/carpentries/sandpaper/issues/369); fixed
  [@zkamvar](https://github.com/zkamvar),
  [\#370](https://github.com/carpentries/sandpaper/issues/370)).

## sandpaper 0.10.8 (2022-11-15)

### MISC

- schedule/syllabus timings are now displayed as XXh XXm to clarify the
  scope of the timing (requested:
  [@tobyhodges](https://github.com/tobyhodges),
  [\#361](https://github.com/carpentries/sandpaper/issues/361); fixed
  [@zkamvar](https://github.com/zkamvar),
  [\#363](https://github.com/carpentries/sandpaper/issues/363)).
- Documentation for automated pull requests updated to reflect bots
  should have `public_repo` scope.

### BUG FIX

- A bug where the index page title was the same for both instructor and
  learner view has been fixed (reported:
  [@tobyhodges](https://github.com/tobyhodges),
  [\#361](https://github.com/carpentries/sandpaper/issues/361); fixed
  [@zkamvar](https://github.com/zkamvar),
  [\#366](https://github.com/carpentries/sandpaper/issues/366))

## sandpaper 0.10.7 (2022-11-02)

### CONTINUOUS INTEGRATION

- pandoc is now set to use the default version for r-lib/setup-pandoc
  (at the time of this update, it is version 2.19.2.

- Workflows that update workflows and packages will now push to single
  branches called `update/workflows` and `update/packages`,
  respectively. This will avoid the issue with
  [\#350](https://github.com/carpentries/sandpaper/issues/350)

- Workflows no longer use the deprecated `set-output` command (reported:
  [@zkamvar](https://github.com/zkamvar),
  [\#349](https://github.com/carpentries/sandpaper/issues/349); fixed
  [@zkamvar](https://github.com/zkamvar),
  [\#356](https://github.com/carpentries/sandpaper/issues/356))

- Versions of external actions have been updated to include
  `actions/core@1.10.0`

## sandpaper 0.10.6 (2022-10-25)

### NEW FEATURES

- Interactive functions to modify lesson structure
  ([`move_episode()`](https://carpentries.github.io/sandpaper/dev/reference/move_episode.md),
  `set_episode()`, etc) will now display a message if the user does not
  specify `write = TRUE`. This message will present a command that, when
  executed, will make the desired change (requested:
  [@tobyhodges](https://github.com/tobyhodges),
  [\#345](https://github.com/carpentries/sandpaper/issues/345), fixed:
  [@zkamvar](https://github.com/zkamvar),
  [\#352](https://github.com/carpentries/sandpaper/issues/352))

## sandpaper 0.10.5 (2022-10-24)

### MISC

- The the `source` config parameter will have the trailing `/` trimmed
  off when passed to the site so that the URL does not have two
  consectutive slashes.

## sandpaper 0.10.4 (2022-10-07)

### BUG FIX

- `renv/sandbox` no longer required in `.gitignore`. A new bug
  introduced in 0.10.2 caused all lessons built before 0.10.2 to fail
  when rebuilt on CI. This was due to the assumption that the .gitignore
  item `renv/sandbox` was strictly necessary with no clear method to
  automatically update a file like this (reported:
  [@zkamvar](https://github.com/zkamvar),
  [\#347](https://github.com/carpentries/sandpaper/issues/347); fixed:
  [@zkamvar](https://github.com/zkamvar),
  [\#348](https://github.com/carpentries/sandpaper/issues/348)).

## sandpaper 0.10.3 (2022-10-05)

### BUG FIX

- An accidental commit of `sandpaper-version.txt` in version 0.8.0
  inside the workflow templates folder was causing workflow update
  script to create pull requests for the workflows every week when they
  should have been much less frequent (the irony of this commit is that
  it will trigger another pull request) (fixed:
  [@zkamvar](https://github.com/zkamvar),
  [\#346](https://github.com/carpentries/sandpaper/issues/346)).

## sandpaper 0.10.2 (2022-10-04)

### BUG FIX

- The default `.gitignore` now has `renv/sandbox` to avoid a sandbox
  directory from being tracked by git. (see
  <https://github.com/rstudio/renv/issues/1088>) (reported:
  [@zkamvar](https://github.com/zkamvar);
  [\#344](https://github.com/carpentries/sandpaper/issues/344), fixed:
  [@zkamvar](https://github.com/zkamvar),
  [\#343](https://github.com/carpentries/sandpaper/issues/343))

### CONTINUOUS INTEGRATION

- The `deploy-aws.yaml` workflow has been removed as plans for its use
  is relegated to the beta stage of the workbench.

## sandpaper 0.10.1 (2022-09-28)

### NEW FEATURES

- If the `index.md (or Rmd)` file has a `title` YAML element, this will
  take precedence over the default title of “Summary and Setup”.
  (requested: [@SaraMorsy](https://github.com/SaraMorsy),
  [\#339](https://github.com/carpentries/sandpaper/issues/339); fixed:
  [@zkamvar](https://github.com/zkamvar)
  [\#342](https://github.com/carpentries/sandpaper/issues/342))

### BUG FIX

- Titles in navigation bar now have Markdown parsed correctly.

## sandpaper 0.10.0 (2022-09-19)

### NEW FEATURES

- The default behavior of
  [`create_episode()`](https://carpentries.github.io/sandpaper/dev/reference/create_episode.md)
  and
  [`create_lesson()`](https://carpentries.github.io/sandpaper/dev/reference/create_lesson.md)
  is to use episodes *without* numbered prefixes and will now
  automatically add episodes to the schedule (requested:
  [@tobyhodges](https://github.com/tobyhodges),
  [\#330](https://github.com/carpentries/sandpaper/issues/330); fixed
  [@zkamvar](https://github.com/zkamvar),
  [\#333](https://github.com/carpentries/sandpaper/issues/333))
- New function
  [`move_episode()`](https://carpentries.github.io/sandpaper/dev/reference/move_episode.md)
  allows the lesson contributor to move an episode in the schedule
  (requested: [@tobyhodges](https://github.com/tobyhodges),
  [\#330](https://github.com/carpentries/sandpaper/issues/330), fixed:
  [@zkamvar](https://github.com/zkamvar),
  [\#333](https://github.com/carpentries/sandpaper/issues/333))
- New functions `draft_lesson_md()` and `draft_lesson_rmd()` perform the
  task of `create_lesson(add = FALSE)`.
- Helper function
  [`strip_prefix()`](https://carpentries.github.io/sandpaper/dev/reference/strip_prefix.md)
  will automatically strip the prefixes for all episodes in the
  schedule.

### BUG FIX

- [`get_config()`](https://carpentries.github.io/sandpaper/dev/reference/get_config.md)
  now has a default `path` argument.
- A bug where anchors for callout headings with generic names
  (e.g. “discussion” or “keypoints”) were missing was fixed.

## sandpaper 0.9.6 (2022-09-15)

### BUG FIX

- A minor bug is fixed. It originated from the most recent update in
  {cli} where newlines in a span are collapsed. This will fix (reported:
  [@zkamvar](https://github.com/zkamvar),
  [\#336](https://github.com/carpentries/sandpaper/issues/336); fixed
  [@zkamvar](https://github.com/zkamvar)
  [\#337](https://github.com/carpentries/sandpaper/issues/337))

### DEPENDENCIES

- The minimum version of CLI has been updated to version 3.4.0

### CONTINUOUS INTEGRATION

- Pull request response workflows have been updated to make sure their
  conditionals do not always default to TRUE (see
  <https://github.com/carpentries/actions/pull/56>)

## sandpaper 0.9.5 (2022-08-30)

- css and js can now be embedded into individual pages for custom
  styling (see
  <https://bookdown.org/yihui/rmarkdown-cookbook/html-css.html> for
  implementation details).
- The pandoc extension `link_attributes` has been added to process
  custom link classes (see
  <https://pandoc.org/MANUAL.html#extension-link_attributes> for
  details).

## sandpaper 0.9.4 (2022-08-26)

- The CLI styling of an important message about {renv} has been fixed to
  be more readable (reported: [@zkamvar](https://github.com/zkamvar),
  [\#331](https://github.com/carpentries/sandpaper/issues/331); fixed:
  [@zkamvar](https://github.com/zkamvar),
  [\#332](https://github.com/carpentries/sandpaper/issues/332)).
- The bioschemas metadata version has been updated to 1.0 (reported:
  [@zkamvar](https://github.com/zkamvar),
  [\#329](https://github.com/carpentries/sandpaper/issues/329); fixed
  [@zkamvar](https://github.com/zkamvar),
  [\#332](https://github.com/carpentries/sandpaper/issues/332)).

## sandpaper 0.9.3 (2022-08-12)

### MISC

- A test that was failing on the R-universe has been skipped
- documentation has been updated to detail the expected and optional
  values in config.yaml in
  [`set_dropdown()`](https://carpentries.github.io/sandpaper/dev/reference/set_dropdown.md)
- The template for the code of conduct has been updated to reflect our
  style guide

## sandpaper 0.9.2 (2022-08-09)

### CONTINUOUS INTEGRATION

- The version of the s3-sync action has been corrected. This only
  affects lessons that deploy to AWS

## sandpaper 0.9.1 (2022-08-09)

### MISC

- Anchor links are now included in all sections and callouts for easy
  navigation to sections. Thanks to [@fiveop](https://github.com/fiveop)
  and [@anenadic](https://github.com/anenadic) for requesting this
  feature. requested in
  [\#285](https://github.com/carpentries/sandpaper/issues/285) and
  <https://github.com/carpentries/workbench/issues/28>; fixed in
  [\#325](https://github.com/carpentries/sandpaper/issues/325)

## sandpaper 0.9.0 (2022-07-12)

### MISC

- [`set_config()`](https://carpentries.github.io/sandpaper/dev/reference/set_config.md)
  gains the option `create`, which will create new variables if they do
  not exist.

### CONTINUOUS INTEGRATION

- A new workflow called `deploy-aws.yaml` has been created to deploy a
  site to AWS when the right secrets from AWS are available. Because
  this workflow does not affect normal use, I am relegating this to a
  patch release.

## sandpaper 0.8.0 (2022-07-06)

### CONTINUOUS INTEGRATION

- A new workflow called `pr-preflight.yaml` has been created to perform
  a quick pre-flight check on the pull request to ensure that there is
  no malicious activity on the lesson itself, which may look like
  modifying both workflow and lesson files in the same pull request. For
  lessons that transition to the workbench from styles in official and
  community-developed lessons, an extra check is added that will
  validate the branch of the incoming PR does not contain invalid
  commits.

- Pull Request workflows have been simplified.

## sandpaper 0.7.1 (2022-07-05)

### BUG FIX

- A bug where `fail_on_error` defaulted to `true` has been fixed. This
  will default to `false` if they key is not present in `config.yaml`
  ([\#314](https://github.com/carpentries/sandpaper/issues/314),
  [@zkamvar](https://github.com/zkamvar)).

## sandpaper 0.7.0 (2022-07-01)

### NEW FEATURE

- Placing `fail_on_error: true` in `config.yaml` will set the global
  chunk option `error = FALSE` for R Markdown documents, meaning that if
  an error is produced from a chunk, the build will fail unless that
  chunk explicitly uses the `error = TRUE` option. (requested:
  [\#306](https://github.com/carpentries/sandpaper/issues/306) by
  [@davidps](https://github.com/davidps), implemented:
  [\#310](https://github.com/carpentries/sandpaper/issues/310) by
  [@zkamvar](https://github.com/zkamvar))

## sandpaper 0.6.2 (2022-06-24)

### BUG FIX

- The sidebar navigation in mobile and tablet views now includes all the
  information that was included in the navigation bar for the desktop
  mode. (reported:
  <https://github.com/carpentries/workbench/issues/16#issuecomment-1165307355>
  by [@Athanasiamo](https://github.com/Athanasiamo) and
  [\#306](https://github.com/carpentries/sandpaper/issues/306), fixed:
  [\#309](https://github.com/carpentries/sandpaper/issues/309) by
  [@zkamvar](https://github.com/zkamvar))
- the downit shims have been updated to be resiliant to upstream changes

## sandpaper 0.6.1 (2022-06-22)

### MISC

- the `config.yaml` template has been updated to default to incubator
  lessons and has more helpful information included about formatting
  ([@tobyhodges](https://github.com/tobyhodges),
  [\#302](https://github.com/carpentries/sandpaper/issues/302))

## sandpaper 0.6.0 (2022-06-10)

### NEW FEATURES

- [`create_lesson()`](https://carpentries.github.io/sandpaper/dev/reference/create_lesson.md)
  gains the `rmd` parameter, which is a logical indicator that the
  lesson should use R Markdown (`TRUE` by default). When this is
  `FALSE`, a markdown lesson is created and no package cache is
  initialised.
- [`create_episode()`](https://carpentries.github.io/sandpaper/dev/reference/create_episode.md)
  gains the `ext` parameter, which allows users to create plain markdown
  episodes if they do not need R Markdown functionality (see
  <https://github.com/carpentries/sandpaper/issues/296>).

### BUG FIX

- [`create_episode()`](https://carpentries.github.io/sandpaper/dev/reference/create_episode.md)
  will now slugify titles so that they only contain lowercase ASCII
  letters, numbers and UTF-8 characters with words separated by single
  hyphens (see <https://github.com/carpentries/sandpaper/issues/294>).

### MISC

- The internal `check_episode()` function has been removed as it was
  over- engineered with marginal value.

## sandpaper 0.5.8 (2022-06-06)

### CONTINUOUS INTEGRATION

- Running the main workflow from GitHub’s actions tab now uses a
  checkbox to indicate if the markdown file cache should be cleared.
- The README file for the workflows no longer contains a link to an
  image that does not exist.

## sandpaper 0.5.7 (2022-05-27)

### CONTINUOUS INTEGRATION

- Workflows that update lesson elements will now report a more obvious
  summary of next steps to take with an invalid token (see
  <https://github.com/carpentries/actions/pull/45>)

## sandpaper 0.5.6 (2022-05-25)

### CONTINUOUS INTEGRATION

- Pull requests will now report on elements of the lesson that do not
  pass checks.

## sandpaper 0.5.5 (2022-05-23)

### MISC

- New YAML items can now be added at-will and will be available to
  varnish in a `{{#yaml}}` context.
- internal function
  [`set_dropdown()`](https://carpentries.github.io/sandpaper/dev/reference/set_dropdown.md)
  will preserve the yaml items that are not explicitly coded in the
  config menu.

## sandpaper 0.5.4 (2022-05-18)

### BUG FIX

- [`build_episode_md()`](https://carpentries.github.io/sandpaper/dev/reference/build_episode_md.md)
  argument `workenv` now defaults to
  [`globalenv()`](https://rdrr.io/r/base/environment.html) to avoid S3
  dispatch issues that can occur in
  [`new.env()`](https://rdrr.io/r/base/environment.html) (see
  <https://github.com/carpentries/sandpaper/issues/288>)

## sandpaper 0.5.3 (2022-05-18)

### BUG FIX

- Episodes with ampersands in their titles no longer break the aggregate
  page building.

## sandpaper 0.5.2 (2022-05-16)

### TEMPORARY BUG FIX

- {downlit} shim has been updated to no longer fail when parsing BASH
  globs. (see <https://github.com/r-lib/downlit/pull/138>)

## sandpaper 0.5.1 (2022-05-03)

### NEW FEATURES

- The sidebar now enumerates episodes so it is easier for instructors
  and learners to indicate episode by number instead of by name
  (suggested by [@fiveop](https://github.com/fiveop) in
  [\#276](https://github.com/carpentries/sandpaper/issues/276)).
  ([@zkamvar](https://github.com/zkamvar),
  [\#277](https://github.com/carpentries/sandpaper/issues/277))

### NEW SUGGESTS

- {mockr} is now a suggested package (aka soft-dependency) to facilitate
  testing functions that do not need an entire lesson set up to test
  their functionality

### CONTINUOUS INTEGRATION

- `setup-r` and `setup-pandoc` actions have been pinned to version 2
- `setup-r` action now uses the default R installation on GitHub’s
  runner, which decreases build times by ~ 1 minute.
- All R actions will use the RStudio Package Manager, which should avoid
  overly lengthy build times.
- explicit permissions have been set for the deploy workflow
  ([@zkamvar](https://github.com/zkamvar),
  [\#279](https://github.com/carpentries/sandpaper/issues/279))

## sandpaper 0.5.0 (2022-04-22)

### NEW FEATURES

- `images.html` is built with internal function
  [`build_images()`](https://carpentries.github.io/sandpaper/dev/reference/build_agg.md),
  collecting all images and displaying alt text for non-screen reader
  users (while marking those paragraphs as `aria-hidden` so that screen
  reader users do not have it read twice).
- `instructor-notes.html` is now built with the internal function
  [`build_instructor_notes()`](https://carpentries.github.io/sandpaper/dev/reference/build_agg.md)
  and now collects instructor notes from the episodes in a section
  called `aggregate-instructor-notes`.

### MISC

- The internal
  [`build_agg_page()`](https://carpentries.github.io/sandpaper/dev/reference/build_agg.md)
  has a new argument, `append`, which takes an XPath expression of what
  node should have children appended. Defaults to `"self::node()"`. An
  example of alternate usage is in
  [`build_instructor_notes()`](https://carpentries.github.io/sandpaper/dev/reference/build_agg.md),
  which uses `section[@id='aggregate-instructor-notes']`.

## sandpaper 0.4.1 (2022-04-21)

### MISC

- The All in One page and Keypoints page have been redesigned. These now
  both use the underlying internal function
  [`build_agg_page()`](https://carpentries.github.io/sandpaper/dev/reference/build_agg.md)
  (build aggregate page). This allows slow templating processes to be
  performed once and cached instead of repeated for each page. It
  provides a framework for future aggregate pages (such as figures,
  instructor notes, glossary, etc).
- A message is now printed when Keypoints and All-in-one pages are
  written to disk if `quiet = FALSE`.

## sandpaper 0.4.0 (2022-04-13)

### NEW FEATURES

- An all-in-one page is now available for lesson websites at `/aio.html`
  and `instructor/aio.html`.

### MISC

- Provisioning of the global lesson element cache (metadata, AST, and
  global variables for varnish) is now all executed via
  [`this_lesson()`](https://carpentries.github.io/sandpaper/dev/reference/lesson_storage.md),
  which is run during
  [`validate_lesson()`](https://carpentries.github.io/sandpaper/dev/reference/validate_lesson.md).
  This simplifies the setup a bit, and provides the same method of cache
  invalidation (checking git outputs) for all of these elements

## sandpaper 0.3.6 (2022-04-09)

### MISC

- custom sandpaper and varnish engines will be properly linked to the
  footer of the lesson pages via this version and varnish 0.1.8.
- testthat tests have been updated.
- a diagram in the vingettes has been updated to reflect the parallel
  roles of sandpaper and pegboard to a lesson.

## sandpaper 0.3.5 (2022-03-04)

### BUG FIX

- `keypoints.html` is now rendered as `key-points.html` to fix
  navigation error with varnish.

## sandpaper 0.3.4 (2022-03-02)

### CONTINUOUS INTEGRATION

- pr-receive.yaml has been updated to not report errors for workflow
  updates. See <https://github.com/carpentries/sandpaper/issues/263> for
  details

## sandpaper 0.3.3 (2022-02-28)

### BUG FIXES

- Links from the index page to the setup or any episodes now correctly
  render
- Links to the setup page now redirect to `index.html#setup`
  ([@zkamvar](https://github.com/zkamvar),
  [\#262](https://github.com/carpentries/sandpaper/issues/262))
- The setup page is now included in the instructor view after the
  schedule
- The setup in the index page is now a separate section with the id
  “setup”
- The schedule in the instructor index page is now in a separate section
  with the id “schedule”

### DEPENDENCIES

- The minimum version of {varnish} required is now 0.1.5

### CONTINUOUS INTEGRATION

- A small bug in the update cache workflow that caused a silent error
  with no detremental effect was fixed
  ([@zkamvar](https://github.com/zkamvar),
  [\#250](https://github.com/carpentries/sandpaper/issues/250))

## sandpaper 0.3.2 (2022-02-25)

### DEPENDENCIES

- The minimum version for {pegboard} should be at least 0.2.3 to
  accomodate div validation ([@sstevens2](https://github.com/sstevens2),
  [\#259](https://github.com/carpentries/sandpaper/issues/259))
- The minimuim version for {varnish} should be at least 1.5.0.

## sandpaper 0.3.1 (2022-02-23)

### BUG FIXES

- Documents with footnotes without trailing newlines will now parse the
  external links correctly by adding a newline between the document and
  the links.

## sandpaper 0.3.0 (2022-02-22)

### NEW FEATURES

- Common links for markdown lessons can be included via a file at the
  top of the lesson called `links.md`. If this file exists, it will be
  concatenated on each markdown file before it is rendered to HTML.
  Thanks to [@sstevens2](https://github.com/sstevens2) for bringing this
  feature up ([@zkamvar](https://github.com/zkamvar),
  [\#257](https://github.com/carpentries/sandpaper/issues/257))
- [`create_lesson()`](https://carpentries.github.io/sandpaper/dev/reference/create_lesson.md)
  now includes `links.md` in main directory.
- A new help page called
  [`?sandpaper.options`](https://carpentries.github.io/sandpaper/dev/reference/sandpaper.options.md)
  provides documentation on the global options used in a sandpaper
  lesson (subject to change).

## sandpaper 0.2.0 (2022-02-18)

### NEW FEATURES

- [`validate_lesson()`](https://carpentries.github.io/sandpaper/dev/reference/validate_lesson.md)
  will perform checks on links and fenced divs in your lesson. This is
  now included in calls to
  [`build_lesson()`](https://carpentries.github.io/sandpaper/dev/reference/build_lesson.md),
  [`ci_deploy()`](https://carpentries.github.io/sandpaper/dev/reference/ci_deploy.md)
  and
  [`serve()`](https://carpentries.github.io/sandpaper/dev/reference/serve.md)
  ([@zkamvar](https://github.com/zkamvar),
  [\#255](https://github.com/carpentries/sandpaper/issues/255))

### DEPENDENCIES

- the minimum pegboard version is now 0.2.0

### BUG FIXES

- internal function
  [`this_lesson()`](https://carpentries.github.io/sandpaper/dev/reference/lesson_storage.md)
  will now properly invalidate and reset if there is a change in commit
  (e.g. the lesson to build has switched).

## sandpaper 0.1.6 (2022-02-14)

### BUG FIX

- [`set_dropdown()`](https://carpentries.github.io/sandpaper/dev/reference/set_dropdown.md)
  no longer fails with {cli} version 3.2.0

## sandpaper 0.1.5 (2022-02-11)

### INTERNAL

- metadata is now processed more consistently across page types, which
  will first and foremost reduces some of the code complexity, and
  second, allows for more rapid development of future page types. In
  some instances, this will result in a marginal improvement of build
  times, but it will not likely be noticable.

## sandpaper 0.1.4 (2022-02-10)

### BUG FIX

- [`sandpaper::build_lesson()`](https://carpentries.github.io/sandpaper/dev/reference/build_lesson.md)
  no longer creates an infinite loop when called after
  [`sandpaper::serve()`](https://carpentries.github.io/sandpaper/dev/reference/serve.md)
  ([@zkamvar](https://github.com/zkamvar),
  [\#247](https://github.com/carpentries/sandpaper/issues/247))

## sandpaper 0.1.3 (2022-02-03)

### MISC

- Clarify license information to specify the copyright is held by The
  Carpentries

## sandpaper 0.1.2 (2022-02-02)

### BUG FIX

- invalid sitemaps have been fixed to have the correct namespace and
  include a slash in the site name.
- a test requring pandoc 2.11 has been suppressed on systems without
  that version of pandoc.

## sandpaper 0.1.1 (2022-02-01)

### DEPENDENCIES

- The {pegboard} package is now required to be 0.1.0 or greater due to a
  fix for generating the keypoints page
  (<https://github.com/carpentries/pegboard/pull/76>)

### METADATA

- The metadata included in the lesson footer now correctly states the
  `@type` as `TrainingMaterial` ([@zkamvar](https://github.com/zkamvar),
  [\#236](https://github.com/carpentries/sandpaper/issues/236))
- A basic sitemap is now constructed for the lesson
  ([@zkamvar](https://github.com/zkamvar),
  [\#243](https://github.com/carpentries/sandpaper/issues/243))

### BUG FIX

- Empty pages will no longer throw errors in rendering and they will not
  be included in the output ([@zkamvar](https://github.com/zkamvar),
  [\#237](https://github.com/carpentries/sandpaper/issues/237))

## sandpaper 0.1.0 (2022-02-01)

### BUG FIXES

- the internal function
  [`render_html()`](https://carpentries.github.io/sandpaper/dev/reference/render_html.md)
  now passes the `--preserve-tabs` parameter to prevent pandoc from
  removing educationally relevant information from the lessons.
- when rebuilding a lesson with `ci_deploy(..., rebuild = TRUE)`,
  detritus in the lesson site will be cleaned
  ([@zkamvar](https://github.com/zkamvar),
  [\#91](https://github.com/carpentries/sandpaper/issues/91)).

### BREAKING CHANGES

- Add support for the updated frontend in {varnish}. This means that you
  will need varnish 0.1.0 installed in order to use this update. This
  change includes modifications to the lua filters along with the
  general handling of the HTML elements which means that older versions
  of varnish will cease to work.
- code blocks will no longer contain package links. While the links may
  have been handy for sighted users to explore documentation, these may
  represent objstructions for users who rely on screen-readers.

### INSTRUCTOR VIEW

There are now two views of the lesson: instructor view and learner view.
The biggest difference is that instructor view gains the
`instructor-note` sections (if they exist).

- Static pages for each view. This means that you can toggle between the
  pages without needing javascript.
- Removed timings on the learner view (to avoid discouraging our
  learners)
- Setup page replaces the schedule on the index page
- There are additional buttons included on the instructor view that do
  not yet work, but will work at some point!

The only downside at the moment is that building the lesson takes *a
bit* longer due to the fact that we now have to render two pages for
each change.

### NAVIGATION

A persistant sidebar with links for the main content of the lesson will
be present on all pages of the lesson. The navigation bar will
prioritise items used most frequently by the respective audiences:

- Learners: Key Points, Glossary, Learner Profiles, “Additional
  Information” (dropdown)
- Instructors: Key Points, Instructor Notes, Extract All Images, “More”
  (dropdown)

### MISC

- The build database now gains a “date” column which will indicate the
  date the file was last rendered to markdown. This allows the “last
  updated on” to better reflect the state of the contents from the
  rendered files.
- The default configuration file now includes a `keywords:` item where
  you can place a comma-separated list of keywords to include in the
  site’s metadata
- The configuration file now also includes an example of what
  provisioned navigation looks like
- The default episode template now refers to the correct documentation
  links and provides examples of how to represent code blocks that are
  not evaluated.
- The setup page now contains a structured example setup page that shows
  how to provide dropdown menus for different operating systems
  ([@zkamvar](https://github.com/zkamvar),
  [\#28](https://github.com/carpentries/sandpaper/issues/28)).
- If the user does not have a github PAT and we can not detect the name
  of the repository from the git setup, then the source goes to an
  example.com link.

## sandpaper 0.0.0.9075

### BUG FIX

- Episodes with missing timing metadata will no longer fail if they also
  contain questions and objectives blocks.
  ([@zkamvar](https://github.com/zkamvar),
  [\#222](https://github.com/carpentries/sandpaper/issues/222)).

## sandpaper 0.0.0.9074

### BUG FIX

- Internal function `renv_cache_available()` continues to work with
  {renv} 0.15.0. This new version of {renv} changed the default value of
  a configuration setting for the system cache from a logical to NULL,
  which casued a logical operation to fail.
  ([@zkamvar](https://github.com/zkamvar),
  [\#223](https://github.com/carpentries/sandpaper/issues/223))

## sandpaper 0.0.0.9073

### DEPENDENCY UPDATE

- {renv} is pinned to version 0.14.0 as version 0.13.2 would throw an
  error when checking for consent.

## sandpaper 0.0.0.9072

### NEW FUNCTION

- [`serve()`](https://carpentries.github.io/sandpaper/dev/reference/serve.md)
  now allows you to work on your lesson and have it automatically
  rebuild whenever you save your files to disk.

### NEW DEPENDENCIES

- {servr} is now used in the
  [`serve()`](https://carpentries.github.io/sandpaper/dev/reference/serve.md)
  function.

## sandpaper 0.0.0.9071

### NEW FEATURE

- Lesson blocks are now treated the same as other blocks. This is a
  placeholder for us to better test the separation of the lesson veiw
  from the default learner view.

## sandpaper 0.0.0.9070

### BUG FIX

- Lessons that have readonly zlib compressed files (read: git objects)
  can now have their websites built.
  ([@zkamvar](https://github.com/zkamvar),
  [\#214](https://github.com/carpentries/sandpaper/issues/214))

## sandpaper 0.0.0.9069

### MISC

- [`build_handout()`](https://carpentries.github.io/sandpaper/dev/reference/build_handout.md)
  is now an officially exported function.
- The pkgdown documentation has been updated

## sandpaper 0.0.0.9068

### CONTINUOUS INTEGRATION

- Workflows have been updated to use `ubuntu-latest` instead of
  `macOS-11`. The macOS runners were often ~ 1 minute faster than the
  ubuntu runners, but the tradeoff was potential failures when packages
  were not available as binary versions and would need compilation with
  external C libraries (along with runs failing due to brew timeouts).
  This update coincides with an update for the github actions, which
  will now check and install the ubuntu dependencies before
  updating/installing packages. ([@zkamvar](https://github.com/zkamvar),
  [\#184](https://github.com/carpentries/sandpaper/issues/184))

## sandpaper 0.0.0.9067

### BUG FIX

- A situation where git would fail if it could not remove everything was
  fixed ([\#206](https://github.com/carpentries/sandpaper/issues/206),
  [@zkamvar](https://github.com/zkamvar))
- Addressed CLI failures due to glue version 1.5.0
  (<https://github.com/r-lib/cli/issues/370#issuecomment-965496848>)

## sandpaper 0.0.0.9066

### API CHANGE

- [`set_config()`](https://carpentries.github.io/sandpaper/dev/reference/set_config.md)
  now takes a named vector/list instead of a pair of vectors.

## sandpaper 0.0.0.9065

### NEW FEATURES

- [`set_config()`](https://carpentries.github.io/sandpaper/dev/reference/set_config.md)
  will set singular items in the configuration file
  ([@zkamvar](https://github.com/zkamvar),
  [\#193](https://github.com/carpentries/sandpaper/issues/193))

## sandpaper 0.0.0.9064

### BUG FIX

- Package discovery now respects the lesson environment, which was
  unfixed from 0.0.0.9063

## sandpaper 0.0.0.9063

### BUG FIX

- The package cache can now be built from external {renv} environments
  ([@zkamvar](https://github.com/zkamvar),
  [\#197](https://github.com/carpentries/sandpaper/issues/197)).

## sandpaper 0.0.0.9062

### BUG FIX

- New lessons that specify custom titles will have them reflected in the
  config file ([@zkamvar](https://github.com/zkamvar),
  [\#195](https://github.com/carpentries/sandpaper/issues/195)).

## sandpaper 0.0.0.9061

### BUG FIX

- lessons with colons in the title are now correctly processed
  ([@zkamvar](https://github.com/zkamvar),
  [\#192](https://github.com/carpentries/sandpaper/issues/192))
- code injection in yaml is now protected against by setting
  `eval.expr = FALSE` in all yaml parsing calls.

## sandpaper 0.0.0.9060

### BUG FIX

- The title of the lesson will now appear in the index page.

### MISC

- The translation script no longer lives in the lesson repo and has been
  moved (and modified) to <https://data-lessons/lesson-transition/>

## sandpaper 0.0.0.9059

### CONTINUOUS INTEGRATION

- The scheduler for `update-cache.yaml` has been fixed to run strictly
  on the first Tuesday of the month instead of the first seven days of
  the month AND on Tuesdays.

## sandpaper 0.0.0.9058

### CONTINUOUS INTEGRATION

- `update-cache.yaml` has been simplified to pull from the
  carpentries/actions repository and now updates packages that were not
  previously included in the lockfile
  ([\#185](https://github.com/carpentries/sandpaper/issues/185)).

## sandpaper 0.0.0.9057

### CONTINUOUS INTEGRATION

- `update-cache.yaml` has been fixed from a regression introduced with
  4b8b14d088d03a8a9c6c90e974bb53c35691fb49 where the workflow would not
  run because it did not check out the repository beforehand.

## sandpaper 0.0.0.9056

### BUG FIX

- [`update_github_workflows()`](https://carpentries.github.io/sandpaper/dev/reference/update_github_workflows.md)
  now sets `clean = "*.yaml"` by default to align with the behavior of
  the GitHub workflow and to prevent stale workflows from being present
  in the repository.
  ([\#181](https://github.com/carpentries/sandpaper/issues/181),
  [@zkamvar](https://github.com/zkamvar))

## sandpaper 0.0.0.9055

### CONTINUOUS INTEGRATION

- `sandpaper-main.yaml` and `pr-receive.yaml` have been simplified by
  using composite actions hosted in
  `carpentries/actions/setup-sandpaper` and
  `carpentries/actions/setup-deps`.
- The caching mechanism for R packages and the package cache can now be
  reset by modifying a per-repository secret called `CACHE_VERSION`.

### BUG FIX

- A bug introduced in 0.0.0.9054 where dependencies were not discovered
  was fixed.

## sandpaper 0.0.0.9054

### MISC

- [`manage_deps()`](https://carpentries.github.io/sandpaper/dev/reference/dependency_management.md)
  runs slightly faster now that it no longer runs
  [`renv::hydrate()`](https://rstudio.github.io/renv/reference/hydrate.html)
  if no new packages have been added in the lesson.

## sandpaper 0.0.0.9053

### NEW FEATURES

- setting `option(sandpaper.handout = TRUE)` will create a code handout
  for R lessons that will live in `/files/code-handout.R` on your site.

### MISC

- An internal caching mechanism has been added for
  [`pegboard::Lesson`](https://carpentries.github.io/pegboard/reference/Lesson.html)
  objects that we use for extracting components for the syllabus and the
  handout. See `?lesson_storage` for details.

## sandpaper 0.0.0.9052

### CONTINUOUS INTEGRATION

- `pr-receive.yaml` has fixed spelling.
- `pr-receive.yaml` has changed to short-cut the invalid PR messages and
  no longer build the lesson if the PR is invalid. Instead, it will emit
  the same warning message without building artifacts.
- `pr-comment.yaml` will no longer fail when no artifacts exist (which
  would cause extraneous emails for users).

### DOCUMENTATION

- Documentation for test fixtures has been improved to include branch
  functions.

## sandpaper 0.0.0.9051

### MISC

The template for the pull request message reverts back to two-dot diff
notation between branches, which is temporary until
[\#169](https://github.com/carpentries/sandpaper/issues/169) can be
addressed. Linebreaks within paragraphs have been removed to avoid
github formatting them as linebreaks.

## sandpaper 0.0.0.9050

This update for {sandpaper} brings in dependency management for lessons
with generated content which will make collaboration between these
lessons much easier and less invasive by establishing a package cache
and lockfile via the {renv} R package.

### DEPENDENCY MANAGEMENT

#### Introduction

We use the {renv} package for controlling dependency management in the
lesson, which is contained in a {renv} profile called
“lesson-requirements”. We have implemented this as a profile instead of
the default {renv} environment to give the maintainers flexibility of
whether or not they want to use the package cache.

#### Consent for Using the Package Cache

- `getOption('sandpaper.use_renv')` will be set when {sandpaper} loads
  to detect if the contributor has previously consented to use the
  {renv} package. If this is `TRUE`, the lesson will use a package
  cache, otherwise, the lesson will use the default library.
- [`use_package_cache()`](https://carpentries.github.io/sandpaper/dev/reference/package_cache.md)
  will give consent to {sandpaper} to create and use a package cache via
  {renv}. Internally, this enforces that
  `options(sandpaper.use_renv = TRUE)`.
- [`no_package_cache()`](https://carpentries.github.io/sandpaper/dev/reference/package_cache.md)
  does the opposite of
  [`use_package_cache()`](https://carpentries.github.io/sandpaper/dev/reference/package_cache.md)
  and revokes consent to use the package cache in a lesson temporarily.
  This can be useful in situtations where the cache is mis-behaving or
  you want to test the lesson using a newer set of packages. Internally,
  this enforces that `options(sandpaper.use_renv = FALSE)`.
- `package_cache_trigger(TRUE)` allows you to trigger a full rebuild
  when the lockfile changes. This is set to `TRUE` by default on
  [`ci_build_markdown()`](https://carpentries.github.io/sandpaper/dev/reference/ci_build.md)

#### Managing the Package Cache

- [`manage_deps()`](https://carpentries.github.io/sandpaper/dev/reference/dependency_management.md)
  is a new function that will manage dependencies for a lesson. This is
  called both in
  [`create_lesson()`](https://carpentries.github.io/sandpaper/dev/reference/create_lesson.md)
  and
  [`build_markdown()`](https://carpentries.github.io/sandpaper/dev/reference/build_markdown.md)
  to ensure that the correct dependencies for the lesson are installed.
  This explicitly calls
  [`use_package_cache()`](https://carpentries.github.io/sandpaper/dev/reference/package_cache.md)
  when it runs.
- [`update_cache()`](https://carpentries.github.io/sandpaper/dev/reference/dependency_management.md)
  will bring in updates for the lesson cache.
- [`pin_version()`](https://carpentries.github.io/sandpaper/dev/reference/dependency_management.md)
  will pin packages to a specific version, allowing authors to upgrade
  or downgrade packages at will.

### NEW FEATURES

- [`create_lesson()`](https://carpentries.github.io/sandpaper/dev/reference/create_lesson.md)
  now additionally will create a {renv} profile called “packages” in the
  lesson repository if `getOption('sandpaper.use_renv')` is `TRUE`. This
  will make the lesson more portable.
- index and README files can now be Rmd files (though it is recommended
  to use .renvignore for these files if they are to avoid {sandpaper}
  becoming part of the package cache).
- internal function
  [`ci_deploy()`](https://carpentries.github.io/sandpaper/dev/reference/ci_deploy.md)
  will set `sandpaper.use_renv` option to `TRUE`
- [`build_markdown()`](https://carpentries.github.io/sandpaper/dev/reference/build_markdown.md)
  and thus
  [`build_lesson()`](https://carpentries.github.io/sandpaper/dev/reference/build_lesson.md)
  will now cache `config.yaml` and `renv.lock`. It will no longer step
  through the build process if no markdown files need to be rebuilt.
  This will cause any project built with previous versions of sandpaper
  to be fully rebuilt.
- [`sandpaper_site()`](https://carpentries.github.io/sandpaper/dev/reference/sandpaper_site.md)
  (and thus,
  [`build_lesson()`](https://carpentries.github.io/sandpaper/dev/reference/build_lesson.md))
  now can take in a single file for rendering and render that specific
  file regardless if it is present in the cache without rendering other
  files. This further addresses
  [\#77](https://github.com/carpentries/sandpaper/issues/77). (n.b. this
  involved changes to
  [`build_markdown()`](https://carpentries.github.io/sandpaper/dev/reference/build_markdown.md),
  [`build_site()`](https://carpentries.github.io/sandpaper/dev/reference/build_site.md),
  and
  [`build_status()`](https://carpentries.github.io/sandpaper/dev/reference/build_status.md)).
- `varnish_vars()` is a list that contains commonly used variables in
  the lesson that can not be contained in the config.yaml
- `build_episode()` and
  [`build_home()`](https://carpentries.github.io/sandpaper/dev/reference/build_home.md)
  now supply default variables to varnish.

### CONTINOUS INTEGRATION

- unexported function
  [`ci_deploy()`](https://carpentries.github.io/sandpaper/dev/reference/ci_deploy.md)
  will now automatically check and set the git user and email.
- `sandpaper-main.yaml` and `pr-receive.yaml` have been updated to
  include the {renv} cache, but they will skip these steps for markdown
  lessons.
- `update-cache.yaml` is a new workflow that will update the package
  cache lockfile and create a pull request to trigger new builds if the
  lesson uses {renv}.
- `update-workflows.yaml` now produces more informative instructions for
  creating a repository secret.

### MISC

- some of the {callr} functions have been made non-anonymous and moved
  to a separate file so they could be tested independently.

### BUG FIX

- changes to `config.yaml` are now reflected on the lesson site without
  rebuilding (fixes
  [\#75](https://github.com/carpentries/sandpaper/issues/75))
- knitr option `root.dir` has been set to the output directory to avoid
  generated content from entering the source.

## sandpaper 0.0.0.9049

This is a placeholder for the testing of 0.0.0.9050.

## sandpaper 0.0.0.9048

### BUG FIX

- pandoc lua filter no longer errors on raw div HTML elements with no
  class ([@zkamvar](https://github.com/zkamvar),
  [\#166](https://github.com/carpentries/sandpaper/issues/166))

## sandpaper 0.0.0.9047

### CONTINUOUS INTEGRATION

- The `update-workflows.yaml` workflow now checks if the
  `SANDPAPER_WORKFLOW` secret is valid. If not, it provides instructions
  for creating a new secret.

## sandpaper 0.0.0.9046

### CONTINUOUS INTEGRATION

- Weekly run pull requests now default to “weekly run” for “who
  triggered this pull request”

## sandpaper 0.0.0.9045

### CONTINUOUS INTEGRATION

- Weekly run has been added for the workflows action
- Actions have been updated to reflect the zkamvar -\> carpenteries
  repository transfer ([@zkamvar](https://github.com/zkamvar),
  [\#156](https://github.com/carpentries/sandpaper/issues/156))

## sandpaper 0.0.0.9044

### CONTIUOUS INTEGRATION

- The `update-workflow.yaml` parameters have been fixed to not use
  wildcards

### MISC

- [`update_github_workflows()`](https://carpentries.github.io/sandpaper/dev/reference/update_github_workflows.md)
  gains a `clean` argument and now will print status reports at the end.

## sandpaper 0.0.0.9043

### CONTINUOUS INTEGRATION

- The `update-workflow.yaml` workflow has been updated to use the github
  action hosted on `zkamvar/actions` (soon to be transferred to The
  Carpentries account
- The names of the actions displayed on GitHub have been updated to be
  more descriptive.
- The script in `inst/scripts/update-workflows.sh` has been removed in
  favor of the github action.

## sandpaper 0.0.0.9042

### CONTINUOUS INTEGRATION

- An experimental `update-workflow.yaml` workflow has been created which
  will create a pull request that will update the workflows. It is still
  *very* experimental and it requires a scoped with repo and scope, but,
  nevertheless, the concept is currently valid.

## sandpaper 0.0.0.9041

### MISC

- `fetch_github_workflows()` has been renamed to
  [`update_github_workflows()`](https://carpentries.github.io/sandpaper/dev/reference/update_github_workflows.md)
- github workflows are no longer downloaded from an external source;
  they now live in inst/workflows. This will reduce the internet
  connection requirements for setting up a lesson and testing sandpaper.
- [`create_lesson()`](https://carpentries.github.io/sandpaper/dev/reference/create_lesson.md)
  now reports progress as it goes along
- tests were updated to use the fixtures

## sandpaper 0.0.0.9040

### CONTINUOUS INTEGRATION

- [`ci_deploy()`](https://carpentries.github.io/sandpaper/dev/reference/ci_deploy.md)
  gains the `reset` argument, which can be used to clear the cache for a
  clean build of the lesson.
- [`ci_deploy()`](https://carpentries.github.io/sandpaper/dev/reference/ci_deploy.md)
  now uses
  [`ci_build_markdown()`](https://carpentries.github.io/sandpaper/dev/reference/ci_build.md)
  and
  [`ci_build_site()`](https://carpentries.github.io/sandpaper/dev/reference/ci_build.md),
  internally

## sandpaper 0.0.0.9039

### CONTINUOUS INTEGRATION

- [`ci_session_info()`](https://carpentries.github.io/sandpaper/dev/reference/ci_session_info.md)
  will report the session information, which will help clean up the
  workflow files.

## sandpaper 0.0.0.9038

### CONTINUOUS INTEGRATION

- Fix broken deploy process on continuous integration caused by
  attempting to fetch all branches in a shallow clone
  ([@zkamvar](https://github.com/zkamvar),
  [\#142](https://github.com/carpentries/sandpaper/issues/142))

## sandpaper 0.0.0.9037

### CONTINUOUS INTEGRATION

- Output of `ci_bundle_pr_artifacts()` no longer escapes HTML-like
  output in the diff summary.
- remove {xml2} from explicit dependencies

## sandpaper 0.0.0.9036

### CONTINUOUS INTEGRATION

- Documentation for
  [`git_worktree_setup()`](https://carpentries.github.io/sandpaper/dev/reference/git_worktree.md)
  has been added for future versions of the maintainer and future
  contributors.
- `ci_bundle_pr_artifacts()` is a new internal function that will create
  artifacts for GitHub to upload upon receipt of a pull request. This
  will replace clunky shell code that lived inside a YAML configuration
  file. ([@zkamvar](https://github.com/zkamvar),
  [\#139](https://github.com/carpentries/sandpaper/issues/139))
- add {brio} to soft dependencies (for testing, but maybe could speed
  up???)

## sandpaper 0.0.0.9035

### CONTINUOUS INTEGRATION

- Tests for git operations were added to be more robust
  ([@zkamvar](https://github.com/zkamvar),
  [\#137](https://github.com/carpentries/sandpaper/issues/137))
- new test fixtures for a local remote repository was added to aid the
  above git tests.

## sandpaper 0.0.0.9034

### NEW FEATURES

- Authors can now cross-link between files within the lesson as they
  appear in the lesson instead of trying to guess how the link would
  appear on the website. For example, if you wanted to reference
  `learners/setup.md` in `episodes/introduction.md`, you would write
  `[setup](../learners/setup.md)` and it will be automatically converted
  to the correct URL in the website
  ([\#43](https://github.com/carpentries/sandpaper/issues/43)). This is
  still backwards compatible with the previous iteration of writing the
  flattened link (as it would appear on the website).

## sandpaper 0.0.0.9033

### NEW FEATURES

- [`get_drafts()`](https://carpentries.github.io/sandpaper/dev/reference/get_drafts.md)
  will report any markdown files that are not currently published in the
  lesson.
- Draft alert notifications are controlled by the
  `"sandpaper.show_draft"` option. To turn off these messages, use
  `options(sandpaper.show_draft = FALSE)`
- The
  [`set_dropdown()`](https://carpentries.github.io/sandpaper/dev/reference/set_dropdown.md)
  family of functions will now throw an error if an author attempts to
  add a file that does not exist
- An error will occurr if the files listed in `config.yaml` do not exist
  in the lesson with an informative message highlighting the files that
  are missing.

## sandpaper 0.0.0.9032

### MISC

- The internal
  [`get_resource_list()`](https://carpentries.github.io/sandpaper/dev/reference/get_resource_list.md)
  function has been modified to incorporate the features of
  [`get_dropdown()`](https://carpentries.github.io/sandpaper/dev/reference/get_dropdown.md).
  This means that all
  [`get_dropdown()`](https://carpentries.github.io/sandpaper/dev/reference/get_dropdown.md)
  functions will only report the files in the dropdown menus that
  actually exist in the directory
  ([\#134](https://github.com/carpentries/sandpaper/issues/134)).
- A persistant test fixture is now included to speed up testing time
  ([\#132](https://github.com/carpentries/sandpaper/issues/132) via
  [\#134](https://github.com/carpentries/sandpaper/issues/134))

## sandpaper 0.0.0.9031

### MISC

- The {cli} package is now an official import of the package
- The warning message issued from the internal `warn_schedule()`
  function has been changed exclusively use cli messages and can be
  suppressed with
  [`suppressMessages()`](https://rdrr.io/r/base/message.html).
- The internal `sandpaper_cli_theme()` is used to style CLI messages.

## sandpaper 0.0.0.9030

### MISC

- A test that caused problems with a new version of {pegboard} was fixed

## sandpaper 0.0.0.9029

### MISC

- The internal database is updated to use relative instead of absolute
  paths. This fixes
  [\#129](https://github.com/carpentries/sandpaper/issues/129)

## sandpaper 0.0.0.9028

### NEW IMPORTS

The {pingr} package is now being imported to check for online access,
which will marginally decrease data usage
([@fmichonneau](https://github.com/fmichonneau),
[\#127](https://github.com/carpentries/sandpaper/issues/127)).

## sandpaper 0.0.0.9027

### MISC

- `create_schedule()` (internal function) no longer uses pegboard’s
  extensions for fixing reference links.

## sandpaper 0.0.0.9026

### MISC

- callout blocks with headers greater than h3 are now rendered properly
  and no longer forced to h3
- tests now clean up after themselves and no longer change the working
  directory by default
- {varnish} version bumped to 0.0.0.9005
- tests that require pandoc will be skipped if pandoc is not available
- tests for the presences of multiple files will use setequal instead of
  equal to allow for alternate sorting orders.

## sandpaper 0.0.0.9025

### DEPENDENCY UPDATE

- required {pegboard} has been bumped to version 0.0.0.9014
- {renv} and {sessioninfo} added to Suggested packages.

## sandpaper 0.0.0.9024

### BUG FIX

- [`create_lesson()`](https://carpentries.github.io/sandpaper/dev/reference/create_lesson.md)
  will now enforce “main” or the default branch (if init.defaultBranch
  is set) as the default branch for the new lesson. It will also try to
  make the URL match the project name and user name (but the latter is
  limited to users who have GitHub PAT set up that {gh} recognises).

## sandpaper 0.0.0.9023

### BUG FIX

- [`build_episode_md()`](https://carpentries.github.io/sandpaper/dev/reference/build_episode_md.md)
  now sets the `knitr.pandoc.to` knit option to allow for the chunk
  option `fig.cap` to be rendered as a caption. This fixes
  [\#114](https://github.com/carpentries/sandpaper/issues/114).

### NEW FEATURES

- [`set_dropdown()`](https://carpentries.github.io/sandpaper/dev/reference/set_dropdown.md)
  is now generalized to set any item in the dropdown menu (though this
  will likely be wrapped into a better-named function for generalized
  editing).
- `system.file("transform.R", pacakge = "sandpaper")` points to a file
  that will be used for transforming styles-repo era lessons to
  sandpaper lessons.
- read/write cycles were reduced in markdown generation because we are
  no longer interfering with the manipulation of the files at this stage
  (and haven’t been for a while now).

## sandpaper 0.0.0.9022

### BUG FIX

- `build_markdown(rebuild = TRUE)` now actually rebuilds the lesson
- Changing an episode suffix will no longer result in a build error.
  This was due to
  [`build_markdown()`](https://carpentries.github.io/sandpaper/dev/reference/build_markdown.md)
  trying to clean *after* building the output instead of before. It’s a
  situation of throwing the baby out with the bathwater. In any case,
  this fixes
  [\#102](https://github.com/carpentries/sandpaper/issues/102).

## sandpaper 0.0.0.9021

### BUG FIX

- the template will be initialized with ALL folders with placeholders
  inside of the `instructor/` and `profile/` menus. This fixes
  [\#103](https://github.com/carpentries/sandpaper/issues/103).

## sandpaper 0.0.0.9020

### BUG FIX

- the `set_*()` functions no longer mess up yaml lists in `config.yaml`.
  This fixes [\#53](https://github.com/carpentries/sandpaper/issues/53).

## sandpaper 0.0.0.9019

- The required version of {pegboard} has been bumped to 0.0.0.9012,
  which gives better error messages and allows us to read in {sandpaper}
  lessons with the Lesson object.

## sandpaper 0.0.0.9018

- The episode template has been rearranged slightly and given level 2
  headers.

## sandpaper 0.0.0.9017

### ENGINE UPDATE

- The version of pandoc will be explicitly checked to ensure that the
  version used is at least 2.11.

## sandpaper 0.0.0.9016

### BUG FIX

- [`create_episode()`](https://carpentries.github.io/sandpaper/dev/reference/create_episode.md)
  with `make_prefix = FALSE` will no longer create episodes prefixed
  with `-` (see
  [\#93](https://github.com/carpentries/sandpaper/issues/93)).

## sandpaper 0.0.0.9015

### NEW FEATURES

- `fetch_github_workflows()` will download and update the GitHub
  workflows from the Carpentries actions repository.
- [`update_varnish()`](https://carpentries.github.io/sandpaper/dev/reference/update_varnish.md)
  will download and update the {varnish} styling package to your local
  repository.

## sandpaper 0.0.0.9014

### BUG FIX

- Episode order is retained in the HTML navigation
  ([\#85](https://github.com/carpentries/sandpaper/issues/85))
- index.md is recorded in the site/build/ directory, and thus in the
  md-pages branch on deployment.

### ENGINE UPDATE

The caching mechanism is now similar to that of {blogdown} where a
database of source files and their checksum hashes is kept and only the
updated files are built. This provides two advantages, the first is that
we no longer have to peek at the top of the files to check if they need
to be updated and the second is that we can keep the files in the right
order (see [\#85](https://github.com/carpentries/sandpaper/issues/85))

Importantly, the workflow itself should not be affected, but there will
be changes in what gets displayed on the github diff of the md-outputs
branch.

## sandpaper 0.0.0.9013

### NEW FEATURES

- In RStudio, the **knit button works** 🎉 (fix
  [\#77](https://github.com/carpentries/sandpaper/issues/77);
  [@zkamvar](https://github.com/zkamvar),
  [\#82](https://github.com/carpentries/sandpaper/issues/82))
- [`sandpaper_site()`](https://carpentries.github.io/sandpaper/dev/reference/sandpaper_site.md)
  is a site generator function that allows {rmarkdown} to use the
  {sandpaper} machinery to build the site from
  [`rmarkdown::render_site()`](https://pkgs.rstudio.com/rmarkdown/reference/render_site.html)
- [`build_site()`](https://carpentries.github.io/sandpaper/dev/reference/build_site.md)
  gains a `slug` argument that tailors the previewed content.
- [`create_lesson()`](https://carpentries.github.io/sandpaper/dev/reference/create_lesson.md)
  will now create a blank `index.md` with `site: sandpaper_site` as the
  only YAML item.
- HTML accidentally rendered to the source directories are silently
  removed when the site is built. (fix
  [\#78](https://github.com/carpentries/sandpaper/issues/78),
  [@zkamvar](https://github.com/zkamvar),
  [\#84](https://github.com/carpentries/sandpaper/issues/84))

## sandpaper 0.0.0.9012

### NEW FEATURES

- Inline and reference-based footnotes are now supported.

## sandpaper 0.0.0.9011

### BUG FIX

- Bare links and text emoji (e.g. 😉) are now rendered (fix
  [\#67](https://github.com/carpentries/sandpaper/issues/67)).
- Objectives and Questions headings will now no longer be rendered (fix
  [\#64](https://github.com/carpentries/sandpaper/issues/64)).

## sandpaper 0.0.0.9010

### BUG FIX

- If `index.md` exists at the top level, it will be used instead of
  `README.md` for the lesson index page (fix
  [\#56](https://github.com/carpentries/sandpaper/issues/56)).

## sandpaper 0.0.0.9009

### BUG FIX

- The lua filter responsible for creating the Objectives summary block
  at the beginning of episodes now uses native pandoc divs instead of
  HTML block shims. This ensures that the content is not corrupted by
  pandoc’s section divs extension. This addresses issue
  [\#64](https://github.com/carpentries/sandpaper/issues/64)
- All aside elements will be forced to have level 3 headers (this fixes
  an issue with pandocs –section-divs where it couldn’t understand when
  an HTML block contained only the start of an aside tag and decided to
  end the section right after it.
- The Objectives and Questions blocks will no longer include their
  headers in the initial summary block.
- A bug introduced in version 0.0.0.9008 was fixed. This bug improperly
  used regex resulting in the accidental removal of cached rendered
  images. This fixes issue
  [\#49](https://github.com/carpentries/sandpaper/issues/49)
- Rendered images now have the prefix of `{SOURCE}-rendered-` in the
  `site/built/fig/` subdir.

## sandpaper 0.0.0.9008

### BUG FIX

- files that were removed from the source are now also removed in the
  site/built directory. This fixes issue
  [\#47](https://github.com/carpentries/sandpaper/issues/47)

## sandpaper 0.0.0.9007

- HTML will now be processed with pandoc lua filters that will do the
  following:

  - overview block will be constructed from the teaching and exercises
    metadata with the question and objectives blocks
  - instructor and callout divs will be converted to `<aside>` tags
  - divs without H2 level headers will have them automatically inserted
  - divs with incorrect level headers will have them converted to H2
  - only divs in our list of carpentries divs will be converted

- README updated to reflect API changes

## sandpaper 0.0.0.9006

Continuous integration functions added:

- [`ci_deploy()`](https://carpentries.github.io/sandpaper/dev/reference/ci_deploy.md)
  will build the markdown source and the site and commit them to
  separate branches, including information about their source.
- [`ci_build_markdown()`](https://carpentries.github.io/sandpaper/dev/reference/ci_build.md)
  will build the markdown source files and commit them to a separate
  branch, including information about the source commit.
- [`ci_build_site()`](https://carpentries.github.io/sandpaper/dev/reference/ci_build.md)
  will build the site directly from the markdown branch, bypassing
  re-rendering the markdown files.

Miscellaneous additions

- {dovetail} no longer in suggests
- new internal function
  [`build_site()`](https://carpentries.github.io/sandpaper/dev/reference/build_site.md)
  compartmentalizes the conversion from markdown to html
- any files or folders named `.git` in the episodes directory will not
  be copied over to the website.

## sandpaper 0.0.0.9005

- sandpaper now requires and uses additional folders and files:
  - CODE_OF_CONDUCT.md
  - learners/Setup.md
  - instructors/
  - profiles/
  - LICENSE.md
- `_schedule()` functions have been renamed to `_episodes()`.
- `clean_*()` functions are now renamed to `reset_*()`
- Generic `set/get/reset_dropdown()` functions have been created to
  facilitate modification/access of folders that are dropdown menus
  inside of the lesson
- questionable practices with directories mucking about.
- [`build_markdown()`](https://carpentries.github.io/sandpaper/dev/reference/build_markdown.md)
  will now generate artifacts in the `site/built/assets/` directory
  instead of `episodes/` directory to prevent generated artifacts from
  being included in git (See
  <https://github.com/carpentries/sandpaper/issues/24>)

## sandpaper 0.0.0.9004

- Internal `html_from_md()` renamed to
  [`render_html()`](https://carpentries.github.io/sandpaper/dev/reference/render_html.md)
- Internal `build_episode()` renamed to
  [`build_episode_html()`](https://carpentries.github.io/sandpaper/dev/reference/build_episode_html.md)
  and exported, but documentation still internal
- Internal `build_single_episode()` renamed to
  [`build_episode_md()`](https://carpentries.github.io/sandpaper/dev/reference/build_episode_md.md)
  and exported, but documentation still internal

## sandpaper 0.0.0.9003

- A regression in
  [`build_markdown()`](https://carpentries.github.io/sandpaper/dev/reference/build_markdown.md)
  due to being called in a separate process was fixed.
- Internal functions for setting {knitr} options were migrated to live
  inside
  [`build_markdown()`](https://carpentries.github.io/sandpaper/dev/reference/build_markdown.md)

## sandpaper 0.0.0.9002

- Migrate template to use fenced divs instead of {dovetail}.
- [`build_lesson()`](https://carpentries.github.io/sandpaper/dev/reference/build_lesson.md)
  will now render HTML in episode titles.
- {callr} is now imported to protect the processes building markdown and
  HTML files.

## sandpaper 0.0.0.9001

- Add `override` argument to
  [`build_lesson()`](https://carpentries.github.io/sandpaper/dev/reference/build_lesson.md).
  This gets passed on to
  [`pkgdown::as_pkgdown()`](https://pkgdown.r-lib.org/reference/as_pkgdown.html)
  for more control over where the site gets built.
- Update dependency of {pegboard} to 0.0.0.9006, which includes the
  \$questions field to make parsing the ever shifting landscape a bit
  easier.
- First tracking version with NEWS
