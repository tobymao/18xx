#!/bin/bash
set +e

if [ $(hostname) = "18xxgames" ]; then
    . scripts/db/env.prod
else
    . scripts/db/env.dev
fi
