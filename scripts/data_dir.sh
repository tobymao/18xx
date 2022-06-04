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

umask 0077
mkdir -p db/data

if [[ $1 == 'podman' ]]; then
  db_uid=1000
  mapped_db_uid=$(($(grep "^$USER:" /etc/subuid | cut -d: -f2) - 1 + db_uid))
  find db/data -prune -type d ! -user $mapped_db_uid -exec \
       sudo chown -R $mapped_db_uid:$mapped_db_uid "{}" \;
else
  find db/data -prune -type d -user root -exec \
       sudo chown -R "$USER":"$USER" \;
fi
