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

ETHEREUM_ACCOUNT_PWD_FILE = "ethereum-account-pwd-file"
ETHEREUM_ACCOUNT_KEY_FILE = "ethereum-account-key-file"


HOMEDIR="/home/$AZURE_USER"
VMNAME=`hostname`
echo "User: $AZURE_USER"
echo "User home dir: $HOMEDIR"
echo "vmname: $VMNAME"

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
printf "${ETHEREUM_ACCOUNT_KEY}"  >> "ethereum-account-key-file"
printf "${ETHEREUM_ACCOUNT_PWD}"  >> "ethereum-account-pwd-file"
 
geth account import $ETHEREUM_ACCOUNT_KEY --password $ETHEREUM_ACCOUNT_PASSWORD

sh start-private-blockchain.sh 