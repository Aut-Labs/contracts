//SPDX-License-Identifier: UNLICENCED
pragma solidity 0.8.18;

/**
 * @title IPluginRegistry
 * @dev Interface for local reputation algorythm
 */
interface ILocalReputation {
    /// @notice function for setting dao specific reputation varibales
    /// @param dao_ address to which the plugin applies
    /// @dev
    function initialize(address dao_) external;

    /// @notice interaction function
    function interaction(bytes4 functionSignature, bytes calldata msgData, address agent) external;

    function setInteractionWeights(bytes4[] memory fxSigs, bytes[] memory datas) external;
}
