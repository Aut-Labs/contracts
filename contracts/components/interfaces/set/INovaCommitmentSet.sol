//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/// @title INova
/// @notice The interface for the extension of each Nova that integrates AutID
interface INovaCommitmentSet {
    function setCommitment(uint256 commitment) external;
}
