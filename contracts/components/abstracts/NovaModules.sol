//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "../interfaces/get/INovaModules.sol";
import "../../modules/registry/IModuleRegistry.sol";
import "../../plugins/registry/IPluginRegistry.sol";

/// @title Nova
/// @notice The extension of each DAO that integrates Aut
/// @dev The extension of each DAO that integrates Aut
abstract contract NovaModules is INovaModules {
    address public override pluginRegistry;
    uint256[] activatedModules;

    modifier onlyPluginRegistry() {
        require(msg.sender == address(pluginRegistry), "Only plugin registry");
        _;
    }

    function _setPluginRegistry(address _pluginRegistry) internal {
        require(_pluginRegistry != address(0), "invalid pluginRegistry");
        pluginRegistry = _pluginRegistry;
    }

    function _activateModule(uint256 moduleId) internal {
        address modulesRegistry = IPluginRegistry(pluginRegistry).modulesRegistry();
        require(
            bytes(IModuleRegistry(modulesRegistry).getModuleById(moduleId).metadataURI).length > 0, "invalid module"
        );
        activatedModules.push(moduleId);
        emit ModuleActivated(moduleId);
    }

    function isModuleActivated(uint256 moduleId) public view override returns (bool) {
        for (uint256 i = 0; i < activatedModules.length; i++) {
            if (activatedModules[i] == moduleId) return true;
        }
        return false;
    }

    uint256[10 - 8] private __gap;
}
