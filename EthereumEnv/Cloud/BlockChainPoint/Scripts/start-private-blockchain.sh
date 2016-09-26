#!/bin/bash
ETHEREUM_NETWORK_ID="${1}"

geth --maxpeers 0 --networkid "{$ETHEREUM_NETWORK_ID}" --rpc --rpccorsdomain "*" 