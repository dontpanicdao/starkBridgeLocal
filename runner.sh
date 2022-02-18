#!/bin/bash

set -e

curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

nvm install 14.15.0 && nvm use 14.15.0
cd /app/l1_msg_handler; npm i; cd /app

read L1_ADDR <<< $(npx hardhat run l1_msg_handler/scripts/deploy.js | grep -i 'deployed to' | awk '{print $NF}')

root_dir=$(pwd)
package_path=${root_dir}/cairo-lang-$(cat src/starkware/cairo/lang/VERSION).zip
# cairo_source_path=${root_dir}/src/starkware/cairo/lang/package_test/main.cairo

python3.7 -m venv venv

source venv/bin/activate

pip install ${package_path}

starknet-compile ${root_dir}/l2_msg_handler/fact_check.cairo --output main_compiled.json --abi anon_abi.json

read L2_ADDR <<< $(starknet deploy --contract main_compiled.json --inputs ${L1_ADDR} | grep -i 'contract' | awk '{print $NF}')

# TODO: poll starknet tx_status until deploy tx accepted and test functionality