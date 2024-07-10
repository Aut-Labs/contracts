#!/bin/bash

# Check if .env file exists
ENV_FILE="../.env"
if [ ! -f $ENV_FILE ]; then
  echo ".env file not found in the parent directory!"
  exit 1
fi

export $(grep -v '^#' $ENV_FILE | xargs)

SUBGRAPH_NETWORK=polygon-amoy
SUBGRAPH_BLOCK=9318892
SUBGRAPH_AUTID_ADDRESS=0x1A3BCa2603110C119448a498c1CEF06AeeEf0A8a
SUBGRAPH_NOVA_REGISTRY_ADDRESS=0x98363e09Fe3224d660FE0B7A320C2611Dbf19093
SUBGRAPH_DOMAIN_ADDRESS=0xB55E9a7a0eBd21F773187d391ca3015B60d31724

npm run codegen && npm run build && graph deploy $TESTNET_SUBGRAPH_NAME \
  --version-label $TESTNET_SUBGRAPH_VERSION \
  --node $TESTNET_SUBGRAPH_NODE \
  --ipfs $TESTNET_SUBGRAPH_IPFS \
  --deploy-key $TESTNET_SUBGRAPH_DEPLOY_KEY