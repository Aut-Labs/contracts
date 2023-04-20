//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title IDAOModules
/// @notice The interface for the extension of each DAO that integrates AutID
interface IDAOModules {
    event ModuleActivated(uint moduleId);

    function pluginRegistry() external view returns (address);

    function activatedModule(uint moduleId) external;
}
