#!/usr/bin/env bash
set -eo pipefail

# Download and update sandpaper workflow files from an upstream repository
#
# usage: 
#   bash update-workflows.sh [UPSTREAM] [SOURCE]
#
# args:
#   UPSTREAM - a version number from which to fetch the workflows. By default,
#     this is fetched from https://carpentries.r-universe.dev/packages/sandpaper
#   SOURCE - a CRAN-like repository from which to fetch a tarball of sandpaper
#     By default this is fetched from https://carpentries.r-universe.dev/
#
# example: Reset the workflow versions to that of 0.0.0.9041 from the drat
#   archives
#
# bash update-workflows.sh 0.0.0.9041 https://carpentries.github.io/drat/

# Fail if we aren't in a sandpaper repository
if [[ -r .github/workflows/sandpaper-main.yaml || -r .github/workflows/sandpaper-version.txt ]]; then
  echo "" > /dev/null
else
  echo "::error::This is not a {sandpaper} repository"
  exit 1
fi

# Set variables needed
UPSTREAM="${1:-}"
SOURCE="${2:-https://carpentries.r-universe.dev}"
CURRENT=$(cat .github/workflows/sandpaper-version.txt)

# Fetch upstream version from the API if we don't have that information
if [[ ${UPSTREAM} == '' ]]; then
  UPSTREAM=$(curl ${SOURCE}/packages/sandpaper/)
  UPSTREAM=$(echo ${UPSTREAM} | grep '[.]' | sed -E -e 's/[^0-9.]//g')
fi

# Create a temporary directory for the sandpaper resource files to land in
if [[ -d ${TMPDIR} ]]; then
  TMP="${TMPDIR}/sandpaper-${RANDOM}"
elif [[ -d /tmp/ ]]; then
  TMP="/tmp/sandpaper-${RANDOM}"
else
  TMP="../sandpaper-${RANDOM}"
fi
mkdir -p ${TMP}

# Show the version inforamtion
echo "::group::Version Information"
echo "This version:    ${CURRENT}"
echo "Current version: ${UPSTREAM}"
echo "::endgroup::"

# Copy the contents if the versions do not match
if [[ ${CURRENT} != ${UPSTREAM} ]]; then
  echo "::group::Copying files and updating the version number"
  curl ${SOURCE}/src/contrib/sandpaper_${UPSTREAM}.tar.gz | \
    tar -C ${TMP} --wildcards -xzv sandpaper/inst/workflows/*
  cp -v ${TMP}/sandpaper/inst/workflows/* .github/workflows/
  echo "Updating version number to ${UPSTREAM}"
  echo ${UPSTREAM} > .github/workflows/sandpaper-version.txt
  echo "::set-output name=old::${CURRENT}"
  echo "::set-output name=new::${UPSTREAM}"
  echo "::endgroup::"
  rm -r ${TMP}
else
  echo "Nothing to update!"
fi

