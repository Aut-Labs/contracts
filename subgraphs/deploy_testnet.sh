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
SUBGRAPH_AUTID_ADDRESS=0x4767071FBAa11cF74D52F23482ECCDC7e09bf369
SUBGRAPH_NOVA_REGISTRY_ADDRESS=0x35EC5fbE50EB25eCc39a8B7396cb0C44F3f6D617

npm run codegen && npm run build && graph deploy $TESTNET_SUBGRAPH_NAME \
  --version-label $TESTNET_SUBGRAPH_VERSION \
  --node $TESTNET_SUBGRAPH_NODE \
  --ipfs $TESTNET_SUBGRAPH_IPFS \
  --deploy-key $TESTNET_SUBGRAPH_DEPLOY_KEY