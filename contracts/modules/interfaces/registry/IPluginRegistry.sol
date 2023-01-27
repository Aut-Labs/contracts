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
        uint256 pluginTypeId;
    }

    function getOwnerOfPlugin(address pluginAddress)
        external
        view
        returns (address);

    function getPluginInstanceByTokenId(uint256 tokenId)
        external
        view
        returns (PluginInstance memory);

    function pluginTypesInstalledByDAO(address dao, uint256 pluginTypeId)
        external
        view
        returns (bool);
}
