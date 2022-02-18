#!/bin/bash

git clone https://github.com/starkware-libs/cairo-lang.git

cp runner.sh cairo-lang/
cp Dockerfile cairo-lang/Dockerfile.local
rm -rf l1_msg_handler/node_modules
cp -r l1_msg_handler cairo-lang/
cp -r l2_msg_handler cairo-lang/

docker build -f cairo-lang/Dockerfile.local  cairo-lang/ -t cairo-env-local

docker run -it cairo-env-local