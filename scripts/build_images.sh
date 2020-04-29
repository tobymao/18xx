#!/bin/bash

already_built=""
new_imgs=""

# wrapper around docker build; if built image already exists with a different
# tag, delete the new tag so that `docker stack deploy` doesn't need to update
# anything
## expects args '-t TAG' first, then other valid `docker build` args in any order
function build() {
    # `docker build --quiet` outputs only the final image, in long form:
    # "sha:VERY_LONG_IMAGE_ID"
    img_id=$(docker build --quiet "$@" | cut -c 8-19)
    new_tag=$(echo "${2}" | cut -d ':' -f 2)

    tags=$(docker images | grep "${img_id}" | awk '{print $2}')

    matching_tags=""

    if [ "${new_tag}" != "dev" ]; then
        for tag in $tags; do
            if [ "${tag}" != "${new_tag}" ] && (git cat-file -e $tag 2> /dev/null); then
                matching_tags+=" $tag"
            fi
        done
    fi

    matches=$(echo $matching_tags | wc -w)

    # another docker image tag has the same id, so the changes up to this commit
    # had no changes for this image; untag it
    if [ "${matches}" -gt "0" ]; then
        docker rmi $2 > /dev/null
        already_built+="- ${2} (image id: ${img_id}; matching tags:${matching_tags})\n"
    else
        new_imgs+="- ${2}\n"
    fi
}

# development or production
TARGET_ENV=$1
if [ "${TARGET_ENV}" = "production" ]; then
    if [ $(git status --porcelain | wc -l) -gt "0" ]; then
        echo "Found uncommited changes. Cannot build production images."
        exit 1
    fi
    COMMIT=$(git rev-parse --verify HEAD --short)

    TAG=${COMMIT}
    build -t 18xx_nginx:${TAG} ./nginx/

elif [ "${TARGET_ENV}" = "development" ]; then
    TAG="dev"

else
    echo "Must specify a target environment of either \"development\" or \"production\"; got \"${TARGET_ENV}\""
    exit 1
fi

build -t 18xx_postgres:${TAG} ./db/
build -t 18xx_rack:${TAG} --build-arg RACK_ENV=${TARGET_ENV} .

if [ ! -z "${new_imgs}" ]; then
    echo -e "Built new tags/images:\n${new_imgs}"
fi

if [ ! -z "${already_built}" ]; then
    echo -e "These new tags were not created:\n${already_built}"
fi
