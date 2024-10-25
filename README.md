[![deployed on mumbai testnet](https://github.com/Aut-Labs/contracts/actions/workflows/deploy_contracts_mumbai.yml/badge.svg)](https://github.com/Aut-Labs/contracts/actions/workflows/deploy_contracts_mumbai.yml)
# Āut Labs - Smart Contracts
Āut is an expandable protocol for Role-based Membership in Web3 Communities & DAOs.

DAOs can be much more than _Smart Treasuries_, Āut introduces native Roles & Interactions directly at contract level, to power the 2nd generation of DAOs. The DAO 2.0s, or a Coordination Renaissance.

To read more about Āut, visit our [Docs](https://docs.aut.id).
Below, you'll find a simple walkthrough to get started using Āut's Smart Contracts.

# Docker Setup

Create docker network (once)
```bash
docker network create mainnet
```

Run local blockchain node & deploy contracts. 
Now the local node is accessable at `http://localhost:8545` (with `chainId=31337`)
The deployer's PK is specified in `dev.env`

```bash
docker-compose up --build
```

Run local graph node
```bash
docker-compose -f docker-compose.graph.yml up
```

Deploy subgraphs
```bash
(
    cd subgraphs
    yarn create-local
    yarn deploy-local
)
```
# Contracts
## `AutID.sol`
The core contract of the protocol. All participants are required to go through the `AutID` contract to create an account and join hubs.

## `GlobalParameters.sol`
Globally-defined variables used across the protocol.  Variables of note are `period0Start`, `periodDuration`, `constraintFactor`, and `penaltyFactor`.

## `HubRegistry.sol`
Central point of hubs where the hub implementation is stored and new hubs are created.

## `HubDomainsRegistry.sol`
Each hub can register an `X.hub` domain, as registered through this contract.

## `TaskRegistry.sol`
Where all `taskIds` are registered, to be used within a `Contribution`.

## `Hub.sol`
Stores values related to the hub like admins and hub parameters.  Each hub is connected to a unique `TaskFactory`, `TaskManager`, `ParticipationScore`, and `Membership` contract.

### `TaskFactory.sol`
Location for hub admins to create `Contributions` and register `Descriptions`.

### `TaskManager.sol`
Contract where `Contributions` are managed through creation and removal.  Members can commit to a `Contribution`, and are then given the `Contribution`.

### `Membership.sol`
Here, you can find the hub members, their role and commitment level for the `Hub`.

### `ParticipationScore.sol`
Hub member participation scores and performance are stored within `ParticipationScore.sol`.

# Setup 

## Install Foundry 

### Using Foundryup

Foundryup is the Foundry toolchain installer. You can find more about it [here](https://github.com/foundry-rs/foundry/blob/master/foundryup/README.md).

Open your terminal and run the following command:

```sh
curl -L https://foundry.paradigm.xyz | bash
```

This will install Foundryup, then simply follow the instructions on-screen,
which will make the `foundryup` command available in your CLI.

Running `foundryup` by itself will install the latest (nightly) [precompiled binaries](#precompiled-binaries): `forge`, `cast`, `anvil`, and `chisel`.
See `foundryup --help` for more options, like installing from a specific version or commit.

## Deployments
### Deploy Using Forge Script

```sh
forge script  ./script/DeployAll.s.sol --rpc-url $RPC_URL --etherscan-api-key $XSCAN_TOKEN --private-key $DEPLOYER_PRIVATE_KEY --verify --broadcast 
 ```

Simulate the deployment locally first by running the command without the `--broadcast` (and `--verify`) flag.

`$RPC_URL` replace with the desired EVM RPC. Private RPC recommended. (Alchemy, Infura etc.)<br>
`$XSCAN_TOKEN` network specific blockchain explorer API key, use to upload ABIs and verify contracts <br>
`$DEPLOYER_PRIVATE_KEY` The private key of the deploying account (needs to have sufficient gas token balance)


### Get Artifacts Using Forge

`forge build`
Now all artefacts are stored in the `out/` folder (repository root)
 
## Useful commands
Foundry
```shell
forge b #build
forge t #test
forge fmt #format
forge help
```
