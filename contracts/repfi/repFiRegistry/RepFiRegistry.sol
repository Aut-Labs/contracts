//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract RepFiRegistry is OwnableUpgradeable {
    mapping(address plugin => bool enabled) private plugins;

    event PluginAdded(address contractAddress);
    event PluginRemoved(address contractAddress);

    function initialize(address initialOwner) external initializer {
        __Ownable_init(initialOwner);
    }

    uint256[50] private __gap;

    function registerPlugin(address contractAddress) external onlyOwner {
        require(contractAddress != address(0), "contractAddress must be a valid address");
        plugins[contractAddress] = true;
        emit PluginAdded(contractAddress);
    }

    function removePlugin(address contractAddress) external onlyOwner {
        require(contractAddress != address(0), "contractAddress must be a valid");
        require(plugins[contractAddress] == true, "plugin does not exist");

        delete plugins[contractAddress];
        emit PluginRemoved(contractAddress);
    }

    function isPlugin(address contractAddress) external view returns (bool) {
        return plugins[contractAddress];
    }
}
