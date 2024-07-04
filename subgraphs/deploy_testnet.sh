#!/bin/bash

# Check if .env file exists
ENV_FILE="../.env"
if [ ! -f $ENV_FILE ]; then
  echo ".env file not found in the parent directory!"
  exit 1
fi

export $(grep -v '^#' $ENV_FILE | xargs)

SUBGRAPH_NETWORK=polygon-amoy
SUBGRAPH_BLOCK=6486436
SUBGRAPH_AUTID_ADDRESS=0xDf8610E895094Be04A206bE2eBa16B8749799499
SUBGRAPH_HUB_REGISTRY_ADDRESS=0x5f57801530CeF74703424cc5FaB09bF4F003E181

npm run codegen && npm run build && graph deploy $TESTNET_SUBGRAPH_NAME \
  --version-label $TESTNET_SUBGRAPH_VERSION \
  --node $TESTNET_SUBGRAPH_NODE \
  --ipfs $TESTNET_SUBGRAPH_IPFS \
  --deploy-key $TESTNET_SUBGRAPH_DEPLOY_KEY