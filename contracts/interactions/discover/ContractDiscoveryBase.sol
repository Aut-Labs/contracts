// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IContractDiscovery} from "./IContractDiscovery.sol";

contract ContractDiscoverуBase {
    // used create2 deployment;
    address public constant CONTRACT_DISCOVERY = address(1000000007);

    bytes32 public immutable AUT_ID;
    bytes32 public immutable INTERACTION_REGISTRY;
    bytes32 public immutable INTERACTION_FACTORY;
    bytes32 public immutable INTERACTION_TX_MAPPER;

    function _constructor() internal {
        AUT_ID=IContractDiscovery.contractIdForName(":contracts:polygon:core:AutID");
        INTERACTION_REGISTRY=IContractDiscovery.contractIdForName(":contracts:polygon:interactions:InteractionRegistry");
        INTERACTION_FACTORY=IContractDiscovery.contractIdForName(":contracts:polygon:interactions:InteractionFactory");
        INTERACTION_TX_MAPPER=IContractDiscovery.contractIdForName(":contracts:polygon:interactions:InteractionTxMapper");
    }

    function _discover(bytes32 contractId) internal view returns(address) {
        return IContractDiscovery(CONTRACT_DISCOVERY).getContractAddress(
            contractId
        );
    }
}
