//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/get/IDAOMetadata.sol";

/// @title DAOExpander
/// @notice The extension of each DAO that integrates Aut
/// @dev The extension of each DAO that integrates Aut
abstract contract DAOMetadata is IDAOMetadata {
    event MetadataUriUpdated();

    string public override metadataUrl;

    function _setMetadataUri(string memory _metadata)
        internal
        virtual
    {
        require(bytes(_metadata).length > 0, "invalid url");

        metadataUrl = _metadata;
        emit MetadataUriUpdated();
    }

}
