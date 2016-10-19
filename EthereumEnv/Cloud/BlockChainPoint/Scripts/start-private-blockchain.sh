#!/bin/bash
BASH_SCRIPT="${0}"
ETHEREUM_NETWORK_ID="${1}"
BLOCKCHAIN_DIR="${2}"
ETHEREUM_ACCOUNT_ADDRESS="${3}"
ETHEREUM_ACCOUNT_PWD_FILE="${4}"
ETHEREUM_NODE_IDENTITY="${5}"

#geth --maxpeers 10 --rpc --rpcaddr "0.0.0.0" --rpcport "8545" --rpccorsdomain "*" --datadir "${BLOCKCHAIN_DIR}" --ipcapi "admin,db,eth,debug,miner,net,shh,txpool,personal,web3" --rpcapi "db,eth,net,web3" --networkid "${ETHEREUM_NETWORK_ID}" --unlock "${ETHEREUM_ACCOUNT_ADDRESS}" --password "${ETHEREUM_ACCOUNT_PWD_FILE}" --mine
#geth --maxpeers 10 --rpc --rpcaddr "0.0.0.0" --rpcport "8545" --rpccorsdomain "*" --ipcapi "admin,db,eth,debug,miner,net,shh,txpool,personal,web3" --rpcapi "db,eth,net,web3" --networkid "${ETHEREUM_NETWORK_ID}" --unlock "${ETHEREUM_ACCOUNT_ADDRESS}" --password "${ETHEREUM_ACCOUNT_PWD_FILE}" --mine
geth --maxpeers 10 --rpc --rpcaddr "0.0.0.0" --rpcport "8545" --rpccorsdomain "*" --datadir "${BLOCKCHAIN_DIR}" --ipcapi "admin,db,eth,debug,miner,net,shh,txpool,personal,web3" --rpcapi "db,eth,net,web3" --networkid "${ETHEREUM_NETWORK_ID}" --identity "${ETHEREUM_NODE_IDENTITY=}" --unlock "${ETHEREUM_ACCOUNT_ADDRESS}" --password "${ETHEREUM_ACCOUNT_PWD_FILE}" --nodiscover
