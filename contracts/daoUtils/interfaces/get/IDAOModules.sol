//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title IDAOModules
/// @notice The interface for the extension of each DAO that integrates AutID
interface IDAOModules {
    function pluginRegistry() external view returns (address);
}
