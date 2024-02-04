#!/bin/bash
set -e

# Loads a db.backup.gz file into your actively running local server. Overwrites
# existing DB data.

if [ $(hostname) = "18xxgames" ]; then
    echo "You probably don't want to run this on prod."
    exit 1
fi

. scripts/db/load_env.sh

if [ -z "${1}" ]; then
    DB_FILE=db.backup.gz
else
    DB_FILE="${1}"
fi

set -x

# unzip
gunzip --keep --force ${DB_FILE}
TMP_DB_FILE=${DB_FILE/.gz/}

# restore
docker-compose exec rack rake dev_bounce
docker exec -i 18xx_db_1 pg_restore --clean --username ${DB_USER} --dbname ${DB_NAME} --format tar < ${TMP_DB_FILE}

# remove uncompressed backup
rm --verbose ${TMP_DB_FILE}
