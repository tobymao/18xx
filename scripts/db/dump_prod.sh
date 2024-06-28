#!/bin/bash
set -e

# Create a backup of the DB on the prod server and copy it to your
# machine, using dump.sh on the prod server.

if [ $(hostname) = "18xxgames" ]; then
    echo "Don't run this on prod"
    exit 1
fi

. scripts/db/load_env.sh

if [ -z "${1}" ]; then
    DB_FILE=db.backup.gz
else
    DB_FILE="${1}"
fi

ssh 18xx "bash -c \"cd ~/18xx; ./scripts/db/dump.sh ${DB_FILE}; mv ${DB_FILE} ~/${DB_FILE}\""

# download
scp deploy@18xx:~/${DB_FILE} .
