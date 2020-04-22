#!/bin/bash

# ensure that ./db/data exists and is not owned by root
#
# - ./db/data/ is need for the postgres container
#
# - if it does not exist when docker-compose tries to create the container,
#   docker-compose will create the dir, and it will be owned by root, preventing
#   the postgres container from working
#
# - postgres requires the data dir to be empty when it initializes, so if a file
#   like ./db/data/.keep is checked into the repo, it will error out instead of
#   initializing properly

mkdir -p db/data

[ $(stat -c '%U' db/data) = 'root' ] && sudo chown -R $USER:$USER db/data || true
