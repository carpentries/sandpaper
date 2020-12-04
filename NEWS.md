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
