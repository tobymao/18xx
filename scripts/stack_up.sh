#!/bin/bash

# start the stack locally, either in production mode or development mode; this
# is best invoked via `make dev_up` or `make prod_up,` rather than direct
# invocation

TARGET_ENV=$1
if [ "${TARGET_ENV}" = "production" ]; then
    . scripts/get_image_tags.sh
    COMPOSE_FILE=docker-compose.prod.yml

elif [ "${TARGET_ENV}" = "development" ]; then
    COMPOSE_FILE=docker-compose.dev.yml

else
    echo "Must specify a target environment of either \"development\" or \"production\"; got \"${TARGET_ENV}\""
    exit 1
fi

docker stack deploy --prune -c docker-compose.yml -c ${COMPOSE_FILE} 18xx
