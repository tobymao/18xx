#!/bin/bash

# Creates a git tag with the timestamp from version.json

# the container engine, e.g., 'podman' or 'docker compose'
CONTAINER_COMPOSE="${@}"

TAG=$($CONTAINER_COMPOSE exec rack bundle exec ruby scripts/tag_name.rb)

git tag $TAG
git push origin refs/tags/$TAG
