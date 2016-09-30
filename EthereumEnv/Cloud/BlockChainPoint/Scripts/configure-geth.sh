#!/bin/bash

# print commands and arguments as they are executed
set -x

echo "initializing geth installation"
date
ps axjf

CWD="$(cd -P -- "$(dirname -- "$0")" && pwd -P)"

log "CustomScript Directory is ${CWD}" "N"

#############
# Parameters
#############

BASH_SCRIPT="${0}"
AZURE_USER="${1}"
ETHEREUM_ACCOUNT_PWD="${2}"
ETHEREUM_ACCOUNT_KEY="${3}"
ETHEREUM_NETWORK_ID="${4}"
ETHEREUM_ACCOUNT_ADDRESS="${5}"
ETHEREUM_NODE_IDENTITY="${6}"

HOMEDIR="/home/$AZURE_USER"
VMNAME=`hostname`
ETHEREUM_ACCOUNT_PWD_FILE="$HOMEDIR/ethereum-account-pwd-file"
ETHEREUM_ACCOUNT_KEY_FILE="$HOMEDIR/ethereum-account-key-file"
GETH_LOG_FILE_PATH="$HOMEDIR/blockchain.log"
GETH_START_SCRIPT="$HOMEDIR/start-private-blockchain.sh"
BLOCKCHAIN_DIR="chains/hackademy"

echo "User: $AZURE_USER"
echo "User home dir: $HOMEDIR"
echo "vmname: $VMNAME"
echo "ETHEREUM_ACCOUNT_PWD: $ETHEREUM_ACCOUNT_PWD"
echo "ETHEREUM_ACCOUNT_KEY: $ETHEREUM_ACCOUNT_PWD_FILE"
echo "ETHEREUM_NETWORK_ID: $ETHEREUM_NETWORK_ID"
echo "ETHEREUM_ACCOUNT_PWD_FILE: $ETHEREUM_ACCOUNT_PWD_FILE"
echo "ETHEREUM_ACCOUNT_KEY_FILE: $ETHEREUM_ACCOUNT_KEY_FILE"
echo "GETH_LOG_FILE_PATH: $GETH_LOG_FILE_PATH"
echo "ETHEREUM_NODE_IDENTITY: $ETHEREUM_NODE_IDENTITY"

#####################
# setup the Azure CLI
#####################
time sudo npm install azure-cli -g
time sudo update-alternatives --install /usr/bin/node nodejs /usr/bin/nodejs 100

####################
# Setup Geth
####################
time sudo apt-get --yes install git
time sudo apt-get install -y software-properties-common
time sudo add-apt-repository -y ppa:ethereum/ethereum
time sudo apt-get update
time sudo apt-get install -y ethereum

####################
# Install sol compiler
####################
time sudo add-apt-repository ppa:ethereum/ethereum -y
time sudo apt-get update
time sudo apt-get install solc -y

time sudo apt-get install nodejs-legacy

# Fetch Genesis and Private Key
cd $HOMEDIR
wget https://raw.githubusercontent.com/DXFrance/BlockchainPoint/master/EthereumEnv/Cloud/BlockChainPoint/Genesis/genesis.json
wget https://raw.githubusercontent.com/DXFrance/BlockchainPoint/master/EthereumEnv/Cloud/BlockChainPoint/Scripts/start-private-blockchain.sh

#https://github.com/ethereum/go-ethereum/wiki/Setting-up-monitoring-on-local-cluster
git clone https://github.com/ethersphere/eth-utils.git
cd eth-utils
npm install

git clone https://github.com/cubedro/eth-netstats
cd eth-netstats
npm install
WS_SECRET="eth-net-stats-has-a-secret" npm start

#https://ethereum.gitbooks.io/frontier-guide/content/netstats.html

git clone https://github.com/cubedro/eth-net-intelligence-api
cd eth-net-intelligence-api
npm install
sudo npm install -g pm2

#after udpate of the app.json
#pm2 start app.json

date
geth init genesis.json
echo "completed geth install $$"

# configuration
printf "${ETHEREUM_ACCOUNT_KEY}" >> "${ETHEREUM_ACCOUNT_KEY_FILE}"
printf "${ETHEREUM_ACCOUNT_PWD}" >> "${ETHEREUM_ACCOUNT_PWD_FILE}"
 
#geth --password "${ETHEREUM_ACCOUNT_PWD_FILE}" --datadir "${BLOCKCHAIN_DIR}" account import "${ETHEREUM_ACCOUNT_KEY_FILE}" 
geth --password "${ETHEREUM_ACCOUNT_PWD_FILE}" account import "${ETHEREUM_ACCOUNT_KEY_FILE}" 

echo "===== Prefunded Etehreum Account imported =====";

#start blockchain

#sh "$GETH_START_SCRIPT" "$ETHEREUM_NETWORK_ID" </dev/null >"$GETH_LOG_FILE_PATH" 2>&1 &
sh "${GETH_START_SCRIPT}" "${ETHEREUM_NETWORK_ID}" "${BLOCKCHAIN_DIR}" "${ETHEREUM_ACCOUNT_ADDRESS}" "${ETHEREUM_ACCOUNT_PWD_FILE}"  "${ETHEREUM_NODE_IDENTITY}"  </dev/null 2>&1 &

echo "===== Started geth node =====";