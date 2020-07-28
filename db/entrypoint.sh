#!/bin/bash

# Adapted from https://github.com/sudo-bmitch/jenkins-docker/blob/main/entrypoint.sh
# Originally pointed out here: https://stackoverflow.com/a/44683248

# Expectation: /var/lib/postgresql/data has been mounted into the container 
# from the Docker Host

set -x

# configure script to go back to original postgres image's entrypoint
set -- /docker-entrypoint.sh "$@"

# match db user's uid to that of /var/lib/postgresql/data
if [ "$(id -u)" = "0" ]; then
  # get uid of mounted data dir
  CONTAINER_RUNNER_UID=`ls -nud /var/lib/postgresql/data | cut -f3 -d' '`

  if [ -z "$(getent passwd db)" ]; then
    # Create user and group matching the UID found on /var/lib/postgresql/data
    useradd --uid $CONTAINER_RUNNER_UID --user-group --create-home --home-dir /home/db db
  fi

  # Make sure db can write to these
  chown db:db /var/lib/postgresql/data && \
  chown db:db /var/run/postgresql

  # Add call to gosu (installed by postgres 12.2 image) 
  # to drop from root user to db user when running original entrypoint
  set -- gosu db "$@"
fi

# replace the current pid 1 with original entrypoint or CMD
exec "$@"
