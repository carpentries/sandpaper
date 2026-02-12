# Setup a git worktree for concurrent manipulation of a separate branch

Setup a git worktree for concurrent manipulation of a separate branch

## Usage

``` r
git_worktree_setup(
  path = ".",
  dest_dir,
  branch = "gh-pages",
  remote = "origin",
  throwaway = FALSE
)

github_worktree_commit(dir, commit_message, remote, branch)

github_worktree_remove(dir, home = NULL)
```

## Arguments

- path:

  path to the repository

- dest_dir:

  path to the destination directory to contain the work tree

- branch:

  the branch associated with the work tree (default: gh-pages)

- remote:

  the remote name (default: origin)

- throwaway:

  if `TRUE`, the worktree created is in a detached HEAD state from from
  the remote branch and will not create a new branch in your repository.
  Defaults to `FALSE`, which will create the branch from upstream.

## Value

an [`expression()`](https://rdrr.io/r/base/expression.html) that calls
`git worktree remove` on the worktree when evaluated.

## Details

This function is used in continuous integration settings where we want
to push derived outputs to non-main branches in our repository. We use
this to populate the markdown and HTML outputs from the lesson so that
we don't have to rebuild the lesson from scratch every time.

The logic behind this looks like

    worktree setup
    [IF BRANCH DOES NOT EXIST]
      git checkout --orphan <branch>
      git rm -rf --quiet .
      git commit --allow-empty -m
      git push remote HEAD:<branch>
      git checkout -
    git fetch <remote> +refs/heads/<branch>:refs/remotes/<remote>/<branch>
    git worktree add --track -B <branch> /path/to/dir <remote>/<branch>

## Note

`git_worktree_setup()` has been modified from the logic in
[`pkgdown::deploy_to_branch()`](https://pkgdown.r-lib.org/reference/deploy_to_branch.html),
by Hadley Wickham.

`github_worktree_commit()`: Modified from `pkgdown:::github_push` by
Hadley Wickham

`github_worktree_remove()`: Modified from
`pkgdown:::github_worktree_remove` by Hadley Wickham

## Examples

``` r
# Use Worktrees to deploy a lesson -----------------------------------------
# This example is a bit inovlved, but it is effectively what we do inside of
# the `ci_deploy()` function (after setting up the lesson).
#
# The setup phase will create a new lesson and a corresponding remote (self
# contained, no GitHub authentication required).
#
# The worktrees will be created for both the markdown and HTML outputs on the
# branches "md-outputs" and "gh-pages", respectively.
#
# After the worktrees are created, we will build the lesson into the
# worktrees and display the output of `git_status()` for each of the three
# branches: "main", "md-outputs", and "gh-pages"
#
# During the clean up phase, the output of `git_worktree_setup()` is
# evaluated
tik <- Sys.time()
cli::cli_h1("Set up")
#> 
#> ── Set up ──────────────────────────────────────────────────────────────
cli::cli_h2("Create Lesson")
#> 
#> ── Create Lesson ──
#> 
restore_fixture <- sandpaper:::create_test_lesson()
#> → Bootstrapping example lesson
#> ℹ Lesson bootstrapped in 3.15047 secs
#> → Bootstrapping example lesson
res <- getOption("sandpaper.test_fixture")
sandpaper:::check_git_user(res)
cli::cli_h2("Create Remote")
#> 
#> ── Create Remote ──
#> 
rmt <- fs::file_temp(pattern = "REMOTE-")
sandpaper:::setup_local_remote(repo = res, remote = rmt, verbose = FALSE)
#> ℹ Remote set up in 0.01321888 secs
tok <- Sys.time()
cli::cli_alert_info("Elapsed time: {round(tok - tik, 2)} seconds")
#> ℹ Elapsed time: 3.19 seconds
tik <- Sys.time()
cli::cli_h2("Create Worktrees")
#> 
#> ── Create Worktrees ──
#> 
db <- sandpaper:::git_worktree_setup(res, fs::path(res, "site", "built"),
  branch = "md-outputs", remote = "sandpaper-local"
)
#> ::group::Create New Branch
#> Running git checkout --orphan md-outputs
#> Switched to a new branch 'md-outputs'
#> Running git rm -rf --quiet .
#> Running git commit --allow-empty -m 'Initializing md-outputs branch'
#> [md-outputs (root-commit) 36dd145] Initializing md-outputs branch
#> Running git push sandpaper-local 'HEAD:md-outputs'
#> To /tmp/RtmpofsREx/REMOTE-1c8b2f82223a
#>  * [new branch]      HEAD -> md-outputs
#> Running git checkout main
#> Switched to branch 'main'
#> Your branch is up to date with 'sandpaper-local/main'.
#> ::endgroup::
#> ::group::Fetch sandpaper-local/md-outputs
#> Running git remote set-branches sandpaper-local md-outputs
#> Running git fetch sandpaper-local md-outputs
#> From /tmp/RtmpofsREx/REMOTE-1c8b2f82223a
#>  * branch            md-outputs -> FETCH_HEAD
#> Running git remote set-branches sandpaper-local '*'
#> ::endgroup::
#> ::group::Add worktree for sandpaper-local/md-outputs in site/built
#> Running git worktree add --track -B md-outputs \
#>   /tmp/RtmpofsREx/file1c8b62575816/lesson-example/site/built \
#>   sandpaper-local/md-outputs
#> Preparing worktree (resetting branch 'md-outputs'; was at 36dd145)
#> branch 'md-outputs' set up to track 'sandpaper-local/md-outputs'.
#> HEAD is now at 36dd145 Initializing md-outputs branch
#> ::endgroup::
ds <- sandpaper:::git_worktree_setup(res, fs::path(res, "site", "docs"),
  branch = "gh-pages", remote = "sandpaper-local"
)
#> ::group::Create New Branch
#> Running git checkout --orphan gh-pages
#> Switched to a new branch 'gh-pages'
#> Running git rm -rf --quiet .
#> Running git commit --allow-empty -m 'Initializing gh-pages branch'
#> [gh-pages (root-commit) 68c19ba] Initializing gh-pages branch
#> Running git push sandpaper-local 'HEAD:gh-pages'
#> To /tmp/RtmpofsREx/REMOTE-1c8b2f82223a
#>  * [new branch]      HEAD -> gh-pages
#> Running git checkout main
#> Switched to branch 'main'
#> Your branch is up to date with 'sandpaper-local/main'.
#> ::endgroup::
#> ::group::Fetch sandpaper-local/gh-pages
#> Running git remote set-branches sandpaper-local gh-pages
#> Running git fetch sandpaper-local gh-pages
#> From /tmp/RtmpofsREx/REMOTE-1c8b2f82223a
#>  * branch            gh-pages   -> FETCH_HEAD
#> Running git remote set-branches sandpaper-local '*'
#> ::endgroup::
#> ::group::Add worktree for sandpaper-local/gh-pages in site/docs
#> Running git worktree add --track -B gh-pages \
#>   /tmp/RtmpofsREx/file1c8b62575816/lesson-example/site/docs \
#>   sandpaper-local/gh-pages
#> Preparing worktree (resetting branch 'gh-pages'; was at 68c19ba)
#> branch 'gh-pages' set up to track 'sandpaper-local/gh-pages'.
#> HEAD is now at 68c19ba Initializing gh-pages branch
#> ::endgroup::
tok <- Sys.time()
cli::cli_alert_info("Elapsed time: {round(tok - tik, 2)} seconds")
#> ℹ Elapsed time: 0.39 seconds
tik <- Sys.time()
cli::cli_h1("Build Lesson into worktrees")
#> 
#> ── Build Lesson into worktrees ─────────────────────────────────────────
build_lesson(res, quiet = TRUE, preview = FALSE)
#> ℹ Checking renv dependencies
#> ── Initialising site ───────────────────────────────────────────────────
#> Copying <pkgdown>/BS3/assets/bootstrap-toc.css to bootstrap-toc.css
#> Copying <pkgdown>/BS3/assets/bootstrap-toc.js to bootstrap-toc.js
#> Copying <pkgdown>/BS3/assets/docsearch.css to docsearch.css
#> Copying <pkgdown>/BS3/assets/docsearch.js to docsearch.js
#> Copying <pkgdown>/BS3/assets/link.svg to link.svg
#> Copying <pkgdown>/BS3/assets/pkgdown.css to pkgdown.css
#> Copying <pkgdown>/BS3/assets/pkgdown.js to pkgdown.js
#> Copying <varnish>/pkgdown/assets/android-chrome-192x192.png to
#> android-chrome-192x192.png
#> Copying <varnish>/pkgdown/assets/android-chrome-512x512.png to
#> android-chrome-512x512.png
#> Copying <varnish>/pkgdown/assets/apple-touch-icon.png to
#> apple-touch-icon.png
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Black.eot to
#> assets/fonts/Mulish-Black.eot
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Black.svg to
#> assets/fonts/Mulish-Black.svg
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Black.ttf to
#> assets/fonts/Mulish-Black.ttf
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Black.woff to
#> assets/fonts/Mulish-Black.woff
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Black.woff2 to
#> assets/fonts/Mulish-Black.woff2
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-BlackItalic.eot to
#> assets/fonts/Mulish-BlackItalic.eot
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-BlackItalic.svg to
#> assets/fonts/Mulish-BlackItalic.svg
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-BlackItalic.ttf to
#> assets/fonts/Mulish-BlackItalic.ttf
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-BlackItalic.woff
#> to assets/fonts/Mulish-BlackItalic.woff
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-BlackItalic.woff2
#> to assets/fonts/Mulish-BlackItalic.woff2
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Bold.eot to
#> assets/fonts/Mulish-Bold.eot
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Bold.svg to
#> assets/fonts/Mulish-Bold.svg
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Bold.ttf to
#> assets/fonts/Mulish-Bold.ttf
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Bold.woff to
#> assets/fonts/Mulish-Bold.woff
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Bold.woff2 to
#> assets/fonts/Mulish-Bold.woff2
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-BoldItalic.eot to
#> assets/fonts/Mulish-BoldItalic.eot
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-BoldItalic.svg to
#> assets/fonts/Mulish-BoldItalic.svg
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-BoldItalic.ttf to
#> assets/fonts/Mulish-BoldItalic.ttf
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-BoldItalic.woff to
#> assets/fonts/Mulish-BoldItalic.woff
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-BoldItalic.woff2
#> to assets/fonts/Mulish-BoldItalic.woff2
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-ExtraBold.eot to
#> assets/fonts/Mulish-ExtraBold.eot
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-ExtraBold.svg to
#> assets/fonts/Mulish-ExtraBold.svg
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-ExtraBold.ttf to
#> assets/fonts/Mulish-ExtraBold.ttf
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-ExtraBold.woff to
#> assets/fonts/Mulish-ExtraBold.woff
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-ExtraBold.woff2 to
#> assets/fonts/Mulish-ExtraBold.woff2
#> Copying
#> <varnish>/pkgdown/assets/assets/fonts/Mulish-ExtraBoldItalic.eot to
#> assets/fonts/Mulish-ExtraBoldItalic.eot
#> Copying
#> <varnish>/pkgdown/assets/assets/fonts/Mulish-ExtraBoldItalic.svg to
#> assets/fonts/Mulish-ExtraBoldItalic.svg
#> Copying
#> <varnish>/pkgdown/assets/assets/fonts/Mulish-ExtraBoldItalic.ttf to
#> assets/fonts/Mulish-ExtraBoldItalic.ttf
#> Copying
#> <varnish>/pkgdown/assets/assets/fonts/Mulish-ExtraBoldItalic.woff to
#> assets/fonts/Mulish-ExtraBoldItalic.woff
#> Copying
#> <varnish>/pkgdown/assets/assets/fonts/Mulish-ExtraBoldItalic.woff2 to
#> assets/fonts/Mulish-ExtraBoldItalic.woff2
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-ExtraLight.eot to
#> assets/fonts/Mulish-ExtraLight.eot
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-ExtraLight.svg to
#> assets/fonts/Mulish-ExtraLight.svg
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-ExtraLight.ttf to
#> assets/fonts/Mulish-ExtraLight.ttf
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-ExtraLight.woff to
#> assets/fonts/Mulish-ExtraLight.woff
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-ExtraLight.woff2
#> to assets/fonts/Mulish-ExtraLight.woff2
#> Copying
#> <varnish>/pkgdown/assets/assets/fonts/Mulish-ExtraLightItalic.eot to
#> assets/fonts/Mulish-ExtraLightItalic.eot
#> Copying
#> <varnish>/pkgdown/assets/assets/fonts/Mulish-ExtraLightItalic.svg to
#> assets/fonts/Mulish-ExtraLightItalic.svg
#> Copying
#> <varnish>/pkgdown/assets/assets/fonts/Mulish-ExtraLightItalic.ttf to
#> assets/fonts/Mulish-ExtraLightItalic.ttf
#> Copying
#> <varnish>/pkgdown/assets/assets/fonts/Mulish-ExtraLightItalic.woff to
#> assets/fonts/Mulish-ExtraLightItalic.woff
#> Copying
#> <varnish>/pkgdown/assets/assets/fonts/Mulish-ExtraLightItalic.woff2 to
#> assets/fonts/Mulish-ExtraLightItalic.woff2
#> Copying
#> <varnish>/pkgdown/assets/assets/fonts/Mulish-Italic-VariableFont_wght.ttf
#> to assets/fonts/Mulish-Italic-VariableFont_wght.ttf
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Italic.eot to
#> assets/fonts/Mulish-Italic.eot
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Italic.svg to
#> assets/fonts/Mulish-Italic.svg
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Italic.ttf to
#> assets/fonts/Mulish-Italic.ttf
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Italic.woff to
#> assets/fonts/Mulish-Italic.woff
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Italic.woff2 to
#> assets/fonts/Mulish-Italic.woff2
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Light.eot to
#> assets/fonts/Mulish-Light.eot
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Light.svg to
#> assets/fonts/Mulish-Light.svg
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Light.ttf to
#> assets/fonts/Mulish-Light.ttf
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Light.woff to
#> assets/fonts/Mulish-Light.woff
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Light.woff2 to
#> assets/fonts/Mulish-Light.woff2
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-LightItalic.eot to
#> assets/fonts/Mulish-LightItalic.eot
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-LightItalic.svg to
#> assets/fonts/Mulish-LightItalic.svg
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-LightItalic.ttf to
#> assets/fonts/Mulish-LightItalic.ttf
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-LightItalic.woff
#> to assets/fonts/Mulish-LightItalic.woff
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-LightItalic.woff2
#> to assets/fonts/Mulish-LightItalic.woff2
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Medium.eot to
#> assets/fonts/Mulish-Medium.eot
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Medium.svg to
#> assets/fonts/Mulish-Medium.svg
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Medium.ttf to
#> assets/fonts/Mulish-Medium.ttf
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Medium.woff to
#> assets/fonts/Mulish-Medium.woff
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Medium.woff2 to
#> assets/fonts/Mulish-Medium.woff2
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-MediumItalic.eot
#> to assets/fonts/Mulish-MediumItalic.eot
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-MediumItalic.svg
#> to assets/fonts/Mulish-MediumItalic.svg
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-MediumItalic.ttf
#> to assets/fonts/Mulish-MediumItalic.ttf
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-MediumItalic.woff
#> to assets/fonts/Mulish-MediumItalic.woff
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-MediumItalic.woff2
#> to assets/fonts/Mulish-MediumItalic.woff2
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Regular.eot to
#> assets/fonts/Mulish-Regular.eot
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Regular.svg to
#> assets/fonts/Mulish-Regular.svg
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Regular.ttf to
#> assets/fonts/Mulish-Regular.ttf
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Regular.woff to
#> assets/fonts/Mulish-Regular.woff
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-Regular.woff2 to
#> assets/fonts/Mulish-Regular.woff2
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-SemiBold.eot to
#> assets/fonts/Mulish-SemiBold.eot
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-SemiBold.svg to
#> assets/fonts/Mulish-SemiBold.svg
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-SemiBold.ttf to
#> assets/fonts/Mulish-SemiBold.ttf
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-SemiBold.woff to
#> assets/fonts/Mulish-SemiBold.woff
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-SemiBold.woff2 to
#> assets/fonts/Mulish-SemiBold.woff2
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-SemiBoldItalic.eot
#> to assets/fonts/Mulish-SemiBoldItalic.eot
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-SemiBoldItalic.svg
#> to assets/fonts/Mulish-SemiBoldItalic.svg
#> Copying <varnish>/pkgdown/assets/assets/fonts/Mulish-SemiBoldItalic.ttf
#> to assets/fonts/Mulish-SemiBoldItalic.ttf
#> Copying
#> <varnish>/pkgdown/assets/assets/fonts/Mulish-SemiBoldItalic.woff to
#> assets/fonts/Mulish-SemiBoldItalic.woff
#> Copying
#> <varnish>/pkgdown/assets/assets/fonts/Mulish-SemiBoldItalic.woff2 to
#> assets/fonts/Mulish-SemiBoldItalic.woff2
#> Copying
#> <varnish>/pkgdown/assets/assets/fonts/Mulish-VariableFont_wght.ttf to
#> assets/fonts/Mulish-VariableFont_wght.ttf
#> Copying
#> <varnish>/pkgdown/assets/assets/fonts/MulishExtraLight-Regular.eot to
#> assets/fonts/MulishExtraLight-Regular.eot
#> Copying
#> <varnish>/pkgdown/assets/assets/fonts/MulishExtraLight-Regular.svg to
#> assets/fonts/MulishExtraLight-Regular.svg
#> Copying
#> <varnish>/pkgdown/assets/assets/fonts/MulishExtraLight-Regular.woff to
#> assets/fonts/MulishExtraLight-Regular.woff
#> Copying
#> <varnish>/pkgdown/assets/assets/fonts/MulishExtraLight-Regular.woff2 to
#> assets/fonts/MulishExtraLight-Regular.woff2
#> Copying
#> <varnish>/pkgdown/assets/assets/fonts/mulish-v5-latin-regular.eot to
#> assets/fonts/mulish-v5-latin-regular.eot
#> Copying
#> <varnish>/pkgdown/assets/assets/fonts/mulish-v5-latin-regular.svg to
#> assets/fonts/mulish-v5-latin-regular.svg
#> Copying
#> <varnish>/pkgdown/assets/assets/fonts/mulish-v5-latin-regular.ttf to
#> assets/fonts/mulish-v5-latin-regular.ttf
#> Copying
#> <varnish>/pkgdown/assets/assets/fonts/mulish-v5-latin-regular.woff to
#> assets/fonts/mulish-v5-latin-regular.woff
#> Copying
#> <varnish>/pkgdown/assets/assets/fonts/mulish-v5-latin-regular.woff2 to
#> assets/fonts/mulish-v5-latin-regular.woff2
#> Copying
#> <varnish>/pkgdown/assets/assets/fonts/mulish-variablefont_wght.woff to
#> assets/fonts/mulish-variablefont_wght.woff
#> Copying
#> <varnish>/pkgdown/assets/assets/fonts/mulish-variablefont_wght.woff2 to
#> assets/fonts/mulish-variablefont_wght.woff2
#> Copying <varnish>/pkgdown/assets/assets/images/carpentries-logo-sm.svg
#> to assets/images/carpentries-logo-sm.svg
#> Copying <varnish>/pkgdown/assets/assets/images/carpentries-logo.svg to
#> assets/images/carpentries-logo.svg
#> Copying <varnish>/pkgdown/assets/assets/images/data-logo-sm.svg to
#> assets/images/data-logo-sm.svg
#> Copying <varnish>/pkgdown/assets/assets/images/data-logo.svg to
#> assets/images/data-logo.svg
#> Copying <varnish>/pkgdown/assets/assets/images/dropdown-arrow.svg to
#> assets/images/dropdown-arrow.svg
#> Copying <varnish>/pkgdown/assets/assets/images/incubator-logo-sm.svg to
#> assets/images/incubator-logo-sm.svg
#> Copying <varnish>/pkgdown/assets/assets/images/incubator-logo.svg to
#> assets/images/incubator-logo.svg
#> Copying <varnish>/pkgdown/assets/assets/images/lab-logo-sm.svg to
#> assets/images/lab-logo-sm.svg
#> Copying <varnish>/pkgdown/assets/assets/images/lab-logo.svg to
#> assets/images/lab-logo.svg
#> Copying <varnish>/pkgdown/assets/assets/images/library-logo-sm.svg to
#> assets/images/library-logo-sm.svg
#> Copying <varnish>/pkgdown/assets/assets/images/library-logo.svg to
#> assets/images/library-logo.svg
#> Copying <varnish>/pkgdown/assets/assets/images/minus.svg to
#> assets/images/minus.svg
#> Copying <varnish>/pkgdown/assets/assets/images/orcid_icon.png to
#> assets/images/orcid_icon.png
#> Copying <varnish>/pkgdown/assets/assets/images/parrot_icon.svg to
#> assets/images/parrot_icon.svg
#> Copying <varnish>/pkgdown/assets/assets/images/parrot_icon_colour.svg
#> to assets/images/parrot_icon_colour.svg
#> Copying <varnish>/pkgdown/assets/assets/images/plus.svg to
#> assets/images/plus.svg
#> Copying <varnish>/pkgdown/assets/assets/images/software-logo-sm.svg to
#> assets/images/software-logo-sm.svg
#> Copying <varnish>/pkgdown/assets/assets/images/software-logo.svg to
#> assets/images/software-logo.svg
#> Copying <varnish>/pkgdown/assets/assets/scripts.js to assets/scripts.js
#> Copying <varnish>/pkgdown/assets/assets/styles.css to assets/styles.css
#> Copying <varnish>/pkgdown/assets/assets/styles.css.map to
#> assets/styles.css.map
#> Copying <varnish>/pkgdown/assets/assets/themetoggle.js to
#> assets/themetoggle.js
#> Copying <varnish>/pkgdown/assets/favicon-16x16.png to favicon-16x16.png
#> Copying <varnish>/pkgdown/assets/favicon-32x32.png to favicon-32x32.png
#> Copying
#> <varnish>/pkgdown/assets/favicons/cp/apple-touch-icon-114x114.png to
#> favicons/cp/apple-touch-icon-114x114.png
#> Copying
#> <varnish>/pkgdown/assets/favicons/cp/apple-touch-icon-120x120.png to
#> favicons/cp/apple-touch-icon-120x120.png
#> Copying
#> <varnish>/pkgdown/assets/favicons/cp/apple-touch-icon-144x144.png to
#> favicons/cp/apple-touch-icon-144x144.png
#> Copying
#> <varnish>/pkgdown/assets/favicons/cp/apple-touch-icon-152x152.png to
#> favicons/cp/apple-touch-icon-152x152.png
#> Copying <varnish>/pkgdown/assets/favicons/cp/apple-touch-icon-57x57.png
#> to favicons/cp/apple-touch-icon-57x57.png
#> Copying <varnish>/pkgdown/assets/favicons/cp/apple-touch-icon-60x60.png
#> to favicons/cp/apple-touch-icon-60x60.png
#> Copying <varnish>/pkgdown/assets/favicons/cp/apple-touch-icon-72x72.png
#> to favicons/cp/apple-touch-icon-72x72.png
#> Copying <varnish>/pkgdown/assets/favicons/cp/apple-touch-icon-76x76.png
#> to favicons/cp/apple-touch-icon-76x76.png
#> Copying <varnish>/pkgdown/assets/favicons/cp/favicon-128.png to
#> favicons/cp/favicon-128.png
#> Copying <varnish>/pkgdown/assets/favicons/cp/favicon-16x16.png to
#> favicons/cp/favicon-16x16.png
#> Copying <varnish>/pkgdown/assets/favicons/cp/favicon-196x196.png to
#> favicons/cp/favicon-196x196.png
#> Copying <varnish>/pkgdown/assets/favicons/cp/favicon-32x32.png to
#> favicons/cp/favicon-32x32.png
#> Copying <varnish>/pkgdown/assets/favicons/cp/favicon-96x96.png to
#> favicons/cp/favicon-96x96.png
#> Copying <varnish>/pkgdown/assets/favicons/cp/favicon.ico to
#> favicons/cp/favicon.ico
#> Copying <varnish>/pkgdown/assets/favicons/cp/mstile-144x144.png to
#> favicons/cp/mstile-144x144.png
#> Copying <varnish>/pkgdown/assets/favicons/cp/mstile-150x150.png to
#> favicons/cp/mstile-150x150.png
#> Copying <varnish>/pkgdown/assets/favicons/cp/mstile-310x150.png to
#> favicons/cp/mstile-310x150.png
#> Copying <varnish>/pkgdown/assets/favicons/cp/mstile-310x310.png to
#> favicons/cp/mstile-310x310.png
#> Copying <varnish>/pkgdown/assets/favicons/cp/mstile-70x70.png to
#> favicons/cp/mstile-70x70.png
#> Copying
#> <varnish>/pkgdown/assets/favicons/dc/apple-touch-icon-114x114.png to
#> favicons/dc/apple-touch-icon-114x114.png
#> Copying
#> <varnish>/pkgdown/assets/favicons/dc/apple-touch-icon-120x120.png to
#> favicons/dc/apple-touch-icon-120x120.png
#> Copying
#> <varnish>/pkgdown/assets/favicons/dc/apple-touch-icon-144x144.png to
#> favicons/dc/apple-touch-icon-144x144.png
#> Copying
#> <varnish>/pkgdown/assets/favicons/dc/apple-touch-icon-152x152.png to
#> favicons/dc/apple-touch-icon-152x152.png
#> Copying <varnish>/pkgdown/assets/favicons/dc/apple-touch-icon-57x57.png
#> to favicons/dc/apple-touch-icon-57x57.png
#> Copying <varnish>/pkgdown/assets/favicons/dc/apple-touch-icon-60x60.png
#> to favicons/dc/apple-touch-icon-60x60.png
#> Copying <varnish>/pkgdown/assets/favicons/dc/apple-touch-icon-72x72.png
#> to favicons/dc/apple-touch-icon-72x72.png
#> Copying <varnish>/pkgdown/assets/favicons/dc/apple-touch-icon-76x76.png
#> to favicons/dc/apple-touch-icon-76x76.png
#> Copying <varnish>/pkgdown/assets/favicons/dc/favicon-128.png to
#> favicons/dc/favicon-128.png
#> Copying <varnish>/pkgdown/assets/favicons/dc/favicon-16x16.png to
#> favicons/dc/favicon-16x16.png
#> Copying <varnish>/pkgdown/assets/favicons/dc/favicon-196x196.png to
#> favicons/dc/favicon-196x196.png
#> Copying <varnish>/pkgdown/assets/favicons/dc/favicon-32x32.png to
#> favicons/dc/favicon-32x32.png
#> Copying <varnish>/pkgdown/assets/favicons/dc/favicon-96x96.png to
#> favicons/dc/favicon-96x96.png
#> Copying <varnish>/pkgdown/assets/favicons/dc/favicon.ico to
#> favicons/dc/favicon.ico
#> Copying <varnish>/pkgdown/assets/favicons/dc/mstile-144x144.png to
#> favicons/dc/mstile-144x144.png
#> Copying <varnish>/pkgdown/assets/favicons/dc/mstile-150x150.png to
#> favicons/dc/mstile-150x150.png
#> Copying <varnish>/pkgdown/assets/favicons/dc/mstile-310x150.png to
#> favicons/dc/mstile-310x150.png
#> Copying <varnish>/pkgdown/assets/favicons/dc/mstile-310x310.png to
#> favicons/dc/mstile-310x310.png
#> Copying <varnish>/pkgdown/assets/favicons/dc/mstile-70x70.png to
#> favicons/dc/mstile-70x70.png
#> Copying
#> <varnish>/pkgdown/assets/favicons/lc/apple-touch-icon-114x114.png to
#> favicons/lc/apple-touch-icon-114x114.png
#> Copying
#> <varnish>/pkgdown/assets/favicons/lc/apple-touch-icon-120x120.png to
#> favicons/lc/apple-touch-icon-120x120.png
#> Copying
#> <varnish>/pkgdown/assets/favicons/lc/apple-touch-icon-144x144.png to
#> favicons/lc/apple-touch-icon-144x144.png
#> Copying
#> <varnish>/pkgdown/assets/favicons/lc/apple-touch-icon-152x152.png to
#> favicons/lc/apple-touch-icon-152x152.png
#> Copying <varnish>/pkgdown/assets/favicons/lc/apple-touch-icon-57x57.png
#> to favicons/lc/apple-touch-icon-57x57.png
#> Copying <varnish>/pkgdown/assets/favicons/lc/apple-touch-icon-60x60.png
#> to favicons/lc/apple-touch-icon-60x60.png
#> Copying <varnish>/pkgdown/assets/favicons/lc/apple-touch-icon-72x72.png
#> to favicons/lc/apple-touch-icon-72x72.png
#> Copying <varnish>/pkgdown/assets/favicons/lc/apple-touch-icon-76x76.png
#> to favicons/lc/apple-touch-icon-76x76.png
#> Copying <varnish>/pkgdown/assets/favicons/lc/favicon-128.png to
#> favicons/lc/favicon-128.png
#> Copying <varnish>/pkgdown/assets/favicons/lc/favicon-16x16.png to
#> favicons/lc/favicon-16x16.png
#> Copying <varnish>/pkgdown/assets/favicons/lc/favicon-196x196.png to
#> favicons/lc/favicon-196x196.png
#> Copying <varnish>/pkgdown/assets/favicons/lc/favicon-32x32.png to
#> favicons/lc/favicon-32x32.png
#> Copying <varnish>/pkgdown/assets/favicons/lc/favicon-96x96.png to
#> favicons/lc/favicon-96x96.png
#> Copying <varnish>/pkgdown/assets/favicons/lc/favicon.ico to
#> favicons/lc/favicon.ico
#> Copying <varnish>/pkgdown/assets/favicons/lc/mstile-144x144.png to
#> favicons/lc/mstile-144x144.png
#> Copying <varnish>/pkgdown/assets/favicons/lc/mstile-150x150.png to
#> favicons/lc/mstile-150x150.png
#> Copying <varnish>/pkgdown/assets/favicons/lc/mstile-310x150.png to
#> favicons/lc/mstile-310x150.png
#> Copying <varnish>/pkgdown/assets/favicons/lc/mstile-310x310.png to
#> favicons/lc/mstile-310x310.png
#> Copying <varnish>/pkgdown/assets/favicons/lc/mstile-70x70.png to
#> favicons/lc/mstile-70x70.png
#> Copying
#> <varnish>/pkgdown/assets/favicons/swc/apple-touch-icon-114x114.png to
#> favicons/swc/apple-touch-icon-114x114.png
#> Copying
#> <varnish>/pkgdown/assets/favicons/swc/apple-touch-icon-120x120.png to
#> favicons/swc/apple-touch-icon-120x120.png
#> Copying
#> <varnish>/pkgdown/assets/favicons/swc/apple-touch-icon-144x144.png to
#> favicons/swc/apple-touch-icon-144x144.png
#> Copying
#> <varnish>/pkgdown/assets/favicons/swc/apple-touch-icon-152x152.png to
#> favicons/swc/apple-touch-icon-152x152.png
#> Copying
#> <varnish>/pkgdown/assets/favicons/swc/apple-touch-icon-57x57.png to
#> favicons/swc/apple-touch-icon-57x57.png
#> Copying
#> <varnish>/pkgdown/assets/favicons/swc/apple-touch-icon-60x60.png to
#> favicons/swc/apple-touch-icon-60x60.png
#> Copying
#> <varnish>/pkgdown/assets/favicons/swc/apple-touch-icon-72x72.png to
#> favicons/swc/apple-touch-icon-72x72.png
#> Copying
#> <varnish>/pkgdown/assets/favicons/swc/apple-touch-icon-76x76.png to
#> favicons/swc/apple-touch-icon-76x76.png
#> Copying <varnish>/pkgdown/assets/favicons/swc/favicon-128.png to
#> favicons/swc/favicon-128.png
#> Copying <varnish>/pkgdown/assets/favicons/swc/favicon-16x16.png to
#> favicons/swc/favicon-16x16.png
#> Copying <varnish>/pkgdown/assets/favicons/swc/favicon-196x196.png to
#> favicons/swc/favicon-196x196.png
#> Copying <varnish>/pkgdown/assets/favicons/swc/favicon-32x32.png to
#> favicons/swc/favicon-32x32.png
#> Copying <varnish>/pkgdown/assets/favicons/swc/favicon-96x96.png to
#> favicons/swc/favicon-96x96.png
#> Copying <varnish>/pkgdown/assets/favicons/swc/favicon.ico to
#> favicons/swc/favicon.ico
#> Copying <varnish>/pkgdown/assets/favicons/swc/mstile-144x144.png to
#> favicons/swc/mstile-144x144.png
#> Copying <varnish>/pkgdown/assets/favicons/swc/mstile-150x150.png to
#> favicons/swc/mstile-150x150.png
#> Copying <varnish>/pkgdown/assets/favicons/swc/mstile-310x150.png to
#> favicons/swc/mstile-310x150.png
#> Copying <varnish>/pkgdown/assets/favicons/swc/mstile-310x310.png to
#> favicons/swc/mstile-310x310.png
#> Copying <varnish>/pkgdown/assets/favicons/swc/mstile-70x70.png to
#> favicons/swc/mstile-70x70.png
#> Copying <varnish>/pkgdown/assets/mstile-150x150.png to
#> mstile-150x150.png
#> Copying <varnish>/pkgdown/assets/safari-pinned-tab.svg to
#> safari-pinned-tab.svg
#> Copying <varnish>/pkgdown/assets/site.webmanifest to site.webmanifest
#> ! No valid citation information available.
cli::cli_h2("git status: {gert::git_branch(repo = res)}")
#> 
#> ── git status: main ──
#> 
print(gert::git_status(repo = res))
#> # A tibble: 0 × 3
#> # ℹ 3 variables: file <chr>, status <chr>, staged <lgl>
cli::cli_h2('git status: {gert::git_branch(repo = fs::path(res, "site", "built"))}')
#> ── git status: md-outputs ──
#> 
print(gert::git_status(repo = fs::path(res, "site", "built")))
#> # A tibble: 13 × 3
#>    file                status staged
#>    <chr>               <chr>  <lgl> 
#>  1 CODE_OF_CONDUCT.md  new    FALSE 
#>  2 LICENSE.md          new    FALSE 
#>  3 config.yaml         new    FALSE 
#>  4 fig/                new    FALSE 
#>  5 index.md            new    FALSE 
#>  6 instructor-notes.md new    FALSE 
#>  7 introduction.md     new    FALSE 
#>  8 learner-profiles.md new    FALSE 
#>  9 links.md            new    FALSE 
#> 10 md5sum.txt          new    FALSE 
#> 11 reference.md        new    FALSE 
#> 12 renv.lock           new    FALSE 
#> 13 setup.md            new    FALSE 
cli::cli_h2('git status: {gert::git_branch(repo = fs::path(res, "site", "docs"))}')
#> ── git status: gh-pages ──
#> 
print(gert::git_status(repo = fs::path(res, "site", "docs")))
#> # A tibble: 36 × 3
#>    file                       status staged
#>    <chr>                      <chr>  <lgl> 
#>  1 .nojekyll                  new    FALSE 
#>  2 404.html                   new    FALSE 
#>  3 CODE_OF_CONDUCT.html       new    FALSE 
#>  4 LICENSE.html               new    FALSE 
#>  5 aio.html                   new    FALSE 
#>  6 android-chrome-192x192.png new    FALSE 
#>  7 android-chrome-512x512.png new    FALSE 
#>  8 apple-touch-icon.png       new    FALSE 
#>  9 assets/                    new    FALSE 
#> 10 bootstrap-toc.css          new    FALSE 
#> # ℹ 26 more rows
tok <- Sys.time()
cli::cli_alert_info("Elapsed time: {round(tok - tik, 2)} seconds")
#> ℹ Elapsed time: 13.15 seconds
tik <- Sys.time()
cli::cli_h1("Clean Up")
#> 
#> ── Clean Up ────────────────────────────────────────────────────────────
cli::cli_alert_info("object db is an expression that evaluates to {.code {db}}")
#> ℹ object db is an expression that evaluates to `sandpaper:::github_worktree_remove("/tmp/RtmpofsREx/file1c8b62575816/lesson-example/site/built", "/tmp/RtmpofsREx/file1c8b62575816/lesson-example")`
eval(db)
#> Running git worktree remove --force \
#>   /tmp/RtmpofsREx/file1c8b62575816/lesson-example/site/built
#> $status
#> [1] 0
#> 
#> $stdout
#> [1] ""
#> 
#> $stderr
#> [1] ""
#> 
#> $timeout
#> [1] FALSE
#> 
cli::cli_alert_info("object ds is an expression that evaluates to {.code {ds}}")
#> ℹ object ds is an expression that evaluates to `sandpaper:::github_worktree_remove("/tmp/RtmpofsREx/file1c8b62575816/lesson-example/site/docs", "/tmp/RtmpofsREx/file1c8b62575816/lesson-example")`
eval(ds)
#> Running git worktree remove --force \
#>   /tmp/RtmpofsREx/file1c8b62575816/lesson-example/site/docs
#> $status
#> [1] 0
#> 
#> $stdout
#> [1] ""
#> 
#> $stderr
#> [1] ""
#> 
#> $timeout
#> [1] FALSE
#> 
sandpaper:::remove_local_remote(repo = res)
#> ℹ removing 'sandpaper-local' (/tmp/RtmpofsREx/REMOTE-1c8b2f82223a)
#> /tmp/RtmpofsREx/REMOTE-1c8b2f82223a
sandpaper:::reset_git_user(res)
# remove the test fixture and report
tryCatch(fs::dir_delete(res), error = function() FALSE)
tok <- Sys.time()
cli::cli_alert_info("Elapsed time: {round(tok - tik, 2)} seconds")
#> ℹ Elapsed time: 0.15 seconds
```
