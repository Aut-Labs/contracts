#!/bin/bash

# Check if .env file exists
ENV_FILE="../.env"
if [ ! -f $ENV_FILE ]; then
  echo ".env file not found in the parent directory!"
  exit 1
fi

export $(grep -v '^#' $ENV_FILE | xargs)

SUBGRAPH_NETWORK=polygon-amoy
SUBGRAPH_BLOCK=9316447
SUBGRAPH_AUTID_ADDRESS=0x532d54aF60149CD03016eF6735092cAe10D85192
SUBGRAPH_NOVA_REGISTRY_ADDRESS=0x238131334e9E1Fb2920DA3B914E40DceCA4F584c
SUBGRAPH_DOMAIN_ADDRESS=0xFde95B1f1f68933f439832fFA3C4c27426Df59d8

npm run codegen && npm run build && graph deploy $TESTNET_SUBGRAPH_NAME \
  --version-label $TESTNET_SUBGRAPH_VERSION \
  --node $TESTNET_SUBGRAPH_NODE \
  --ipfs $TESTNET_SUBGRAPH_IPFS \
  --deploy-key $TESTNET_SUBGRAPH_DEPLOY_KEY