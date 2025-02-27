//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

/// @title Aut Registry
/// @author Āut Labs
/// @notice This contract keeps track of the plugins used in the Aut ecosystem and will be used by the c-aut token mostly as the only transactions allowed for this token is from and to these plugins.
contract UtilsRegistry is OwnableUpgradeable {
    /// @notice mapping of plugin addresses and their information
    mapping(address plugin => PluginMeta pluginMeta) private plugins;

    /// @notice emitted when a plugin is added to the registry
    /// @param contractAddress The contract address of the plugin
    event PluginAdded(address contractAddress);

    /// @notice emitted when a plugin is removed from the registry
    /// @param contractAddress The contract address of the plugin
    event PluginRemoved(address contractAddress);

    /// @notice provides more information about a plugin
    /// @param description The description of the plugin
    /// @param enabled Whether the plugin is enabled
    struct PluginMeta {
        string description;
        bool enabled;
    }

    /// @notice UtilsRegistry contract initializer
    /// @param initialOwner The initial owner of the contract
    function initialize(address initialOwner) external initializer {
        __Ownable_init(initialOwner);
    }

    /// @notice gap used as best practice for upgradeable contracts
    uint256[50] private __gap;

    /// @notice Registers a plugin, only callable by the owner of the contract
    /// @param contractAddress the address of the contract
    /// @param _description The description of the plugin
    function registerPlugin(address contractAddress, string calldata _description) external onlyOwner {
        require(contractAddress != address(0), "contractAddress must be a valid address");
        require(!plugins[contractAddress].enabled, "plugin is already registered");
        plugins[contractAddress].description = _description;
        plugins[contractAddress].enabled = true;
        emit PluginAdded(contractAddress);
    }

    /// @notice removes a plugin, only callable by the owner of the contract
    /// @param contractAddress the address of the contract
    function removePlugin(address contractAddress) external onlyOwner {
        require(contractAddress != address(0), "contractAddress must be a valid address");
        require(plugins[contractAddress].enabled, "plugin does not exist");

        delete plugins[contractAddress];
        emit PluginRemoved(contractAddress);
    }

    /// @notice returns whether the plugin is enabled
    /// @param contractAddress the address of the contract
    function isPlugin(address contractAddress) external view returns (bool) {
        return plugins[contractAddress].enabled;
    }

    /// @notice returns the plugin description
    /// @param contractAddress the address of the contract
    function getPluginDescription(address contractAddress) external view returns (string memory) {
        return plugins[contractAddress].description;
    }
}
