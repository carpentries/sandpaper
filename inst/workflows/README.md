# Carpentries Workflows

This directory contains workflows to be used for Lessons using the {sandpaper}
template.

## Deployment

### Build and Deploy (sandpaper-main.yaml)

This is the main driver that will only act on the main branch of the repository.
This workflow does not use any custom actions from this repository.

## Pull Request and Review Management

This series of workflows all go together and are described in the following 
diagram and the below sections:

![Graph representation of a pull request](https://raw.githubusercontent.com/zkamvar/stunning-barnacle/main/img/pr-flow.dot.svg)

### Recieve Pull Request (pull-request.yaml)

The first step is to build the generated content from the pull request. This
builds the content and uploads three artifacts:

1. The pull request number (pr)
2. A summary of changes after the rendering process (diff)
3. The rendered files (build)

These artifacts are used by the next workflow.

### Comment on Pull Request (comment-pr.yaml)

This workflow is triggered if the `pull-request.yaml` workflow is successful.
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

### Close PR Signal (pr-close.yaml)

Triggered any time a pull request is closed. This emits an artifact that is the
pull request number for the next action

### Remove Pull Request Branch (remove-branch.yaml)

Tiggered by `pr-close.yaml`. This removes the temporary branch associated with
the pull request (if it was created).
