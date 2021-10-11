#!/bin/bash

bad_vars_msg=""

if [ -z "${DATABASE_URL}" ]; then
    bad_vars_msg="${bad_vars_msg}\n- DATABASE_URL"
fi

if [ -z "${ELASTIC_KEY}" ]; then
    bad_vars_msg="${bad_vars_msg}\n- ELASTIC_KEY"
fi

if [ -z "${POSTGRES_USER}" ]; then
    bad_vars_msg="${bad_vars_msg}\n- POSTGRES_USER"
fi

if [ -z "${POSTGRES_PASSWORD}" ]; then
    bad_vars_msg="${bad_vars_msg}\n- POSTGRES_PASSWORD"
fi

if [ -z "${POSTGRES_DB}" ]; then
    bad_vars_msg="${bad_vars_msg}\n- POSTGRES_DB"
fi

if [ -z "${NEW_RELIC_LICENSE_KEY}" ]; then
    bad_vars_msg="${bad_vars_msg}\n- NEW_RELIC_LICENSE_KEY"
fi

if [ -z "${SLACK_WEBHOOK_URL}" ]; then
    bad_vars_msg="${bad_vars_msg}\n- SLACK_WEBHOOK_URL"
fi

if [ ! -z "${bad_vars_msg}" ]; then
    echo "ERROR: no values found for the following environment variables:"
    echo -e "${bad_vars_msg}"
    exit 1
fi
