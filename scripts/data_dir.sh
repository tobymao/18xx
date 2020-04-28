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

TARGET_ENV=$1
if [ "${TARGET_ENV}" = "production" ]; then
    ENV_SHORT="prod"
elif [ "${TARGET_ENV}" = "development" ]; then
    ENV_SHORT="dev"
else
    echo "Must specify a target environment of either \"development\" or \"production\"; got \"${TARGET_ENV}\""
    exit 1
fi

# manage db/data as a symlink for seamlessly handling dev and prod setup
if [ -L db/data ]; then
    link_target=$(readlink -f db/data)
    if [[ ! "${link_target}" =~ "${ENV_SHORT}" ]]; then
        echo "ERROR: Deploying to ${TARGET_ENV} but db/data points to ${link_target}"
        read -p "Fix link and continue? NOT RECOMMENDED if it is already mounted to a running container. [y/N] " fix
        if [[ "${fix}" =~ ^[yY].*$ ]]; then
            rm db/data
            ln -f -s "data_${ENV_SHORT}" db/data
        else
            exit 1
        fi
    fi

elif [ -d "db/data_dev" ] && [ -d "db/data_prod" ]; then
    ln -s "data_${ENV_SHORT}" db/data

else
    mkdir -p db/data

    [ $(ls -l db/ | grep data | awk '{print $3}' | head -1) = 'root' ] && sudo chown -R $USER:$USER db/data || true

fi
