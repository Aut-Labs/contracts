#!/usr/bin/env sh

set -eu

nohup anvil --port "${RPC_PORT}" \
    --host "0.0.0.0" \
    --accounts 1 \
    1>&2 &

while ! nc -z localhost ${RPC_PORT}; do sleep 1; done;

forge script ./script/DeployAll.s.sol --rpc-url "http://localhost:${RPC_PORT}" \
    --private-key "${PVK_A1}" \
    --broadcast \
    --legacy

wait $!
