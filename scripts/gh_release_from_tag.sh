#!/bin/bash
set -e

# Creates a GitHub Release from the latest tag. This is automatically run during
# `make prod_deploy`.
#
# Alternatively, a release can be created for a pre-existing $OLD_TAG by running
# this script manually. To do this, run these commands:
#
#     git checkout $OLD_TAG
#
#     # run this to include `version.json` and pin tarball assets
#     docker compose exec rack bundle exec rake precompile
#
#     # after running precompile, in `version.json` you'll need to replace the values for
#     # `timestamp_tag`, `release_url`, and `unreleased_url` to match the actual
#     # tag instead of the using the time you run this command. If you would
#     # like to also replace `version_epochtime` to match the tag's timestamp,
#     # you can use `scripts/tag_name_to_timestamp.rb` to get the timestamp.
#
#     # manually find the tag for the release prior to the tag you're releasing
#     PREVIOUS_TAG=<prior_release_tag>
#
#     ./scripts/gh_release_from_tag.sh $OLD_TAG $PREVIOUS_TAG

TAG=${1}
PREVIOUS_TAG=${2}

if [ -z "${TAG}" ]; then
    LATEST_FLAG='--latest'

    TAGS=$(git show-ref --tags | \
               grep -E '\brefs/tags/\d{4}-\d{2}-\d{2}_\d{2}\.\d{2}\.\d{2}' | \
               cut -d ' ' -f 2 | \
               cut -d '/' -f 3)
    TAG=$(echo "${TAGS}" | tail -1)
    PREVIOUS_TAG=$(echo "${TAGS}" | tail -2 | head -1)
else
    LATEST_FLAG='--latest=false'
fi

if [ -z "${PREVIOUS_TAG}" ]; then
    echo 'No PREVIOUS_TAG found for `gh release create ${TAG} --notes-start-tag=${PREVIOUS_TAG}`'
    exit 1
fi

TARBALL="${TARBALL:-public/pinned/${TAG}.js.gz}"
if [ ! -f ${TARBALL} ]; then
    TARBALL=''
fi

VERSION_JSON="${VERSION_JSON:-public/assets/version.json}"
if [ ! -f ${VERSION_JSON} ]; then
    VERSION_JSON=''
fi

REPO="${REPO:-tobymao/18xx}"

git checkout ${TAG}
gh release create ${TAG} ${TARBALL} ${VERSION_JSON} \
   ${LATEST_FLAG} \
   --repo ${REPO} \
   --verify-tag \
   --generate-notes \
   --notes-start-tag "${PREVIOUS_TAG}"
