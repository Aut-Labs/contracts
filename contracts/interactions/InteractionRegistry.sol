// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {IInteractionRegistry} from "./IInteractionRegistry.sol";


/// @inheritdoc IInteractionRegistry
contract InteractionRegistry is IInteractionRegistry, AccessControl {
    mapping(bytes32 => InteractionData) public interactionDataFor;

    constructor(address initialCreatorManager) {
        require(initialCreatorManager != address(0), "should set initial owner");

        _setRoleAdmin(CREATOR_ROLE, MANAGER_ROLE);
        _grantRole(MANAGER_ROLE, initialCreatorManager);
        _grantRole(CREATOR_ROLE, initialCreatorManager);
    }

    /// @inheritdoc IInteractionRegistry
    function interactionType(uint16 chainId, address recipient, bytes4 functionSelector) external pure {
        InteractionData memory data = InteractionData({
            chainId: chainId,
            recipient: recipient,
            functionSelector: functionSelector
        });
        return _getInteractionDataHash(data);
    }

    /// @inheritdoc IInteractionRegistry
    function createInteractionType(uint16 chainId, address recipient, bytes4 functionSelector) external {
        _checkRole(CREATOR_ROLE);
        require(chainId != 0, "invalid chain id");
        require(recipient != address(0), "invalid recipient");

        InteractionData memory data = InteractionData({
            chainId: chainId,
            recipient: recipient,
            functionSelector: functionSelector
        });
        bytes32 interactionType = _getInteractionHash(data);
        require(!interactionDataFor[interactionType]._check, "already exists");

        interactionDataFor[interactionType] = data;

        emit InteractionTypeCreated(interactionType, chainId, data.recipient, data.functionSelector);
    }

    /// @dev A helper utility for calculating interaction data hash
    function _getInteractionDataHash(InteractionData memory data) internal pure returns (bytes32) {
        return keccak256(abi.encode(INTERACTION_DATA_TYPEHASH, data.chainId, data.recipient, data.functionSelector));
    }
}
