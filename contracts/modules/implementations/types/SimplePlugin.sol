//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../interfaces/modules/IModule.sol";
import "../../interfaces/registry/IPluginRegistry.sol";
import "../../../daoUtils/interfaces/get/IDAOModules.sol";

abstract contract SimplePlugin is IModule {
    address _deployer;
    address _dao;
    IPluginRegistry public pluginRegistry; // This shouldn't exist. This needs to check the holder of the NFT...

    modifier onlyDeployer() {
        require(msg.sender == _deployer, "Only deployer can call this function");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner(), "Only owner can call this function");
        _;
    }

    constructor(address dao) {
        _dao = dao;
        pluginRegistry = IPluginRegistry(IDAOModules(dao).getPluginRegistryAddress());
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
}
