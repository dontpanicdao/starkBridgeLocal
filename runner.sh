#!/bin/bash

set -e

bash /app/build.sh
cd /app/build/Release
make all -j8

curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash

npm -g config set user root

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

nvm install 14.15.0 && nvm use 14.15.0
cd /app/l1_msg_handler; npm i; cd /app

# TODO: user pure ganache cli deploy like cairo-test sweet
read L1_ADDR <<< $(npx hardhat run --network localhost l1_msg_handler/scripts/deploy.js | grep -i 'deployed to' | awk '{print $NF}')

root_dir=$(pwd)
package_path=${root_dir}/cairo-lang-$(cat src/starkware/cairo/lang/VERSION).zip
# cairo_source_path=${root_dir}/src/starkware/cairo/lang/package_test/main.cairo

python3.7 -m venv venv

source venv/bin/activatex

pip install ${package_path} cairo-nile starknet-devnet

nile node &

nile compile l2_msg_handler/fact_check.cairo

read L2_ADDR <<< $(nile deploy fact_check --alias fact_check ${L1_ADDR} | grep -i 'successfully' | awk '{print $NF}')

# TODO: poll starknet tx_status until deploy tx accepted and test functionality
nile invoke fact_check fact_check_sharp 2754806153357301156380357983574496185342034785016738734224771556919270737441