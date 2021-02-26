# sandpaper 0.0.0.9013

NEW FEATURES
------------

* In RStudio, the **knit button works** :tada:
* `sandpaper_site()` is a site generator function that allows {rmarkdown} to
  use the {sandpaper} machinery to build the site from
  `rmarkdown::render_site()`
* `build_site()` gains a `slug` argument that tailors the previewed content.
* `create_lesson()` will now create a blank `index.md` with `site:
  sandpaper_site` as the only YAML item. 

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
