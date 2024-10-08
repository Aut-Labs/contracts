#!/bin/bash

# Check if .env file exists
ENV_FILE="../.env"
if [ ! -f $ENV_FILE ]; then
  echo ".env file not found in the parent directory!"
  exit 1
fi

export $(grep -v '^#' $ENV_FILE | xargs)

npm run codegen && npm run build && graph deploy $TESTNET_SUBGRAPH_NAME \
  --version-label $TESTNET_SUBGRAPH_VERSION \
  --node $TESTNET_SUBGRAPH_NODE \
  --ipfs $TESTNET_SUBGRAPH_IPFS \
  --deploy-key $TESTNET_SUBGRAPH_DEPLOY_KEY