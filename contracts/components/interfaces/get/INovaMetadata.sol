//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/// @title INova
/// @notice The interface for the extension of each Nova that integrates AutID
interface INovaMetadata {
    function metadataUrl() external view returns (string memory uri);
}
