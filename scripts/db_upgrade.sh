set -ex

bad_vars_msg=""
if [ -z "${POSTGRES_USER}" ]; then
    bad_vars_msg="${bad_vars_msg}\n- POSTGRES_USER"
fi
if [ -z "${POSTGRES_DB}" ]; then
    bad_vars_msg="${bad_vars_msg}\n- POSTGRES_DB"
fi
if [ ! -z "${bad_vars_msg}" ]; then
    echo "ERROR: no values found for the following environment variables:"
    echo -e "${bad_vars_msg}"
    exit 1
fi

CURRENT_VERSION=UPDATE_ME
NEW_VERSION=UPDATE_ME

DB_BACKUP=~/db.backup-pg${CURRENT_VERSION}
echo DB_BACKUP=$DB_BACKUP

# make sure db/Dockerfile has the expected version
cat db/Dockerfile | grep "FROM postgres:${NEW_VERSION}"

# check version
docker-compose exec db postgres --version | grep ${CURRENT_VERSION}

# bring down server (and containers depending on it) to prevent anything new
# going to the db; don't want anyone losing actions/games that were created
# during the db dump
docker-compose stop rack queue nginx || true

# dump db
pg_dump --host localhost --port 5433 --user ${POSTGRES_USER} --no-password --exclude-table schema_info --exclude-table message_bus --data-only --format t ${POSTGRES_DB} | gzip > ${DB_BACKUP}.gz

# check the backup file
ls -lah ${DB_BACKUP}*

# bring down db
docker-compose stop db

# move data dir for now; can delete after confirming deploy is fine
mv db/data db/data-postgres${CURRENT_VERSION}
mkdir db/data

# rebuild db with updated db/Dockerfile for postgres ${NEW_VERSION}
docker-compose up --detach --build db

# bring up rack and queue first to talk to the new db and set up their tables
docker-compose up --detach --build rack
docker-compose up --detach --build queue

# restore db backup in postgres ${NEW_VERSION}
gunzip -k -f ${DB_BACKUP}.gz
ls -lah ${DB_BACKUP}* # check the backup file
docker exec -i 18xx_db_1 pg_restore -U ${POSTGRES_USER} -d ${POSTGRES_DB} -F t < ${DB_BACKUP}
rm ${DB_BACKUP}

# check version, expecting ${NEW_VERSION}
docker-compose exec db postgres --version | grep ${NEW_VERSION}

# bring up nginx, let users in again
docker-compose up --detach nginx
