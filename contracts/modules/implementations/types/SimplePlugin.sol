//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../interfaces/modules/IModule.sol";
import "../../interfaces/registry/IPluginRegistry.sol";
import "../../../daoUtils/interfaces/get/IDAOModules.sol";

abstract contract SimplePlugin is IModule {
    address _deployer;
    address _dao;
    uint256 public pluginId;
    bool public override isActive;
    IPluginRegistry public pluginRegistry; 
    
    modifier onlyDAOModule() {
        uint256[] memory installedPlugins = IPluginRegistry(pluginRegistry)
            .getPluginIdsByDAO(_dao);
        bool pluginFound = false;
        for (uint256 i = 0; i < installedPlugins.length; i++) {
            if (installedPlugins[i] == pluginId) pluginFound = true; _;
        }
        require(pluginFound, "Only DAO Module");
        _;
    }

    modifier onlyDeployer() {
        require(
            msg.sender == _deployer,
            "Only deployer can call this function"
        );
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner(), "Only owner can call this function");
        _;
    }

    modifier onlyPluginRegistry() {
        require(msg.sender == address(pluginRegistry), "Only plugin registry");
        _;
    }

    constructor(address dao) {
        _dao = dao;
        pluginRegistry = IPluginRegistry(
            IDAOModules(dao).getPluginRegistryAddress()
        );
        _deployer = msg.sender;
    }

    function owner() public view returns (address) {
        return pluginRegistry.getOwnerOfPlugin(address(this));
    }

    function deployer() public view override returns (address) {
        return _deployer;
    }

    function daoAddress() public view override returns (address) {
        return _dao;
    }

    function _setActive(bool newActive) internal {
        isActive = newActive;
    }

    function storePluginId(uint256 tokenId) public override onlyPluginRegistry {
        pluginId = tokenId;
    }
}
