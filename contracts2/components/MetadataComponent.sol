//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "../base/ComponentBase.sol";

/// @title Metadata component
/// @notice The extension of each DAO that integrates Aut
/// @dev The extension of each DAO that integrates Aut
contract MetadataComponent is ComponentBase {
    event MetadataUriUpdated(string);

    string public metadataUrl;

    function setMetadataUri(string memory _metadata) external novaCall {
        require(bytes(_metadata).length > 0, "MetadataComponent: invalid url");
        metadataUrl = _metadata;
        emit MetadataUriUpdated(_metadata);
    }
}
