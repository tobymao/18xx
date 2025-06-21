#!/bin/bash

# Creates a git tag with the timestamp from version.json

# the container engine, e.g., 'podman' or 'docker compose'
CONTAINER_COMPOSE="${@}"

TAG=$(${CONTAINER_COMPOSE} exec rack bundle exec ruby scripts/tag_name.rb)
if [ -z "${TAG}" ]; then
    echo "Failed to get tag name. CONTAINER_COMPOSE=\"${CONTAINER_COMPOSE}\""
    exit 1
fi

git tag "${TAG}"

if git push origin "refs/tags/${TAG}"; then
   echo "Created and pushed release tag \"${TAG}\""
else
   echo "Failed to push release tag \"${TAG}\""
fi
