//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract RepFiRegistry is OwnableUpgradeable {
    mapping(address plugin => PluginMeta pluginMeta) private plugins;

    event PluginAdded(address contractAddress);
    event PluginRemoved(address contractAddress);

    struct PluginMeta {
        string description;
        bool enabled;
    }

    function initialize(address initialOwner) external initializer {
        __Ownable_init(initialOwner);
    }

    uint256[50] private __gap;

    function registerPlugin(address contractAddress, string calldata _description) external onlyOwner {
        require(contractAddress != address(0), "contractAddress must be a valid address");
        require(plugins[contractAddress].enabled == false, "plugin is already registered");
        plugins[contractAddress].description = _description;
        plugins[contractAddress].enabled = true;
        emit PluginAdded(contractAddress);
    }

    function removePlugin(address contractAddress) external onlyOwner {
        require(contractAddress != address(0), "contractAddress must be a valid");
        require(plugins[contractAddress].enabled == true, "plugin does not exist");

        delete plugins[contractAddress];
        emit PluginRemoved(contractAddress);
    }

    function isPlugin(address contractAddress) external view returns (bool) {
        return plugins[contractAddress].enabled;
    }

    function getPluginDescription(address _contractAddress) external view returns (string memory) {
        return plugins[_contractAddress].description;
    }
}
