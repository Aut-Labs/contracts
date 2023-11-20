#!/usr/bin/env sh

set -eu

nohup anvil --port "${RPC_PORT}" \
    --host "0.0.0.0" \
    --accounts 1 \
    1>&2 &

# todo: until $(curl ...) healthcheck
sleep 1

forge script ./script/DeployAll.s.sol --rpc-url "http://localhost:${RPC_PORT}" \
    --private-key "${PVK_A1}" \
    --broadcast \
    --legacy

wait $!
