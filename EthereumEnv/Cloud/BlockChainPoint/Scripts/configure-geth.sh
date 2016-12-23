#!/bin/bash

function usage()
{
    echo "INFO:"
    echo "Usage:...."
}

function error_log()
{
    if [ "$?" != "0" ]; then
        log "$1"
        log "Deployment ends with an error" "1"
        exit 1
    fi
}

function log()
{
  mess="$(hostname): $1"
  logger -t "${BASH_SCRIPT}" "${mess}"
}

function install_prerequisites()
{
    log "Update System ..."
    until apt-get --yes update
    do
      log "Lock detected on apt-get while install Try again..."
      sleep 2
    done

    log "Install software-properties-common ..."
	until apt-get --yes install software-properties-common build-essential libssl-dev libffi-dev python-dev > /dev/null 2>&1
    do
      log "Lock detected on apt-get while install Try again..."
      sleep 2
    done

    log "Update System ..."
    until apt-get --yes update
    do
      log "Lock detected on apt-get while install Try again..."
      sleep 2
    done

    log "Install git ..."
    until apt-get --yes install git > /dev/null 2>&1
    do
      log "Lock detected on apt-get while install Try again..."
      sleep 2
    done

	log "Update System ..."
    until apt-get --yes update
    do
      log "Lock detected on apt-get while install Try again..."
      sleep 2
    done

	log "Install npm ..."
    until apt-get --yes install npm > /dev/null 2>&1
    do
      log "Lock detected on apt-get while install Try again..."
      sleep 2
    done

    log "Install node ..."
    until curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash - > /dev/null 2>&1
    do
      log "Lock detected on curl while install Try again..."
      sleep 2
    done

    until sudo apt-get install -y nodejs > /dev/null 2>&1
    do
      log "Lock detected on apt-get install -y nodejs while install Try again..."
      sleep 2
    done


	#log "Install azure-cli ..."
	#npm install azure-cli -g > /dev/null 2>&1
	#update-alternatives --install /usr/bin/node nodejs /usr/bin/nodejs 100

}


# print commands and arguments as they are executed
set -x

echo "initializing geth installation"
usage
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
ETHEREUM_MINING_NODES_NUMBER="${6}"
ETHEREUM_NODE_IDENTITY="${7}"
ETHEREUM_NODE_NUMBER="${8}"

HOMEDIR="/home/$AZURE_USER"
VMNAME=`hostname`
ETHEREUM_ACCOUNT_PWD_FILE="$HOMEDIR/ethereum-account-pwd-file"
ETHEREUM_ACCOUNT_KEY_FILE="$HOMEDIR/ethereum-account-key-file"
GETH_LOG_FILE_PATH="$HOMEDIR/blockchain.log"
GETH_START_SCRIPT="$HOMEDIR/start-private-blockchain.sh"
BLOCKCHAIN_DIR="chains/hackademy"
ETHEREUM_STATS_FILE="configure-ethstats.sh"
ETHEREUM_NETSTATS_DIR="eth-netstats"
ETHEREUM_NETINTELLIGENCE_DIR="eth-net-intelligence-api"

echo "User: $AZURE_USER"
echo "User home dir: $HOMEDIR"
echo "vmname: $VMNAME"
echo "ETHEREUM_ACCOUNT_PWD: $ETHEREUM_ACCOUNT_PWD"
echo "ETHEREUM_ACCOUNT_KEY: $ETHEREUM_ACCOUNT_PWD_FILE"
echo "ETHEREUM_NETWORK_ID: $ETHEREUM_NETWORK_ID"
echo "ETHEREUM_ACCOUNT_PWD_FILE: $ETHEREUM_ACCOUNT_PWD_FILE"
echo "ETHEREUM_ACCOUNT_KEY_FILE: $ETHEREUM_ACCOUNT_KEY_FILE"
echo "GETH_LOG_FILE_PATH: $GETH_LOG_FILE_PATH"
echo "ETHEREUM_MINING_NODES_NUMBER: $ETHEREUM_MINING_NODES_NUMBER"
echo "ETHEREUM_NODE_IDENTITY: $ETHEREUM_NODE_IDENTITY"
echo "ETHEREUM_NODE_NUMBER: $ETHEREUM_NODE_NUMBER"

cd $HOMEDIR

install_prerequisites


####################
# Setup Geth
####################
add-apt-repository -y ppa:ethereum/ethereum
apt-get update
apt-get install -y ethereum  > /dev/null 2>&1

####################
# Install sol compiler
####################
add-apt-repository ppa:ethereum/ethereum -y
apt-get update
apt-get install solc -y  > /dev/null 2>&1


# Fetch Genesis and Private Key
wget https://raw.githubusercontent.com/DXFrance/BlockchainPoint/master/EthereumEnv/Cloud/BlockChainPoint/Genesis/genesis.json
wget https://raw.githubusercontent.com/DXFrance/BlockchainPoint/master/EthereumEnv/Cloud/BlockChainPoint/Scripts/start-private-blockchain.sh
wget https://raw.githubusercontent.com/DXFrance/BlockchainPoint/master/EthereumEnv/Cloud/BlockChainPoint/Scripts/configure-ethstats.sh

date
geth --datadir "${BLOCKCHAIN_DIR}" init genesis.json
echo "completed geth install $$"

# configuration
printf "${ETHEREUM_ACCOUNT_KEY}" >> "${ETHEREUM_ACCOUNT_KEY_FILE}"
printf "${ETHEREUM_ACCOUNT_PWD}" >> "${ETHEREUM_ACCOUNT_PWD_FILE}"
 
geth --password "${ETHEREUM_ACCOUNT_PWD_FILE}" --datadir "${BLOCKCHAIN_DIR}" account import "${ETHEREUM_ACCOUNT_KEY_FILE}" 
#geth --password "${ETHEREUM_ACCOUNT_PWD_FILE}" account import "${ETHEREUM_ACCOUNT_KEY_FILE}" 

echo "===== Prefunded Etehreum Account imported =====";

#start blockchain

#sh "$GETH_START_SCRIPT" "$ETHEREUM_NETWORK_ID" </dev/null >"$GETH_LOG_FILE_PATH" 2>&1 &
bash "${GETH_START_SCRIPT}" "${ETHEREUM_NETWORK_ID}" "${BLOCKCHAIN_DIR}" "${ETHEREUM_ACCOUNT_ADDRESS}" "${ETHEREUM_ACCOUNT_PWD_FILE}"  "${ETHEREUM_NODE_IDENTITY}"  </dev/null 2>&1 &

echo "===== Started geth node =====";


if [ $ETHEREUM_NODE_NUMBER -eq 0 ]; then

	git clone https://github.com/cubedro/eth-netstats
	cd "$ETHEREUM_NETSTATS_DIR"
	npm install > /dev/null 2>&1
	npm install -g grunt-cli > /dev/null 2>&1
	grunt all > /dev/null 2>&1
	#WS_SECRET="eth-net-stats-has-a-secret" npm start
	cd ..

	cp "$HOMEDIR/$ETHEREUM_STATS_FILE" "$HOMEDIR/$ETHEREUM_NETINTELLIGENCE_DIR/$ETHEREUM_STATS_FILE" 
	#https://ethereum.gitbooks.io/frontier-guide/content/netstats.html
	git clone https://github.com/cubedro/eth-net-intelligence-api
	cd "$ETHEREUM_NETINTELLIGENCE_DIR"
	npm install > /dev/null 2>&1
	npm install -g pm2 > /dev/null 2>&1

	#https://github.com/ethereum/go-ethereum/wiki/Setting-up-monitoring-on-local-cluster
	#git clone https://github.com/ethersphere/eth-utils.git

	bash "./../$ETHEREUM_STATS_FILE" "$ETHEREUM_MINING_NODES_NUMBER" "$VMNAME" "http://localhost:3000" "eth-net-stats-has-a-secret" > app.json

	cd ..
	#after udpate of the app.json
	#pm2 start app.json

fi
