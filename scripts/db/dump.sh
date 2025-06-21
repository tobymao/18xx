#!/bin/bash
set -e

# Create db.backup.gz, a copy of the current database. This can be run locally
# or directly on prod.

. scripts/db/load_env.sh

if [ -z "${1}" ]; then
    DB_FILE=db.backup.gz
else
    DB_FILE="${1}"
fi

DB_CONTAINER_NAME=$(docker ps --filter name="db.?1" --format '{{.Names}}')

# create gzipped backup file in docker container
docker exec -i ${DB_CONTAINER_NAME} bash -c "pg_dump --host localhost --port ${DB_PORT} --user ${DB_USER} --no-password --exclude-table schema_info --exclude-table message_bus --data-only --format t ${DB_NAME} | gzip > /home/db/${DB_FILE}"

# copy backup to host
docker cp ${DB_CONTAINER_NAME}:/home/db/${DB_FILE} .

# remove backup from docker container
docker exec -i ${DB_CONTAINER_NAME} rm -v /home/db/${DB_FILE}
