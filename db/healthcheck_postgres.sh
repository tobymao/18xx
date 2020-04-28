#!/bin/bash

set -e

pg_isready

psql --username=${POSTGRES_USER} ${POSTGRES_DB} --list | grep ${POSTGRES_DB}
