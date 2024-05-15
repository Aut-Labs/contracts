#!/bin/bash

# Check if .env file exists
ENV_FILE="../.env"
if [ ! -f $ENV_FILE ]; then
  echo ".env file not found in the parent directory!"
  exit 1
fi

export $(grep -v '^#' $ENV_FILE | xargs)

forge script ./DeployAll.s.sol --rpc-url $MAINNET_RPC_URL --private-key $MAINNET_PRIVATE_KEY --broadcast --legacy