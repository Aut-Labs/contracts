//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title IPluginRegistry
 * @dev Interface for the plugin registry contract, which manages the registration and installation of plugins.
 */
interface IPluginRegistry {
    
    /**
     * @dev Struct defining the data for a plugin definition, which includes metadata, pricing, creator information, and dependencies.
     */
    struct PluginDefinition {
        string metadataURI;
        uint256 price;
        address payable creator;
        bool active;
        bool canBeStandalone;
        uint[] dependencyModules;
    }
    
    /**
     * @dev Struct defining the data for a plugin instance, which includes the plugin's address and its associated plugin definition ID.
     */
    struct PluginInstance {
        address pluginAddress;
        uint256 pluginDefinitionId;
    }
    
    /**
     * @dev Emitted when a new plugin is registered with the plugin registry.
     * @param tokenId The ID of the token associated with the registered plugin.
     * @param pluginAddress The address of the registered plugin.
     */
    event PluginRegistered(
        uint256 indexed tokenId,
        address indexed pluginAddress
    );
    
    /**
     * @dev Emitted when a new plugin definition is added to the plugin registry.
     * @param pluginTypeId The ID of the newly added plugin definition.
     */
    event PluginDefinitionAdded(uint256 indexed pluginTypeId);

    /**
     * @dev Emitted when a plugin is added to a DAO.
     * @param tokenId The ID of the token associated with the added plugin.
     * @param pluginTypeId The ID of the plugin definition associated with the added plugin.
     * @param dao The address of the DAO to which the plugin was added.
     */
    event PluginAddedToDAO(
        uint256 indexed tokenId,
        uint256 indexed pluginTypeId,
        address indexed dao
    );
    
    /**
     * @dev Returns the owner of a given plugin.
     * @param pluginAddress The address of the plugin for which to get the owner.
     * @return The address of the owner of the specified plugin.
     */
    function getOwnerOfPlugin(address pluginAddress)
        external
        view
        returns (address);
    
    /**
     * @dev Returns the plugin instance associated with a given token ID.
     * @param tokenId The token ID for which to get the plugin instance.
     * @return A `PluginInstance` struct containing the plugin address and plugin definition ID associated with the specified token ID.
     */
    function getPluginInstanceByTokenId(uint256 tokenId)
        external
        view
        returns (PluginInstance memory);
    
    /**
     * @dev Returns a boolean indicating whether a given plugin definition is installed for a given DAO.
     * @param dao The address of the DAO for which to check plugin definition installation.
     * @param pluginTypeId The ID of the plugin definition for which to check installation.
     * @return A boolean indicating whether the specified plugin definition is installed for the specified DAO.
     */
    function pluginDefinitionsInstalledByDAO(address dao, uint256 pluginTypeId)
        external
        view
        returns (bool);
    
    /**
     * @dev Returns an array of token IDs representing the plugins installed for a given DAO.
     * @param dao The address of the DAO for which to get installed plugins.
     * @return An array of token IDs representing the plugins installed for the specified DAO.
     */
    function getPluginIdsByDAO(address dao)
        external
        view
        returns (uint256[] memory);
    
    /**
     * @dev Edits the metadata URI for a given plugin definition.
     * @param pluginDefinitionId The ID of the plugin for which to edit metadata.
     * @param url The URL of the new metadata.
     */
    function editPluginDefinitionMetadata(uint pluginDefinitionId, string memory url) external;

    /**
     * @dev Returns the address of the Modules Registry contract.
     * @return The address of the Modules Registry contract.
     */
    function modulesRegistry() external view returns(address);
    
    /**
     * @dev Adds a plugin to a DAO.
     * @param pluginAddress The address of the plugin contract.
     * @param pluginDefinitionId The ID of the plugin definition.
     */
    function addPluginToDAO(
        address pluginAddress,
        uint256 pluginDefinitionId
    ) external payable;

}
