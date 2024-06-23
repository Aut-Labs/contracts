#!/bin/bash

# Check if .env file exists
ENV_FILE="../.env"
if [ ! -f $ENV_FILE ]; then
  echo ".env file not found in the parent directory!"
  exit 1
fi

export $(grep -v '^#' $ENV_FILE | xargs)

SUBGRAPH_NETWORK=polygon
SUBGRAPH_BLOCK=57002848
SUBGRAPH_AUTID_ADDRESS="0xA8D2eaa40C7cc0Ed6A6B0e85B50767b82715d7bD"
SUBGRAPH_NOVA_REGISTRY_ADDRESS="0xF3954e1d1152f64592E8E7ECD1c0DCca5f1de427"

npm run codegen && npm run build && graph deploy $MAINNET_SUBGRAPH_NAME \
  --version-label $MAINNET_SUBGRAPH_VERSION \
  --node $MAINNET_SUBGRAPH_NODE \
  --ipfs $MAINNET_SUBGRAPH_IPFS \
  --deploy-key $MAINNET_SUBGRAPH_DEPLOY_KEY