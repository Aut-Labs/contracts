//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IPlugin.sol";
import "./registry/IPluginRegistry.sol";
import "../daoUtils/interfaces/get/IDAOModules.sol";

abstract contract SimplePlugin is IPlugin {
    address _deployer;
    address _dao;

    uint256 public override pluginId;
    uint public override moduleId;

    bool public override isActive;
    IPluginRegistry public pluginRegistry;

    modifier onlyDAOModule() {
        uint256[] memory installedPlugins = IPluginRegistry(pluginRegistry)
            .getPluginIdsByDAO(_dao);
        bool pluginFound = false;
        for (uint256 i = 0; i < installedPlugins.length; i++) {
            if (installedPlugins[i] == pluginId) pluginFound = true;
            _;
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

    constructor(address dao, uint modId) {
        _dao = dao;
        pluginRegistry = IPluginRegistry(IDAOModules(dao).pluginRegistry());
        _deployer = msg.sender;
        moduleId = modId;
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

    function setPluginId(uint256 tokenId) public override onlyPluginRegistry {
        pluginId = tokenId;
    }
}
