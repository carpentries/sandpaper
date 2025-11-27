# Package index

## Lesson Creation

Provision new lessons and/or episodes. These functions will likely only
be used once.

- [`create_lesson()`](https://carpentries.github.io/sandpaper/dev/reference/create_lesson.md)
  : Create a carpentries lesson
- [`create_episode()`](https://carpentries.github.io/sandpaper/dev/reference/create_episode.md)
  [`create_episode_md()`](https://carpentries.github.io/sandpaper/dev/reference/create_episode.md)
  [`create_episode_rmd()`](https://carpentries.github.io/sandpaper/dev/reference/create_episode.md)
  [`draft_episode_md()`](https://carpentries.github.io/sandpaper/dev/reference/create_episode.md)
  [`draft_episode_rmd()`](https://carpentries.github.io/sandpaper/dev/reference/create_episode.md)
  : Create an Episode from a template

## Building Lessons

Functions to work build, audit, and preview lesson content. These will
be used with regularity in your work.

- [`serve()`](https://carpentries.github.io/sandpaper/dev/reference/serve.md)
  : Build your lesson and work on it at the same time
- [`build_lesson()`](https://carpentries.github.io/sandpaper/dev/reference/build_lesson.md)
  : Build your lesson site
- [`sandpaper_site()`](https://carpentries.github.io/sandpaper/dev/reference/sandpaper_site.md)
  : Site generator for sandpaper
- [`validate_lesson()`](https://carpentries.github.io/sandpaper/dev/reference/validate_lesson.md)
  : Pre-build validation of lesson elements

## Lesson Development Helpers

Functions to programmatically assess and modify configuration and source
elements of a lesson. These are often used when developing a lesson.

- [`get_drafts()`](https://carpentries.github.io/sandpaper/dev/reference/get_drafts.md)
  : Show files in draft form
- [`get_config()`](https://carpentries.github.io/sandpaper/dev/reference/get_config.md)
  : Get the configuration parameters for the lesson
- [`set_config()`](https://carpentries.github.io/sandpaper/dev/reference/set_config.md)
  : Set individual keys in a configuration file
- [`set_dropdown()`](https://carpentries.github.io/sandpaper/dev/reference/set_dropdown.md)
  [`set_episodes()`](https://carpentries.github.io/sandpaper/dev/reference/set_dropdown.md)
  [`set_learners()`](https://carpentries.github.io/sandpaper/dev/reference/set_dropdown.md)
  [`set_instructors()`](https://carpentries.github.io/sandpaper/dev/reference/set_dropdown.md)
  [`set_profiles()`](https://carpentries.github.io/sandpaper/dev/reference/set_dropdown.md)
  : Set the order of items in a dropdown menu
- [`get_dropdown()`](https://carpentries.github.io/sandpaper/dev/reference/get_dropdown.md)
  [`get_episodes()`](https://carpentries.github.io/sandpaper/dev/reference/get_dropdown.md)
  [`get_learners()`](https://carpentries.github.io/sandpaper/dev/reference/get_dropdown.md)
  [`get_instructors()`](https://carpentries.github.io/sandpaper/dev/reference/get_dropdown.md)
  [`get_profiles()`](https://carpentries.github.io/sandpaper/dev/reference/get_dropdown.md)
  : Helpers to extract contents of dropdown menus on the site
- [`move_episode()`](https://carpentries.github.io/sandpaper/dev/reference/move_episode.md)
  : Move an episode in the schedule
- [`get_syllabus()`](https://carpentries.github.io/sandpaper/dev/reference/get_syllabus.md)
  : Create a syllabus for the lesson
- [`reset_episodes()`](https://carpentries.github.io/sandpaper/dev/reference/reset_episodes.md)
  : Clear the schedule in the lesson
- [`reset_site()`](https://carpentries.github.io/sandpaper/dev/reference/reset_site.md)
  : Remove all files associated with the site
- [`strip_prefix()`](https://carpentries.github.io/sandpaper/dev/reference/strip_prefix.md)
  : This will strip existing episode prefixes and set the schedule

## The Package Cache

Lessons with generated content (R Markdown lessons) have an extra file
called `renv/profiles/lesson-requirments/renv.lock` that records the
package versions used to build the lesson. These functions provide ways
for you to manage these packages and turn it on or off while previewing
the lesson.

- [`use_package_cache()`](https://carpentries.github.io/sandpaper/dev/reference/package_cache.md)
  [`no_package_cache()`](https://carpentries.github.io/sandpaper/dev/reference/package_cache.md)
  [`package_cache_trigger()`](https://carpentries.github.io/sandpaper/dev/reference/package_cache.md)
  : Give Consent to Use Package Cache
- [`manage_deps()`](https://carpentries.github.io/sandpaper/dev/reference/dependency_management.md)
  [`update_cache()`](https://carpentries.github.io/sandpaper/dev/reference/dependency_management.md)
  [`pin_version()`](https://carpentries.github.io/sandpaper/dev/reference/dependency_management.md)
  : Lesson Runtime Dependency Management

## Updating Lesson Tools

Lesson updates will happen automatically on a regular schedule on
GitHub. If you want to expediate those updates or update the components
on your own computer, these functions will help you with that.

- [`update_varnish()`](https://carpentries.github.io/sandpaper/dev/reference/update_varnish.md)
  : Update the local version of the carpentries style
- [`manage_deps()`](https://carpentries.github.io/sandpaper/dev/reference/dependency_management.md)
  [`update_cache()`](https://carpentries.github.io/sandpaper/dev/reference/dependency_management.md)
  [`pin_version()`](https://carpentries.github.io/sandpaper/dev/reference/dependency_management.md)
  : Lesson Runtime Dependency Management
- [`update_github_workflows()`](https://carpentries.github.io/sandpaper/dev/reference/update_github_workflows.md)
  : Update github workflows

## \[Internal\] Continous Integration Functions

Internal functions for deploying on continuous integration. Users are
not intended to work with these.

- [`ci_deploy()`](https://carpentries.github.io/sandpaper/dev/reference/ci_deploy.md)
  : (INTERNAL) Build and deploy the site with continous integration
- [`ci_build_markdown()`](https://carpentries.github.io/sandpaper/dev/reference/ci_build.md)
  [`ci_build_site()`](https://carpentries.github.io/sandpaper/dev/reference/ci_build.md)
  : Build and deploy individual site components to a remote branch
- [`ci_session_info()`](https://carpentries.github.io/sandpaper/dev/reference/ci_session_info.md)
  : Report session information to the user
- [`git_worktree_setup()`](https://carpentries.github.io/sandpaper/dev/reference/git_worktree.md)
  [`github_worktree_commit()`](https://carpentries.github.io/sandpaper/dev/reference/git_worktree.md)
  [`github_worktree_remove()`](https://carpentries.github.io/sandpaper/dev/reference/git_worktree.md)
  : Setup a git worktree for concurrent manipulation of a separate
  branch

## \[Internal\] Markdown Build Components

Internal functions used to provision and build the markdown components
of a lesson.

- [`this_lesson()`](https://carpentries.github.io/sandpaper/dev/reference/lesson_storage.md)
  [`clear_this_lesson()`](https://carpentries.github.io/sandpaper/dev/reference/lesson_storage.md)
  [`set_this_lesson()`](https://carpentries.github.io/sandpaper/dev/reference/lesson_storage.md)
  [`set_resource_list()`](https://carpentries.github.io/sandpaper/dev/reference/lesson_storage.md)
  [`clear_resource_list()`](https://carpentries.github.io/sandpaper/dev/reference/lesson_storage.md)
  : Internal cache for storing pre-computed lesson objects
- [`build_handout()`](https://carpentries.github.io/sandpaper/dev/reference/build_handout.md)
  : Create a code handout of challenges without solutions
- [`build_markdown()`](https://carpentries.github.io/sandpaper/dev/reference/build_markdown.md)
  : Build plain markdown from the RMarkdown episodes
- [`build_episode_md()`](https://carpentries.github.io/sandpaper/dev/reference/build_episode_md.md)
  : Build an episode to markdown
- [`sandpaper.options`](https://carpentries.github.io/sandpaper/dev/reference/sandpaper.options.md)
  : Global Options

## \[Internal\] HTML Build Components

Internal functions used to provision and build the HTML components of a
lesson assuming that the markdown components have been built. (this is
non-exhaustive)

- [`known_languages()`](https://carpentries.github.io/sandpaper/dev/reference/known_languages.md)
  :

  Show a list of languages known by
  [sandpaper](https://carpentries.github.io/sandpaper/)

- [`these`](https://carpentries.github.io/sandpaper/dev/reference/translations.md)
  [`establish_translation_vars()`](https://carpentries.github.io/sandpaper/dev/reference/translations.md)
  [`set_language()`](https://carpentries.github.io/sandpaper/dev/reference/translations.md)
  [`tr_src()`](https://carpentries.github.io/sandpaper/dev/reference/translations.md)
  [`tr_get()`](https://carpentries.github.io/sandpaper/dev/reference/translations.md)
  [`tr_varnish()`](https://carpentries.github.io/sandpaper/dev/reference/translations.md)
  [`tr_computed()`](https://carpentries.github.io/sandpaper/dev/reference/translations.md)
  : Establish and Manage Translation Strings

- [`render_html()`](https://carpentries.github.io/sandpaper/dev/reference/render_html.md)
  : Render html from a markdown file

- [`build_site()`](https://carpentries.github.io/sandpaper/dev/reference/build_site.md)
  : Wrapper for site builder

- [`build_episode_html()`](https://carpentries.github.io/sandpaper/dev/reference/build_episode_html.md)
  : Build a single episode html file

- [`build_home()`](https://carpentries.github.io/sandpaper/dev/reference/build_home.md)
  : Build a home page for a lesson

- [`build_404()`](https://carpentries.github.io/sandpaper/dev/reference/build_404.md)
  : Build the 404 page for a lesson

- [`build_html()`](https://carpentries.github.io/sandpaper/dev/reference/build_html.md)
  : Build instructor and learner HTML page

- [`create_resources_dropdown()`](https://carpentries.github.io/sandpaper/dev/reference/create_sidebar.md)
  [`create_sidebar()`](https://carpentries.github.io/sandpaper/dev/reference/create_sidebar.md)
  [`update_sidebar()`](https://carpentries.github.io/sandpaper/dev/reference/create_sidebar.md)
  : Create the sidebar for varnish

- [`create_sidebar_item()`](https://carpentries.github.io/sandpaper/dev/reference/create_sidebar_item.md)
  [`create_sidebar_headings()`](https://carpentries.github.io/sandpaper/dev/reference/create_sidebar_item.md)
  : Create a single item that appears in the sidebar

## \[Internal\] Post-build Aggregation Components

Components to build aggregate pages such as All in One and Keypoints

- [`read_all_html()`](https://carpentries.github.io/sandpaper/dev/reference/read_all_html.md)
  : read all HTML files in a folder
- [`provision_agg_page()`](https://carpentries.github.io/sandpaper/dev/reference/provision.md)
  [`provision_extra_template()`](https://carpentries.github.io/sandpaper/dev/reference/provision.md)
  : Provision an aggregate page in a lesson
- [`get_content()`](https://carpentries.github.io/sandpaper/dev/reference/get_content.md)
  : Get sections from an episode's HTML page
- [`make_aio_section()`](https://carpentries.github.io/sandpaper/dev/reference/make_aio_section.md)
  : Make a section and place it inside the All In One page
- [`make_images_section()`](https://carpentries.github.io/sandpaper/dev/reference/make_images_section.md)
  : Make a section of aggregated images
- [`build_aio()`](https://carpentries.github.io/sandpaper/dev/reference/build_agg.md)
  [`build_images()`](https://carpentries.github.io/sandpaper/dev/reference/build_agg.md)
  [`build_instructor_notes()`](https://carpentries.github.io/sandpaper/dev/reference/build_agg.md)
  [`build_keypoints()`](https://carpentries.github.io/sandpaper/dev/reference/build_agg.md)
  [`build_agg_page()`](https://carpentries.github.io/sandpaper/dev/reference/build_agg.md)
  : Build a page for aggregating common elements

## \[Internal\] Resource Discovery/Management

Tools for discovering resources and managing their hashes in a text file
database.

- [`get_resource_list()`](https://carpentries.github.io/sandpaper/dev/reference/get_resource_list.md)
  : Get the full resource list of markdown files
- [`parse_file_matches()`](https://carpentries.github.io/sandpaper/dev/reference/parse_file_matches.md)
  : Subset file matches to the order they appear in the config file
- [`get_hash()`](https://carpentries.github.io/sandpaper/dev/reference/build_status.md)
  [`get_built_db()`](https://carpentries.github.io/sandpaper/dev/reference/build_status.md)
  [`build_status()`](https://carpentries.github.io/sandpaper/dev/reference/build_status.md)
  : Identify what files need to be rebuilt and what need to be removed
- [`hash_children()`](https://carpentries.github.io/sandpaper/dev/reference/hash_children.md)
  [`get_lineages()`](https://carpentries.github.io/sandpaper/dev/reference/hash_children.md)
  : Update file checksums to account for child documents
- [`template_gitignore()`](https://carpentries.github.io/sandpaper/dev/reference/template.md)
  [`template_episode()`](https://carpentries.github.io/sandpaper/dev/reference/template.md)
  [`template_links()`](https://carpentries.github.io/sandpaper/dev/reference/template.md)
  [`template_cff()`](https://carpentries.github.io/sandpaper/dev/reference/template.md)
  [`template_citation()`](https://carpentries.github.io/sandpaper/dev/reference/template.md)
  [`template_config()`](https://carpentries.github.io/sandpaper/dev/reference/template.md)
  [`template_conduct()`](https://carpentries.github.io/sandpaper/dev/reference/template.md)
  [`template_index()`](https://carpentries.github.io/sandpaper/dev/reference/template.md)
  [`template_license()`](https://carpentries.github.io/sandpaper/dev/reference/template.md)
  [`template_contributing()`](https://carpentries.github.io/sandpaper/dev/reference/template.md)
  [`template_setup()`](https://carpentries.github.io/sandpaper/dev/reference/template.md)
  [`template_pkgdown()`](https://carpentries.github.io/sandpaper/dev/reference/template.md)
  [`template_placeholder()`](https://carpentries.github.io/sandpaper/dev/reference/template.md)
  [`template_pr_diff()`](https://carpentries.github.io/sandpaper/dev/reference/template.md)
  [`template_sidebar_item()`](https://carpentries.github.io/sandpaper/dev/reference/template.md)
  [`template_metadata()`](https://carpentries.github.io/sandpaper/dev/reference/template.md)
  : Template files
- [`yaml_list()`](https://carpentries.github.io/sandpaper/dev/reference/yaml_list.md)
  : Create a valid, opinionated yaml list for insertion into a whisker
  template

## \[Developer\] Lesson Test Fixture

Internal documentation for the temporary lesson and remote used as a
test fixture created and destroyed before and after tests.

- [`create_test_lesson()`](https://carpentries.github.io/sandpaper/dev/reference/fixtures.md)
  [`generate_restore_fixture()`](https://carpentries.github.io/sandpaper/dev/reference/fixtures.md)
  [`setup_local_remote()`](https://carpentries.github.io/sandpaper/dev/reference/fixtures.md)
  [`make_branch()`](https://carpentries.github.io/sandpaper/dev/reference/fixtures.md)
  [`clean_branch()`](https://carpentries.github.io/sandpaper/dev/reference/fixtures.md)
  [`remove_local_remote()`](https://carpentries.github.io/sandpaper/dev/reference/fixtures.md)
  : Test fixture functions for sandpaper
