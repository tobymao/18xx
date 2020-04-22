#!/bin/bash

ssh -l deploy 18xx <<EOF
cd ~/18xx/
git pull
make prod_up_b_d
EOF
