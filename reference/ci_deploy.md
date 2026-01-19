# (INTERNAL) Build and deploy the site with continous integration

A platform-agnostic method of deploying a lesson website and cached
content. This function takes advantage of git worktrees to render and
push content to orphan branches, which can be used to host the lesson
website. **This function assumes that you are in a git clone from a
remote and have write access to that remote**.

## Usage

``` r
ci_deploy(
  path = ".",
  md_branch = "md-outputs",
  site_branch = "gh-pages",
  remote = "origin",
  reset = FALSE,
  skip_manage_deps = FALSE
)
```

## Arguments

- path:

  path to the lesson

- md_branch:

  the branch name that contains the markdown outputs

- site_branch:

  the branch name that contains the full HTML site

- remote:

  the name of the git remote to which you should deploy.

- reset:

  if `TRUE`, the markdown cache is cleared before rebuilding, this
  defaults to `FALSE` meaning the markdown cache will be provisioned and
  used.

- skip_manage_deps:

  if `TRUE`, dependency management will NOT be processed. This defaults
  to `FALSE`. Set this to TRUE to force dependency management to be
  handled in the separate package cache update and apply steps in the CI
  workflow, and therefore can be skipped.

## Value

Nothing, invisibly. This is used for it's side-effect

## Details

`ci_deploy()` does the same thing as
[`build_lesson()`](https://carpentries.github.io/sandpaper/reference/build_lesson.md),
except instead of storing the outputs under the `site/` folder, it
pushes the outputs to remote orphan branches (determined by the
`md_branch` and `site_branch` arguments). These branches are used as the
cache and the website, respectively. If these branches do not exist,
they will be created.

### Requirements

This function can only run in a non-interactive fashion. If you try to
run it interactively, you will get an error message. It assumes that the
following are true:

- it is running in a script or automated workflow

- it is running in a clone of a git repository

- the remote exists and is writable

Unexpected consequences can arise from violating these assumptions.

### Workflow

This function has a similar two-step workflow as
[`build_lesson()`](https://carpentries.github.io/sandpaper/reference/build_lesson.md),
with a few extra steps to ensure that the git branches are set up
correctly. Below are the steps with elements common to
[`build_lesson()`](https://carpentries.github.io/sandpaper/reference/build_lesson.md)
annotated with `*`

1.  check that a git user and email is registered

2.  `*` Validate the lesson and generate global variables with
    [`validate_lesson()`](https://carpentries.github.io/sandpaper/reference/validate_lesson.md)

3.  provision, build, and deploy markdown branch with
    [`ci_build_markdown()`](https://carpentries.github.io/sandpaper/reference/ci_build.md) i.
    provision markdown branch with
    [`git_worktree_setup()`](https://carpentries.github.io/sandpaper/reference/git_worktree.md) ii.
    `*` build the markdown source documents with
    [`build_markdown()`](https://carpentries.github.io/sandpaper/reference/build_markdown.md) iii.
    commit and push the git worktree to the remote branch with
    [`github_worktree_commit()`](https://carpentries.github.io/sandpaper/reference/git_worktree.md)

4.  provision, build, and deploy site branch with
    [`ci_build_site()`](https://carpentries.github.io/sandpaper/reference/ci_build.md) i.
    provision site branch with
    [`git_worktree_setup()`](https://carpentries.github.io/sandpaper/reference/git_worktree.md) ii.
    `*` build the site HTML documents with
    [`build_site()`](https://carpentries.github.io/sandpaper/reference/build_site.md) iii.
    commit and push the git worktree to the remote branch with
    [`github_worktree_commit()`](https://carpentries.github.io/sandpaper/reference/git_worktree.md) iv.
    remove the git worktree with
    [`github_worktree_remove()`](https://carpentries.github.io/sandpaper/reference/git_worktree.md)

5.  remove markdown git worktree with
    [`github_worktree_remove()`](https://carpentries.github.io/sandpaper/reference/git_worktree.md)

## Note

this function is not for interactive use. It requires git to be
installed on your machine and will destroy anything you have in the
`site/` folder. For R-based lessons it *will* rebuild all components if
the lockfile has changed.

## Examples

``` r
# For this example, we are setting up a temporary repository with a local
# remote called `sandpaper-local`. This demonstrates how `ci_deploy()`
# modifies the remote, but there are setup and teardown steps to run.
# The actual example is highlighted below under the DEPLOY comment.

# SETUP -------------------------------------------------------------------
snd <- asNamespace("sandpaper")
tik <- Sys.time()
cli::cli_h1("Set up")
#> 
#> ── Set up ──────────────────────────────────────────────────────────────
cli::cli_h2("Create Lesson")
#> 
#> ── Create Lesson ──
#> 
restore_fixture <- snd$create_test_lesson()
#> → Bootstrapping example lesson
#> ℹ Lesson bootstrapped in 3.307063 secs
#> → Bootstrapping example lesson
res <- getOption("sandpaper.test_fixture")
cli::cli_h2("Create Remote")
#> 
#> ── Create Remote ──
#> 
rmt <- fs::file_temp(pattern = "REMOTE-")
snd$setup_local_remote(repo = res, remote = rmt, verbose = FALSE)
#> ℹ Remote set up in 0.01467538 secs
tok <- Sys.time()
cli::cli_alert_info("Elapsed time: {round(tok - tik, 2)} seconds")
#> ℹ Elapsed time: 3.35 seconds

# reporting -----
# The repository should only have one branch and the remote should be in
# sync with the local.
cli::cli_h2("Local status")
#> 
#> ── Local status ──
#> 
gert::git_branch_list(repo = res)[c('name', 'commit', 'updated')]
#> # A tibble: 2 × 3
#>   name                 commit                        updated            
#>   <chr>                <chr>                         <dttm>             
#> 1 main                 29d3614cce9bc596ef24faaa7a82… 2026-01-19 14:06:17
#> 2 sandpaper-local/main 29d3614cce9bc596ef24faaa7a82… 2026-01-19 14:06:17
cli::cli_h2("First episode status")
#> ── First episode status ──
#> 
gert::git_stat_files("episodes/introduction.Rmd", repo = res)
#> # A tibble: 1 × 5
#>   file             created             modified            commits head 
#> * <chr>            <dttm>              <dttm>                <int> <chr>
#> 1 episodes/introd… 2026-01-19 14:06:17 2026-01-19 14:06:17       1 29d3…
gert::git_stat_files("episodes/introduction.Rmd", repo = rmt)
#> # A tibble: 1 × 5
#>   file             created             modified            commits head 
#> * <chr>            <dttm>              <dttm>                <int> <chr>
#> 1 episodes/introd… 2026-01-19 14:06:17 2026-01-19 14:06:17       1 29d3…

# DEPLOY ------------------------------------------------------------------
tik <- Sys.time()
cli::cli_h1("deploy to remote")
#> ── deploy to remote ────────────────────────────────────────────────────
sandpaper:::ci_deploy(path = res, remote = "sandpaper-local")
#> ── Validating Fenced Divs ──────────────────────────────────────────────
#> ── Validating Internal Links and Images ────────────────────────────────
#> ::group::Create New Branch
#> Running git checkout --orphan md-outputs
#> Switched to a new branch 'md-outputs'
#> Running git rm -rf --quiet .
#> Running git commit --allow-empty -m 'Initializing md-outputs branch'
#> [md-outputs (root-commit) 00d1e84] Initializing md-outputs branch
#> Running git push sandpaper-local 'HEAD:md-outputs'
#> To /tmp/Rtmph9vhkW/REMOTE-1bff471ebdeb
#>  * [new branch]      HEAD -> md-outputs
#> Running git checkout main
#> Switched to branch 'main'
#> Your branch is up to date with 'sandpaper-local/main'.
#> ::endgroup::
#> ::group::Fetch sandpaper-local/md-outputs
#> Running git remote set-branches sandpaper-local md-outputs
#> Running git fetch sandpaper-local md-outputs
#> From /tmp/Rtmph9vhkW/REMOTE-1bff471ebdeb
#>  * branch            md-outputs -> FETCH_HEAD
#> Running git remote set-branches sandpaper-local '*'
#> ::endgroup::
#> ::group::Add worktree for sandpaper-local/md-outputs in site/built
#> Running git worktree add --track -B md-outputs \
#>   /tmp/Rtmph9vhkW/file1bff75c0d5a1/lesson-example/site/built \
#>   sandpaper-local/md-outputs
#> Preparing worktree (resetting branch 'md-outputs'; was at 00d1e84)
#> branch 'md-outputs' set up to track 'sandpaper-local/md-outputs'.
#> HEAD is now at 00d1e84 Initializing md-outputs branch
#> ::endgroup::
#> ::group::Build Markdown Sources
#> ℹ Checking renv dependencies
#> ℹ Consent to use package cache provided
#> → Searching for and installing available dependencies
#> Finding R package dependencies ... Done!
#> → Restoring any dependency versions
#> - The library is already synchronized with the lockfile.
#> → Recording changes in lockfile
#> - The lockfile is already up to date.
#> ℹ Using package cache in /home/runner/.cache/R/renv
#> 
#> 
#> processing file: /tmp/Rtmph9vhkW/file1bff75c0d5a1/lesson-example/episodes/introduction.Rmd
#> 1/3          
#> 2/3 [pyramid]
#> 3/3          
#> output file: /tmp/Rtmph9vhkW/file1bff75c0d5a1/lesson-example/site/built/introduction.md
#> 
#> ::endgroup::
#> ::group::Commit Markdown Sources
#> Running git commit --allow-empty -m \
#>   'markdown source builds
#> 
#> Auto-generated via `{sandpaper}`
#> Source  : 29d3614cce9bc596ef24faaa7a82c150db5ca2c7
#> Branch  : main
#> Author  : carpenter <team@carpentries.org>
#> Time    : 2026-01-19 14:06:17 +0000
#> Message : Initial commit [via `{sandpaper}`]
#> '
#> [md-outputs 9342cbf] markdown source builds
#>  13 files changed, 1364 insertions(+)
#>  create mode 100644 CODE_OF_CONDUCT.md
#>  create mode 100644 LICENSE.md
#>  create mode 100644 config.yaml
#>  create mode 100644 fig/introduction-rendered-pyramid-1.png
#>  create mode 100644 index.md
#>  create mode 100644 instructor-notes.md
#>  create mode 100644 introduction.md
#>  create mode 100644 learner-profiles.md
#>  create mode 100644 links.md
#>  create mode 100644 md5sum.txt
#>  create mode 100644 reference.md
#>  create mode 100644 renv.lock
#>  create mode 100644 setup.md
#> Running git remote -v
#> sandpaper-local  /tmp/Rtmph9vhkW/REMOTE-1bff471ebdeb (fetch)
#> sandpaper-local  /tmp/Rtmph9vhkW/REMOTE-1bff471ebdeb (push)
#> Running git push --force sandpaper-local 'HEAD:md-outputs'
#> To /tmp/Rtmph9vhkW/REMOTE-1bff471ebdeb
#>    00d1e84..9342cbf  HEAD -> md-outputs
#> ::endgroup::
#> ::group::Create New Branch
#> Running git checkout --orphan gh-pages
#> Switched to a new branch 'gh-pages'
#> Running git rm -rf --quiet .
#> Running git commit --allow-empty -m 'Initializing gh-pages branch'
#> [gh-pages (root-commit) 4202ab0] Initializing gh-pages branch
#> Running git push sandpaper-local 'HEAD:gh-pages'
#> To /tmp/Rtmph9vhkW/REMOTE-1bff471ebdeb
#>  * [new branch]      HEAD -> gh-pages
#> Running git checkout main
#> Switched to branch 'main'
#> Your branch is up to date with 'sandpaper-local/main'.
#> ::endgroup::
#> ::group::Fetch sandpaper-local/gh-pages
#> Running git remote set-branches sandpaper-local gh-pages
#> Running git fetch sandpaper-local gh-pages
#> From /tmp/Rtmph9vhkW/REMOTE-1bff471ebdeb
#>  * branch            gh-pages   -> FETCH_HEAD
#> Running git remote set-branches sandpaper-local '*'
#> ::endgroup::
#> ::group::Add worktree for sandpaper-local/gh-pages in site/docs
#> Running git worktree add --track -B gh-pages \
#>   /tmp/Rtmph9vhkW/file1bff75c0d5a1/lesson-example/site/docs \
#>   sandpaper-local/gh-pages
#> Preparing worktree (resetting branch 'gh-pages'; was at 4202ab0)
#> branch 'gh-pages' set up to track 'sandpaper-local/gh-pages'.
#> HEAD is now at 4202ab0 Initializing gh-pages branch
#> ::endgroup::
#> ::group::Build Lesson Website
#> ◉ pandoc found
#>   version : 3.1.11
#>   path    : /opt/hostedtoolcache/pandoc/3.1.11/x64
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
#> ── Scanning episodes to rebuild ────────────────────────────────────────
#> ── Creating citation page ──────────────────────────────────────────────
#> ══ Validating cff ══════════════════════════════════════════════════════
#> ✔ Congratulations! /tmp/Rtmph9vhkW/file1bff75c0d5a1/lesson-example/CITATION.cff is valid
#> Writing `instructor/citation.html`
#> Writing `citation.html`
#> Writing `instructor/CODE_OF_CONDUCT.html`
#> Writing `CODE_OF_CONDUCT.html`
#> Writing `instructor/LICENSE.html`
#> Writing `LICENSE.html`
#> Writing `instructor/introduction.html`
#> Writing `introduction.html`
#> Writing `instructor/reference.html`
#> Writing `reference.html`
#> ── Creating 404 page ───────────────────────────────────────────────────
#> Writing `instructor/404.html`
#> Writing `404.html`
#> ── Creating learner profiles ───────────────────────────────────────────
#> Writing `instructor/profiles.html`
#> Writing `profiles.html`
#> ── Creating homepage ───────────────────────────────────────────────────
#> Writing `instructor/index.html`
#> Writing `index.html`
#> ── Creating keypoints summary ──────────────────────────────────────────
#> Writing 'instructor/key-points.html'
#> Writing 'key-points.html'
#> ── Creating All-in-one page ────────────────────────────────────────────
#> Writing 'instructor/aio.html'
#> Writing 'aio.html'
#> ── Creating Images page ────────────────────────────────────────────────
#> Writing 'instructor/images.html'
#> Writing 'images.html'
#> ── Creating Instructor Notes ───────────────────────────────────────────
#> Writing 'instructor/instructor-notes.html'
#> Writing 'instructor-notes.html'
#> ── Creating sitemap.xml ────────────────────────────────────────────────
#> 
#> Output created: /tmp/Rtmph9vhkW/file1bff75c0d5a1/lesson-example/site/docs/index.html
#> ::endgroup::
#> ::group::Commit Lesson Website
#> Running git commit --allow-empty -m \
#>   'site deploy
#> 
#> Auto-generated via `{sandpaper}`
#> Source  : 9342cbfe0ccf871d932b9401260874367de4f8f4
#> Branch  : md-outputs
#> Author  : GitHub Actions <actions@github.com>
#> Time    : 2026-01-19 14:06:21 +0000
#> Message : markdown source builds
#> 
#> Auto-generated via `{sandpaper}`
#> Source  : 29d3614cce9bc596ef24faaa7a82c150db5ca2c7
#> Branch  : main
#> Author  : carpenter <team@carpentries.org>
#> Time    : 2026-01-19 14:06:17 +0000
#> Message : Initial commit [via `{sandpaper}`]
#> '
#> [gh-pages cba964d] site deploy
#>  237 files changed, 153767 insertions(+)
#>  create mode 100644 .nojekyll
#>  create mode 100644 404.html
#>  create mode 100644 CODE_OF_CONDUCT.html
#>  create mode 100644 LICENSE.html
#>  create mode 100644 aio.html
#>  create mode 100644 android-chrome-192x192.png
#>  create mode 100644 android-chrome-512x512.png
#>  create mode 100644 apple-touch-icon.png
#>  create mode 100644 assets/fonts/Mulish-Black.eot
#>  create mode 100644 assets/fonts/Mulish-Black.svg
#>  create mode 100644 assets/fonts/Mulish-Black.ttf
#>  create mode 100644 assets/fonts/Mulish-Black.woff
#>  create mode 100644 assets/fonts/Mulish-Black.woff2
#>  create mode 100644 assets/fonts/Mulish-BlackItalic.eot
#>  create mode 100644 assets/fonts/Mulish-BlackItalic.svg
#>  create mode 100644 assets/fonts/Mulish-BlackItalic.ttf
#>  create mode 100644 assets/fonts/Mulish-BlackItalic.woff
#>  create mode 100644 assets/fonts/Mulish-BlackItalic.woff2
#>  create mode 100644 assets/fonts/Mulish-Bold.eot
#>  create mode 100644 assets/fonts/Mulish-Bold.svg
#>  create mode 100644 assets/fonts/Mulish-Bold.ttf
#>  create mode 100644 assets/fonts/Mulish-Bold.woff
#>  create mode 100644 assets/fonts/Mulish-Bold.woff2
#>  create mode 100644 assets/fonts/Mulish-BoldItalic.eot
#>  create mode 100644 assets/fonts/Mulish-BoldItalic.svg
#>  create mode 100644 assets/fonts/Mulish-BoldItalic.ttf
#>  create mode 100644 assets/fonts/Mulish-BoldItalic.woff
#>  create mode 100644 assets/fonts/Mulish-BoldItalic.woff2
#>  create mode 100644 assets/fonts/Mulish-ExtraBold.eot
#>  create mode 100644 assets/fonts/Mulish-ExtraBold.svg
#>  create mode 100644 assets/fonts/Mulish-ExtraBold.ttf
#>  create mode 100644 assets/fonts/Mulish-ExtraBold.woff
#>  create mode 100644 assets/fonts/Mulish-ExtraBold.woff2
#>  create mode 100644 assets/fonts/Mulish-ExtraBoldItalic.eot
#>  create mode 100644 assets/fonts/Mulish-ExtraBoldItalic.svg
#>  create mode 100644 assets/fonts/Mulish-ExtraBoldItalic.ttf
#>  create mode 100644 assets/fonts/Mulish-ExtraBoldItalic.woff
#>  create mode 100644 assets/fonts/Mulish-ExtraBoldItalic.woff2
#>  create mode 100644 assets/fonts/Mulish-ExtraLight.eot
#>  create mode 100644 assets/fonts/Mulish-ExtraLight.svg
#>  create mode 100644 assets/fonts/Mulish-ExtraLight.ttf
#>  create mode 100644 assets/fonts/Mulish-ExtraLight.woff
#>  create mode 100644 assets/fonts/Mulish-ExtraLight.woff2
#>  create mode 100644 assets/fonts/Mulish-ExtraLightItalic.eot
#>  create mode 100644 assets/fonts/Mulish-ExtraLightItalic.svg
#>  create mode 100644 assets/fonts/Mulish-ExtraLightItalic.ttf
#>  create mode 100644 assets/fonts/Mulish-ExtraLightItalic.woff
#>  create mode 100644 assets/fonts/Mulish-ExtraLightItalic.woff2
#>  create mode 100644 assets/fonts/Mulish-Italic-VariableFont_wght.ttf
#>  create mode 100644 assets/fonts/Mulish-Italic.eot
#>  create mode 100644 assets/fonts/Mulish-Italic.svg
#>  create mode 100644 assets/fonts/Mulish-Italic.ttf
#>  create mode 100644 assets/fonts/Mulish-Italic.woff
#>  create mode 100644 assets/fonts/Mulish-Italic.woff2
#>  create mode 100644 assets/fonts/Mulish-Light.eot
#>  create mode 100644 assets/fonts/Mulish-Light.svg
#>  create mode 100644 assets/fonts/Mulish-Light.ttf
#>  create mode 100644 assets/fonts/Mulish-Light.woff
#>  create mode 100644 assets/fonts/Mulish-Light.woff2
#>  create mode 100644 assets/fonts/Mulish-LightItalic.eot
#>  create mode 100644 assets/fonts/Mulish-LightItalic.svg
#>  create mode 100644 assets/fonts/Mulish-LightItalic.ttf
#>  create mode 100644 assets/fonts/Mulish-LightItalic.woff
#>  create mode 100644 assets/fonts/Mulish-LightItalic.woff2
#>  create mode 100644 assets/fonts/Mulish-Medium.eot
#>  create mode 100644 assets/fonts/Mulish-Medium.svg
#>  create mode 100644 assets/fonts/Mulish-Medium.ttf
#>  create mode 100644 assets/fonts/Mulish-Medium.woff
#>  create mode 100644 assets/fonts/Mulish-Medium.woff2
#>  create mode 100644 assets/fonts/Mulish-MediumItalic.eot
#>  create mode 100644 assets/fonts/Mulish-MediumItalic.svg
#>  create mode 100644 assets/fonts/Mulish-MediumItalic.ttf
#>  create mode 100644 assets/fonts/Mulish-MediumItalic.woff
#>  create mode 100644 assets/fonts/Mulish-MediumItalic.woff2
#>  create mode 100644 assets/fonts/Mulish-Regular.eot
#>  create mode 100644 assets/fonts/Mulish-Regular.svg
#>  create mode 100644 assets/fonts/Mulish-Regular.ttf
#>  create mode 100644 assets/fonts/Mulish-Regular.woff
#>  create mode 100644 assets/fonts/Mulish-Regular.woff2
#>  create mode 100644 assets/fonts/Mulish-SemiBold.eot
#>  create mode 100644 assets/fonts/Mulish-SemiBold.svg
#>  create mode 100644 assets/fonts/Mulish-SemiBold.ttf
#>  create mode 100644 assets/fonts/Mulish-SemiBold.woff
#>  create mode 100644 assets/fonts/Mulish-SemiBold.woff2
#>  create mode 100644 assets/fonts/Mulish-SemiBoldItalic.eot
#>  create mode 100644 assets/fonts/Mulish-SemiBoldItalic.svg
#>  create mode 100644 assets/fonts/Mulish-SemiBoldItalic.ttf
#>  create mode 100644 assets/fonts/Mulish-SemiBoldItalic.woff
#>  create mode 100644 assets/fonts/Mulish-SemiBoldItalic.woff2
#>  create mode 100644 assets/fonts/Mulish-VariableFont_wght.ttf
#>  create mode 100644 assets/fonts/MulishExtraLight-Regular.eot
#>  create mode 100644 assets/fonts/MulishExtraLight-Regular.svg
#>  create mode 100644 assets/fonts/MulishExtraLight-Regular.woff
#>  create mode 100644 assets/fonts/MulishExtraLight-Regular.woff2
#>  create mode 100644 assets/fonts/mulish-v5-latin-regular.eot
#>  create mode 100644 assets/fonts/mulish-v5-latin-regular.svg
#>  create mode 100644 assets/fonts/mulish-v5-latin-regular.ttf
#>  create mode 100644 assets/fonts/mulish-v5-latin-regular.woff
#>  create mode 100644 assets/fonts/mulish-v5-latin-regular.woff2
#>  create mode 100644 assets/fonts/mulish-variablefont_wght.woff
#>  create mode 100644 assets/fonts/mulish-variablefont_wght.woff2
#>  create mode 100644 assets/images/carpentries-logo-sm.svg
#>  create mode 100644 assets/images/carpentries-logo.svg
#>  create mode 100644 assets/images/data-logo-sm.svg
#>  create mode 100644 assets/images/data-logo.svg
#>  create mode 100644 assets/images/dropdown-arrow.svg
#>  create mode 100644 assets/images/incubator-logo-sm.svg
#>  create mode 100644 assets/images/incubator-logo.svg
#>  create mode 100644 assets/images/lab-logo-sm.svg
#>  create mode 100644 assets/images/lab-logo.svg
#>  create mode 100644 assets/images/library-logo-sm.svg
#>  create mode 100644 assets/images/library-logo.svg
#>  create mode 100644 assets/images/minus.svg
#>  create mode 100644 assets/images/orcid_icon.png
#>  create mode 100644 assets/images/parrot_icon.svg
#>  create mode 100644 assets/images/parrot_icon_colour.svg
#>  create mode 100644 assets/images/plus.svg
#>  create mode 100644 assets/images/software-logo-sm.svg
#>  create mode 100644 assets/images/software-logo.svg
#>  create mode 100644 assets/scripts.js
#>  create mode 100644 assets/styles.css
#>  create mode 100644 assets/styles.css.map
#>  create mode 100644 assets/themetoggle.js
#>  create mode 100644 bootstrap-toc.css
#>  create mode 100644 bootstrap-toc.js
#>  create mode 100644 citation.html
#>  create mode 100644 config.yaml
#>  create mode 100644 docsearch.css
#>  create mode 100644 docsearch.js
#>  create mode 100644 favicon-16x16.png
#>  create mode 100644 favicon-32x32.png
#>  create mode 100644 favicons/cp/apple-touch-icon-114x114.png
#>  create mode 100644 favicons/cp/apple-touch-icon-120x120.png
#>  create mode 100644 favicons/cp/apple-touch-icon-144x144.png
#>  create mode 100644 favicons/cp/apple-touch-icon-152x152.png
#>  create mode 100644 favicons/cp/apple-touch-icon-57x57.png
#>  create mode 100644 favicons/cp/apple-touch-icon-60x60.png
#>  create mode 100644 favicons/cp/apple-touch-icon-72x72.png
#>  create mode 100644 favicons/cp/apple-touch-icon-76x76.png
#>  create mode 100644 favicons/cp/favicon-128.png
#>  create mode 100644 favicons/cp/favicon-16x16.png
#>  create mode 100644 favicons/cp/favicon-196x196.png
#>  create mode 100644 favicons/cp/favicon-32x32.png
#>  create mode 100644 favicons/cp/favicon-96x96.png
#>  create mode 100644 favicons/cp/favicon.ico
#>  create mode 100644 favicons/cp/mstile-144x144.png
#>  create mode 100644 favicons/cp/mstile-150x150.png
#>  create mode 100644 favicons/cp/mstile-310x150.png
#>  create mode 100644 favicons/cp/mstile-310x310.png
#>  create mode 100644 favicons/cp/mstile-70x70.png
#>  create mode 100644 favicons/dc/apple-touch-icon-114x114.png
#>  create mode 100644 favicons/dc/apple-touch-icon-120x120.png
#>  create mode 100644 favicons/dc/apple-touch-icon-144x144.png
#>  create mode 100644 favicons/dc/apple-touch-icon-152x152.png
#>  create mode 100644 favicons/dc/apple-touch-icon-57x57.png
#>  create mode 100644 favicons/dc/apple-touch-icon-60x60.png
#>  create mode 100644 favicons/dc/apple-touch-icon-72x72.png
#>  create mode 100644 favicons/dc/apple-touch-icon-76x76.png
#>  create mode 100644 favicons/dc/favicon-128.png
#>  create mode 100644 favicons/dc/favicon-16x16.png
#>  create mode 100644 favicons/dc/favicon-196x196.png
#>  create mode 100644 favicons/dc/favicon-32x32.png
#>  create mode 100644 favicons/dc/favicon-96x96.png
#>  create mode 100644 favicons/dc/favicon.ico
#>  create mode 100644 favicons/dc/mstile-144x144.png
#>  create mode 100644 favicons/dc/mstile-150x150.png
#>  create mode 100644 favicons/dc/mstile-310x150.png
#>  create mode 100644 favicons/dc/mstile-310x310.png
#>  create mode 100644 favicons/dc/mstile-70x70.png
#>  create mode 100644 favicons/lc/apple-touch-icon-114x114.png
#>  create mode 100644 favicons/lc/apple-touch-icon-120x120.png
#>  create mode 100644 favicons/lc/apple-touch-icon-144x144.png
#>  create mode 100644 favicons/lc/apple-touch-icon-152x152.png
#>  create mode 100644 favicons/lc/apple-touch-icon-57x57.png
#>  create mode 100644 favicons/lc/apple-touch-icon-60x60.png
#>  create mode 100644 favicons/lc/apple-touch-icon-72x72.png
#>  create mode 100644 favicons/lc/apple-touch-icon-76x76.png
#>  create mode 100644 favicons/lc/favicon-128.png
#>  create mode 100644 favicons/lc/favicon-16x16.png
#>  create mode 100644 favicons/lc/favicon-196x196.png
#>  create mode 100644 favicons/lc/favicon-32x32.png
#>  create mode 100644 favicons/lc/favicon-96x96.png
#>  create mode 100644 favicons/lc/favicon.ico
#>  create mode 100644 favicons/lc/mstile-144x144.png
#>  create mode 100644 favicons/lc/mstile-150x150.png
#>  create mode 100644 favicons/lc/mstile-310x150.png
#>  create mode 100644 favicons/lc/mstile-310x310.png
#>  create mode 100644 favicons/lc/mstile-70x70.png
#>  create mode 100644 favicons/swc/apple-touch-icon-114x114.png
#>  create mode 100644 favicons/swc/apple-touch-icon-120x120.png
#>  create mode 100644 favicons/swc/apple-touch-icon-144x144.png
#>  create mode 100644 favicons/swc/apple-touch-icon-152x152.png
#>  create mode 100644 favicons/swc/apple-touch-icon-57x57.png
#>  create mode 100644 favicons/swc/apple-touch-icon-60x60.png
#>  create mode 100644 favicons/swc/apple-touch-icon-72x72.png
#>  create mode 100644 favicons/swc/apple-touch-icon-76x76.png
#>  create mode 100644 favicons/swc/favicon-128.png
#>  create mode 100644 favicons/swc/favicon-16x16.png
#>  create mode 100644 favicons/swc/favicon-196x196.png
#>  create mode 100644 favicons/swc/favicon-32x32.png
#>  create mode 100644 favicons/swc/favicon-96x96.png
#>  create mode 100644 favicons/swc/favicon.ico
#>  create mode 100644 favicons/swc/mstile-144x144.png
#>  create mode 100644 favicons/swc/mstile-150x150.png
#>  create mode 100644 favicons/swc/mstile-310x150.png
#>  create mode 100644 favicons/swc/mstile-310x310.png
#>  create mode 100644 favicons/swc/mstile-70x70.png
#>  create mode 100644 fig/introduction-rendered-pyramid-1.png
#>  create mode 100644 images.html
#>  create mode 100644 index.html
#>  create mode 100644 instructor-notes.html
#>  create mode 100644 instructor/404.html
#>  create mode 100644 instructor/CODE_OF_CONDUCT.html
#>  create mode 100644 instructor/LICENSE.html
#>  create mode 100644 instructor/aio.html
#>  create mode 100644 instructor/citation.html
#>  create mode 100644 instructor/images.html
#>  create mode 100644 instructor/index.html
#>  create mode 100644 instructor/instructor-notes.html
#>  create mode 100644 instructor/introduction.html
#>  create mode 100644 instructor/key-points.html
#>  create mode 100644 instructor/profiles.html
#>  create mode 100644 instructor/reference.html
#>  create mode 100644 introduction.html
#>  create mode 100644 key-points.html
#>  create mode 100644 link.svg
#>  create mode 100644 md5sum.txt
#>  create mode 100644 mstile-150x150.png
#>  create mode 100644 pkgdown.css
#>  create mode 100644 pkgdown.js
#>  create mode 100644 pkgdown.yml
#>  create mode 100644 profiles.html
#>  create mode 100644 reference.html
#>  create mode 100644 renv.lock
#>  create mode 100644 safari-pinned-tab.svg
#>  create mode 100644 site.webmanifest
#>  create mode 100644 sitemap.xml
#> Running git remote -v
#> sandpaper-local  /tmp/Rtmph9vhkW/REMOTE-1bff471ebdeb (fetch)
#> sandpaper-local  /tmp/Rtmph9vhkW/REMOTE-1bff471ebdeb (push)
#> Running git push --force sandpaper-local 'HEAD:gh-pages'
#> To /tmp/Rtmph9vhkW/REMOTE-1bff471ebdeb
#>    4202ab0..cba964d  HEAD -> gh-pages
#> ::endgroup::
#> Running git worktree remove --force \
#>   /tmp/Rtmph9vhkW/file1bff75c0d5a1/lesson-example/site/docs
#> Running git worktree remove --force \
#>   /tmp/Rtmph9vhkW/file1bff75c0d5a1/lesson-example/site/built
tok <- Sys.time()
cli::cli_alert_info("Elapsed time: {round(tok - tik, 2)} seconds")
#> ℹ Elapsed time: 17.49 seconds

# reporting -----
# The repository and remote should both have three branches
cli::cli_h2("Local status")
#> 
#> ── Local status ──
#> 
gert::git_branch_list(repo = res)[c('name', 'commit', 'updated')]
#> # A tibble: 6 × 3
#>   name                       commit                  updated            
#>   <chr>                      <chr>                   <dttm>             
#> 1 gh-pages                   cba964d0985b7e94401ae5… 2026-01-19 14:06:34
#> 2 main                       29d3614cce9bc596ef24fa… 2026-01-19 14:06:17
#> 3 md-outputs                 9342cbfe0ccf871d932b94… 2026-01-19 14:06:21
#> 4 sandpaper-local/gh-pages   cba964d0985b7e94401ae5… 2026-01-19 14:06:34
#> 5 sandpaper-local/main       29d3614cce9bc596ef24fa… 2026-01-19 14:06:17
#> 6 sandpaper-local/md-outputs 9342cbfe0ccf871d932b94… 2026-01-19 14:06:21

# An indicator this worked: the first episode should be represented as
# different files across the branches:
# - main: Rmd
# - md-outputs: md
# - gh-pages: html
cli::cli_h2("First episode status")
#> ── First episode status ──
#> 
gert::git_stat_files("episodes/introduction.Rmd", repo = rmt)
#> # A tibble: 1 × 5
#>   file             created             modified            commits head 
#> * <chr>            <dttm>              <dttm>                <int> <chr>
#> 1 episodes/introd… 2026-01-19 14:06:17 2026-01-19 14:06:17       1 29d3…
cli::cli_h3("rendered markdown")
#> ── rendered markdown 
gert::git_stat_files("introduction.md", repo = rmt, ref = "md-outputs")
#> # A tibble: 1 × 5
#>   file            created             modified            commits head  
#> * <chr>           <dttm>              <dttm>                <int> <chr> 
#> 1 introduction.md 2026-01-19 14:06:21 2026-01-19 14:06:21       1 9342c…
cli::cli_h3("html file")
#> 
#> ── html file 
gert::git_stat_files("introduction.html", repo = rmt, ref = "gh-pages")
#> # A tibble: 1 × 5
#>   file             created             modified            commits head 
#> * <chr>            <dttm>              <dttm>                <int> <chr>
#> 1 introduction.ht… 2026-01-19 14:06:34 2026-01-19 14:06:34       1 cba9…

# CLEAN -------------------------------------------------------------------
tik <- Sys.time()
cli::cli_h1("Clean Up")
#> 
#> ── Clean Up ────────────────────────────────────────────────────────────
snd$remove_local_remote(repo = res)
#> ℹ removing 'sandpaper-local' (/tmp/Rtmph9vhkW/REMOTE-1bff471ebdeb)
#> /tmp/Rtmph9vhkW/REMOTE-1bff471ebdeb
snd$reset_git_user(res)
# remove the test fixture and report
tryCatch(fs::dir_delete(res), error = function() FALSE)
tok <- Sys.time()
cli::cli_alert_info("Elapsed time: {round(tok - tik, 2)} seconds")
#> ℹ Elapsed time: 0.11 seconds
```
