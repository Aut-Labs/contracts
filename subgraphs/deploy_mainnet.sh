#!/bin/bash

# Check if .env file exists
ENV_FILE="../.env"
if [ ! -f $ENV_FILE ]; then
  echo ".env file not found in the parent directory!"
  exit 1
fi

export $(grep -v '^#' $ENV_FILE | xargs)

SUBGRAPH_NETWORK=matic
SUBGRAPH_BLOCK=59244446
SUBGRAPH_AUTID_ADDRESS=0x2AD2B856137F2d9c352b427eC5f4F3f816f8eA4c
SUBGRAPH_NOVA_REGISTRY_ADDRESS=0x9854056CEE6379E1ac27ABecC95b69CF9aeaB7B9
SUBGRAPH_DOMAIN_ADDRESS=0x997CC06eE3fFA0A196478F15A54E0f2c42d8Ee68

npm run codegen && npm run build && graph deploy $MAINNET_SUBGRAPH_NAME \
  --version-label $MAINNET_SUBGRAPH_VERSION \
  --node $MAINNET_SUBGRAPH_NODE \
  --ipfs $MAINNET_SUBGRAPH_IPFS \
  --deploy-key $MAINNET_SUBGRAPH_DEPLOY_KEY