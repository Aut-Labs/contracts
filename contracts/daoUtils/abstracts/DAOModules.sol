//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/get/IDAOModules.sol";
import "../../modules/interfaces/modules/IModuleRegistry.sol";
import "../../modules/interfaces/registry/IPluginRegistry.sol";

/// @title DAOModules
/// @notice The extension of each DAO that integrates Aut
/// @dev The extension of each DAO that integrates Aut
abstract contract DAOModules is IDAOModules {
    address public override pluginRegistry;
    uint[] activatedModules;

    modifier onlyPluginRegistry() {
        require(msg.sender == address(pluginRegistry), "Only plugin registry");
        _;
    }

    function _setPluginRegistry(address _pluginRegistry) internal {
        require(_pluginRegistry != address(0), "invalid pluginRegistry");
        pluginRegistry = _pluginRegistry;
    }

    function _activateModule(uint moduleId) internal {
        address modulesRegistry = IPluginRegistry(pluginRegistry).modulesRegistry();
        require(IModuleRegistry(modulesRegistry).getModuleById(moduleId).isStandalone, "only standalone");
        activatedModules.push(moduleId);
        emit ModuleActivated(moduleId);
    }
}
