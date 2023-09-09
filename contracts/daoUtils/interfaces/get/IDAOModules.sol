//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/// @title IDAOModules
/// @notice The interface for the extension of each DAO that integrates AutID
interface IDAOModules {
    event ModuleActivated(uint256 moduleId);

    function pluginRegistry() external view returns (address);

    function activateModule(uint256 moduleId) external;

    function isModuleActivated(uint256 moduleId) external view returns (bool);
}
