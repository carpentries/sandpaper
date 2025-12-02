# Working with Automated Pull Requests

## Introduction

One of the innovations of {sandpaper} is the out-of-the-box integration
with GitHub Actions by supplying several workflows that deploy,
validate, and update the lesson. This vignette will focus on the latter
set of workflows: those that update the lesson in some form. In this
vignette, we will outline the components of the lesson that need
updating, demonstrate pull requests and the requirements to set them up
on a non-carpentries account, and demonstrate functions to manually
update these components.

## Components which Need to be Updated

The concept of a {sandpaper} lesson is simple: place a set of markdown
or R markdown files in a folder, run a command, and get a website out of
it. It’s not much different than a static site generator. What makes it
different is that, with a {sandpaper} lesson, you are no longer solely
responsible for ensuring that the styling and build tools are kept
up-to-date as these have been stripped from the repository and separated
into three stand-alone packages. There are, however two places in a
lesson where build requirements still live and will need updating from
time to time:

1.  Continuous Integration Workflows (in the `.github/` folder)
2.  Lesson Requirements for Generated Content (in the `renv/` folder)

A lesson created with {sandpaper} relies on deployment workflows that
live inside the `.github/` folder to ensure that it can not only be
properly deployed, but also that pull requests can be tested and
validated. Additionally, if you have a lesson that uses generated
content via R Markdown, then you will have a folder called `renv/` in
your repository. This folder will contain a lockfile at
`renv/profiles/lesson-requirements/renv.lock`, which will detail the
packages required to build the lesson, along with their versions and
specific hash of the package contents.

## Pull Request Updates

When you host a lesson on one of The Carpentries’ repositories, the
automated workflows will periodically check for updates and issue pull
requests *if there are available updates*. These pull requests are
designed to be minimally invasive and predictable to ensure that your
lesson remains up-to-date.

In addition to being run periodically, you can run them at any time by
going to your repository \> actions and selecting one of the workflows
that starts with “Maintain”. There will be a button that says “Run
Workflow” that you can push and it will start the process of checking
for updates.

### Weekly Checks: Update Workflows

On a weekly basis, the workflow located in
`.github/workflows/update-workflows.yaml` will run and update the
workflow files with the current versions from {sandpaper}. This will
then create a pull request with the title “Update Workflows to Version
X.Y.Z” from the [Carpentries Apprentice
Bot](https://github.com/carpentries-bot). *A pull request is only
created if there are updates to be had, otherwise, it will report that
there are no updates at this time.*

Check to make sure that this workflow *only* contains modified workflows
in the .`github/workflows/` and that no secrets have been accidentally
divulged.

### Monthly Checks: Update Lesson Requirements

On a monthly basis, if the lesson has generated content, the workflow in
`.github/workflows/update-cache.yaml` will run to check for updates to
the lockfile in `renv/profiles/lesson-requirements/renv.lock`. This pull
request will change only the `renv.lock` file and it will report in the
pull request itself what packages have changed.

This pull request will be followed closely by a comment that will inform
you what has changed in the generated content based on the new versions.
If the packages are relatively stable, then not much should change. This
is the time to inspect the generated output for any errors that occurr
due to packages updating their expectations or dependencies.

### Setting up a Pull Request Bot

Both of these pull requests are provided with the help of [The
Carpentries Apprentice Bot](https://github.com/carpentries-bot). This
bot is available across The Carpentries github organisations and if you
have a lesson hosted on one of these organisations, then you do not need
to worry about this section.

If you are hosting your own lesson and would like to take advantage of
these periodic updates, you do not necessarily need a bot account, but
you do need access to an account that has the following aspects

1.  Access to your lesson repository (as a collaborator or self), and
2.  A Personal Access Token registered as `SANDPAPER_WORKFLOW` in that
    repository with the `public_repo` and `workflow` scopes

#### Creating a PAT

Whether or not you choose to use a bot account or your own account, you
will need to [generate a new Personal Access Token with the repo and
workflow
scope](https://github.com/settings/tokens/new?scopes=public_repo,workflow&description=Sandpaper%20Token).

Once there, add more context in the `Note` field, set an expiration date
(default is 30 days), scroll down to the bottom of the page and select
“Generate Token”

Your token will appear in a green box and will start with `ghp_`. Copy
the token by clicking on the clipboard symbol immediately to the right
of the token and then go to your repository \> settings \> secrets and
select “New Repository Secret” if you haven’t created the
`SANDPAPER_WORKFLOW` secret before. Add `SANDPAPER_WORKFLOW` in the
“Name” field and paste your token in the “Value” field.

## Manual Updates

If you want to create updates manually without using GitHub Actions,
there are two functions available:

``` r
update_github_workflows()  # updates the package workflows
update_cache()      # uses `renv::update()` to check for updates to the package cache
```

Both of these functions will modify files locally so if you do not like
them, you can use `git restore .` to revert them to their original
state.
