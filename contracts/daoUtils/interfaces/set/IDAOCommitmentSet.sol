//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/// @title IDAOMetadata
/// @notice The interface for the extension of each DAO that integrates AutID
interface IDAOCommitmentSet {
    function setCommitment(uint256 commitment) external;
}
