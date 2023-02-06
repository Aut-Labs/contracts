//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPluginRegistry {
    struct PluginDefinition {
        string metadataURI;
        uint256 price;
        address payable creator;
        bool active;
    }

    struct PluginInstance {
        address pluginAddress;
        uint256 pluginDefinitionId;
    }
    event PluginRegistered(
        uint256 indexed tokenId,
        address indexed pluginAddress
    );
    event PluginDefinitionAdded(uint256 indexed pluginTypeId);

    event PluginAddedToDAO(
        uint256 indexed tokenId,
        uint256 indexed pluginTypeId,
        address indexed dao
    );

    function getOwnerOfPlugin(address pluginAddress)
        external
        view
        returns (address);

    function getPluginInstanceByTokenId(uint256 tokenId)
        external
        view
        returns (PluginInstance memory);

    function pluginDefinitionsInstalledByDAO(address dao, uint256 pluginTypeId)
        external
        view
        returns (bool);

    function getPluginIdsByDAO(address dao)
        external
        view
        returns (uint256[] memory);
}
