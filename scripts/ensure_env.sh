#!/bin/bash

# Set up $ENV_FILE so that it can be used by docker-compose.yml
#
# Required variables in the $ENV_FILE and current environment are resolved in
# one of four ways:
#   - If a required var is neither in the current environment or $ENV_FILE,
#     inform the user and exit with failure
#
#   - If a required var is in $ENV_FILE, and in the current environment is
#     either unset or has the same value as in $ENV_FILE, nothing to do
#
#   - If a required var is set in the current environment, but is not in
#     $ENV_FILE, add it to the $ENV_FILE
#
#   -If a required var is set in both the current environment and $ENV_FILE, but
#    with different values, allow the user to overwrite the value in $ENV_FILE,
#    or proceed using the value from $ENV_FILE instead of the value from the
#    current environment.
#
# Next, if deploying to "development", check if any of the required variables
# have "production" in their values (and vice versa), warning the user but
# allowing them to proceed if they wish.
#
# Finally, RACK_ENV must be "development" or "production".

# development or production
TARGET_ENV=$1
if [ "${TARGET_ENV}" = "production" ]; then
    ENV_SHORT="prod"
    OTHER_ENV="development"
elif [ "${TARGET_ENV}" = "development" ]; then
    ENV_SHORT="dev"
    OTHER_ENV="production"
else
    echo "Must specify a target environment of either \"development\" or \"production\"; got \"${TARGET_ENV}\""
    exit 1
fi

# the file used by docker-compose.yml
ENV_FILE=.env

# if  env files with -dev and -prod exist, make $ENV_FILE a symlink to the right
# one; if they don't exist, just make sure $ENV_FILE does exist
if [ -f "${ENV_FILE}_dev" ] && [ -f "${ENV_FILE}_prod" ]; then
    rm -f ${ENV_FILE}
    ln -s ${ENV_FILE}_${ENV_SHORT} ${ENV_FILE}
else
    # create $ENV_FILE if it does not exist
    touch ${ENV_FILE}
fi

err_msg=""
error=false

warn_msg=""

# the key environment variables
required_vars=(
    MAIL_GUN_KEY
    POSTGRES_DB
    POSTGRES_PASSWORD
    POSTGRES_USER
    RACK_ENV
)
DEFAULT_MAIL_GUN_KEY=super_secret_mail_key
DEFAULT_POSTGRES_DB=18xx_development
DEFAULT_POSTGRES_PASSWORD=super_secret_dev_password
DEFAULT_POSTGRES_USER=18xx
DEFAULT_RACK_ENV=development

#     - if in environment, and in $ENV_FILE, compare the values
#         - if different, prompt user to overwrite $ENV_FILE (make it clear value
#           $ENV_FILE will be used)
#         - if same, carry on

for item in ${required_vars[*]}
do
    # value from user's environment
    env_val="${!item}"

    # value from $ENV_FILE file
    saved_val=$(grep -E "^${item}=.*" ${ENV_FILE} 2> /dev/null | cut -d '=' -f 2)

    # neither is defined, user must define
    if [ -z "${env_val}${saved_val}" ]; then
        default_var_name="DEFAULT_${item}"
        echo "${item}=${!default_var_name}" >> ${ENV_FILE}
        err_msg+="- ${item}\n"

    # defined in environment but not in file
    elif [ -z "${saved_val}" ]; then
        echo "Adding ${item}=${env_val} to ${ENV_FILE}..."
        echo "${item}=${env_val}" >> ${ENV_FILE}

    # defined in file but not in environment
    elif [ -z "${env_val}" ]; then
        # add to environment for this script
        declare "${item}=${saved_val}"

    # defined in both, but with different values
    elif [ "${env_val}" != "${saved_val}" ]; then
        echo "${item} has value \"${env_val}\" in environment, but \"${saved_val}\" in ${ENV_FILE}"
        read -p "Overwrite value in ${ENV_FILE} with \"${env_val}\" and proceed? [y/N] " overwrite
        if [[ "${overwrite}" =~ ^[yY].*$ ]]; then
            sed -i s/${item}=.*/${item}=${env_val}/ $ENV_FILE
        else
            read -p "Proceed with deployment using ${item}=${saved_val}? [y/N] " proceed
            if [[ "${proceed}" =~ ^[yY].*$ ]]; then
                declare "${item}=${saved_val}"
            else
                echo "Resolve the difference between your environment and ${ENV_FILE} and try again."
                exit 1
            fi
        fi
    fi

    final_value="${!item}"

    if (echo "${final_value}" | grep "${OTHER_ENV}" > /dev/null); then
        warn_msg+="- ${item}=${final_value}\n"
    fi
done

if [ ! -z "${err_msg}" ]; then
    error=true
    echo -e "ERROR: no values found for the following environment variables:\n${err_msg}"
    echo -e "Default values for the above variables have been added to ${ENV_FILE}\n"
    echo -e "Inspect the file and change any values you wish, then try again.\n"
fi

if [ ! -z "${warn_msg}" ]; then
    echo "WARNING: Deploying to target environment \"${TARGET_ENV}\", but found:"
    echo -e "${warn_msg}"

    if [ "${error}" != "true" ]; then
        read -p 'Deploy anyway? [y/N] ' deploy_anyway
        if [[ $deploy_anyway =~ ^[yY].*$ ]]; then
            echo "Continuing..."
        else
            echo "Exiting.\n"
            error=true
        fi
    fi
fi

if [ "${RACK_ENV}" != "production" ] && [ "${RACK_ENV}" != "development" ]; then
    echo "ERROR: RACK_ENV must be one of \"production\" or \"development\"; found \"${RACK_ENV}\"\n"
    error=true
fi

if [ "${error}" = "true" ]; then
    exit 1
fi
