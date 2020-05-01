#!/bin/bash

docker-compose run rack rake precompile
scp public/assets/main.js public/assets/main.js.gz deploy@18xx:~/18xx/public/assets/
ssh -l deploy 18xx <<EOF
cd ~/18xx/
git pull
make prod_up_b_d
EOF
