#!/bin/bash

# deploy to the prod server; update the code, then build and deploy the new
# images and containers

ssh -l deploy 18xx <<EOF
cd ~/18xx/
git pull
make build_prod
make prod_up
EOF
