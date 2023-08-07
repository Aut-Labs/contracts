//SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

/// @title IDAOMetadata
/// @notice The interface for the extension of each DAO that integrates AutID
interface IDAOMetadataSet {

    function setMetadataUri(string calldata metadata) external;
}
