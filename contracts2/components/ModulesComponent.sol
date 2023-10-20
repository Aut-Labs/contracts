//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "../interfaces/IModuleRegistry.sol";
import "../interfaces/IPluginRegistry.sol";

import "../base/ComponentBase.sol";
import "../utils/Semver.sol";

/// @title Modules component
/// @notice The extension of each DAO that integrates Aut
/// @dev The extension of each DAO that integrates Aut
contract ModulesComponent is ComponentBase, Semver(0, 1, 0) {
    event ModuleActivated(uint256);

    address public pluginRegistry;
    uint256[] activatedModules;

    function setPluginRegistry(address _pluginRegistry) external novaCall {
        require(_pluginRegistry != address(0), "invalid pluginRegistry");
        pluginRegistry = _pluginRegistry;
    }

    function activateModule(uint256 moduleId) external novaCall {
        address modulesRegistry = IPluginRegistry(pluginRegistry).modulesRegistry();
        require(
            bytes(IModuleRegistry(modulesRegistry).getModuleById(moduleId).metadataURI).length > 0, "invalid module"
        );
        activatedModules.push(moduleId);
        emit ModuleActivated(moduleId);
    }

    function isModuleActivated(uint256 moduleId) public view returns (bool) {
        for (uint256 i = 0; i < activatedModules.length; i++) {
            if (activatedModules[i] == moduleId) return true;
        }
        return false;
    }
}
