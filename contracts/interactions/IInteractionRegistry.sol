// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @author Āut Labs
/// @title A registry contract for all defined interaction types
interface IInteractionRegistry {
    /// @title Event emitted on creation of interaction
    /// @param interactionType interaction identifier (`keccak256` hash of `InteractionData`)
    /// @param chainId EIP-1344 comptible chain id relative to interaction
    /// @param recipient address specified as `to` in the transaction data (recipient of the transaction)
    /// @param functionSelector first 4 bytes of the `msg.to` in the transaction data (contract method)
    event InteractionCreated(
        bytes32 indexed interactionType,
        uint16 indexed chainId,
        address indexed recipient,
        bytes4 functionSelector
    );

    /// @title Interaction data structure
    /// @param chainId EIP-1344 comptible chain id relative to interaction
    /// @param recipient address specified as `to` in the transaction data (recipient of the transaction)
    /// @param functionSelector first 4 bytes of the `msg.to` in the transaction data (contract method)
    struct InteractionData {
        uint16 chainId;
        address recipient;
        bytes4 functionSelector;
        bool _check;
    }

    /// @dev Authorized for creating interactions
    bytes32 public constant CREATOR_ROLE = keccak256("CREATOR_ROLE");

    /// @dev Authorized to manage the CREATOR role
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER(CREATOR)_ROLE");

    bytes32 public constant INTERACTION_DATA_TYPEHASH =
        keccak256("InteractionData(uint16 chainId,address recipient,bytes4 functionSelector)");

    /// @title Form an interaction `bytes32` identifier hash from base interaction parameters
    /// @param chainId EIP-1344 comptible chain id relative to interaction
    /// @param recipient address specified as `to` in the transaction data (recipient of the transaction)
    /// @param functionSelector first 4 bytes of the `msg.to` in the transaction data (contract method)
    /// @return the identifier
    function interactionType(
        uint16 chainId,
        address recipient,
        bytes4 functionSelector
    ) external pure returns (bytes32);

    /// @title Get `InteractionData` for the given interaction type hash
    /// @param interactionType interaction identifier (`keccak256` hash of `InteractionData`)
    /// @return the interaction data struct
    function interactionDataFor(bytes32 interactionType) external view returns (InteractionData memory);

    /// @title Create new interaction type with parameters
    /// @param chainId EIP-1344 comptible chain id relative to interaction
    /// @param recipient address specified as `to` in the transaction data (recipient of the transaction)
    /// @param functionSelector first 4 bytes of the `msg.to` in the transaction data (contract method)
    function createInteraction(uint16 chainId, address recipient, bytes4 functionSelector) external;
}
