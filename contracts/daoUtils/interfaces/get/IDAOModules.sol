//SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

/// @title IDAOModules
/// @notice The interface for the extension of each DAO that integrates AutID
interface IDAOModules {
    event ModuleActivated(uint moduleId);

    function pluginRegistry() external view returns (address);

    function activateModule(uint moduleId) external;

    function isModuleActivated(uint moduleId) external view returns(bool);
}
