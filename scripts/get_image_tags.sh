#!/bin/bash

# find the commit tags for the different services in the stack, and export env
# vars used in docker-compose.prod.yml

function get_var() {
    image_name=$1

    tags=$(docker images | grep $image_name | grep -v '<none>' | awk '{print $2}')

    # `docker images` output is sorted by time, so the first hit will be the
    # most recently built image
    for tag in $tags; do
        # return early if the tag on the docker image matches a git commit
        # (technically it will match other git refs as well)
        if (git cat-file -e ${tag} 2> /dev/null); then
            echo $tag
            return 0
        fi
    done

    echo "Didn't find any matching tags for ${1}. Try building with 'make build_prod'"
    exit 1
}

export NGINX_TAG=$(get_var 18xx_nginx)
export POSTGRES_TAG=$(get_var 18xx_postgres)
export RACK_TAG=$(get_var 18xx_rack)
