#!/bin/bash
set -e

# Creates a new copy of the db with user info other than usernames scrubbed out.

if [ $(hostname) = "18xxgames" ]; then
    echo "Don't run this on prod"
    exit 1
fi

set -x

# download and copy the real prod DB
./scripts/db/dump_prod.sh

# load the copy into the local server
./scripts/db/load_from_backup.sh

# scrub the local data
docker-compose exec --env DB_LOG_LEVEL=fatal rack bundle exec ruby -e "load 'scripts/db_scrub.rb'; scrub_all_users!"

# dump the scrubbed data
./scripts/db/dump.sh "db.backup.scrubbed.$(date +"%Y%m%d.%H%M").gz"
