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

#####################
# setup the Azure CLI
#####################
time sudo npm install azure-cli -g
time sudo update-alternatives --install /usr/bin/node nodejs /usr/bin/nodejs 100

####################
# Setup Geth
####################
time sudo apt-get -y git
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

# Fetch Genesis and Private Key
cd $HOMEDIR
wget https://raw.githubusercontent.com/DXFrance/BlockchainPoint/master/EthereumEnv/Cloud/BlockChainPoint/Genesis/genesis.json
wget https://raw.githubusercontent.com/DXFrance/BlockchainPoint/master/EthereumEnv/Cloud/BlockChainPoint/Scripts/start-private-blockchain.sh

date
geth init genesis.json
echo "completed geth install $$"

# configuration
printf "${ETHEREUM_ACCOUNT_KEY}" >> "${ETHEREUM_ACCOUNT_KEY_FILE}"
printf "${ETHEREUM_ACCOUNT_PWD}" >> "${ETHEREUM_ACCOUNT_PWD_FILE}"
 
geth --password "${ETHEREUM_ACCOUNT_PASSWORD}" --datadir "${BLOCKCHAIN_DIR}" account import "${ETHEREUM_ACCOUNT_KEY_FILE}" 

echo "===== Prefunded Etehreum Account imported =====";

#start blockchain

#sh "$GETH_START_SCRIPT" "$ETHEREUM_NETWORK_ID" </dev/null >"$GETH_LOG_FILE_PATH" 2>&1 &
sh "${GETH_START_SCRIPT}" "${ETHEREUM_NETWORK_ID}" "${BLOCKCHAIN_DIR}" "${ETHEREUM_ACCOUNT_ADDRESS}" "${ETHEREUM_ACCOUNT_PWD_FILE}" </dev/null 2>&1 &

echo "===== Started geth node =====";