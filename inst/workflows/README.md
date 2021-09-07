# Carpentries Workflows

This directory contains workflows to be used for Lessons using the {sandpaper}
lesson infrastructure. Two of these workflows require R (`sandpaper-main.yaml`
and `pr-recieve.yaml`) and the rest are bots to handle pull request management.

These workflows will likely change as {sandpaper} evolves, so it is important to
keep them up-to-date. To do this in your lesson you can do the following in your
R console:

```r
# Install/Update sandpaper
options(repos = c(carpentries = "https://carpentries.r-universe.dev/", 
  CRAN = "https://cloud.r-project.org"))
install.packages("sandpaper")

# update the workflows in your lesson
library("sandpaper")
update_github_workflows()
```

Inside this folder, you will find a file called `sandpaper-version.txt`, which
will contain a version number for sandpaper. This will be used in the future to
alert you if a workflow update is needed.

What follows are the descriptions of the workflow files:

## Deployment

### 01 Build and Deploy (sandpaper-main.yaml)

This is the main driver that will only act on the main branch of the repository.
This workflow does not use any custom actions from this repository.


## Updates

### 02 Maintain: Update Workflow Files (update-workflow.yaml)

The {sandpaper} repository was designed to do as much as possible to separate 
the tools from the content. For local builds, this is absolutely true, but 
there is a minor issue when it comes to workflow files: they must live inside 
the repository. 

This workflow ensures that the workflow files are up-to-date. The way it work is
to download the update-workflows.sh script from GitHub and run it. The script 
will do the following:

1. check the recorded version of sandpaper against the current version on github
2. update the files if there is a difference in versions

After the files are updated, a pull request is created via a
repository/organization secret token called `SANDPAPER_WORKFLOW`, which has the
`workflow` scope. This can be an individual user token, OR it can be a trusted
bot account. Maintainers are encouraged to review the changes and accept the
pull request.

This update is run ~~monthly or~~ on demand.

TODO: 
  - perform check if a pull request exists before creating pull request

## Pull Request and Review Management

This series of workflows all go together and are described in the following 
diagram and the below sections:

![Graph representation of a pull request](https://raw.githubusercontent.com/zkamvar/stunning-barnacle/main/img/pr-flow.dot.svg)

### Recieve Pull Request (pr-recieve.yaml)

The first step is to build the generated content from the pull request. This
builds the content and uploads three artifacts:

1. The pull request number (pr)
2. A summary of changes after the rendering process (diff)
3. The rendered files (build)

These artifacts are used by the next workflow.

### Comment on Pull Request (pr-comment.yaml)

This workflow is triggered if the `pr-recieve.yaml` workflow is successful.
The steps in this workflow are:

1. Test if the workflow is valid
2. If it is valid: create an orphan branch with two commits: the current state of
   the repository and the proposed changes.
3. If it is valid: comment on the pull request with the summary of changes
4. If it is NOT valid: comment on the pull request that it is not valid,
   warning the maintainer that more scrutiny is needed.

Importantly: if the pull request is invalid, the branch is not created so any
malicious code is not published. 

From here, the maintainer can request changes from the author and eventually 
either merge or reject the PR. When this happens, if the PR was valid, the 
preview branch needs to be deleted. 

### Send Close PR Signal (pr-close-signal.yaml)

Triggered any time a pull request is closed. This emits an artifact that is the
pull request number for the next action

### Remove Pull Request Branch (pr-post-remove-branch.yaml)

Tiggered by `pr-close-signal.yaml`. This removes the temporary branch associated with
the pull request (if it was created).
