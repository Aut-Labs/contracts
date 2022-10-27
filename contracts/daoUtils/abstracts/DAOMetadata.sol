//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/get/IDAOMetadata.sol";

/// @title DAOExpander
/// @notice The extension of each DAO that integrates Aut
/// @dev The extension of each DAO that integrates Aut
abstract contract DAOMetadata is IDAOMetadata {
    event MetadataUriUpdated();

    string _metadata;

    function _setMetadataUri(string memory metadata)
        internal
        virtual
    {
        require(bytes(metadata).length > 0, "Missing Metadata URL");

        _metadata = metadata;
        emit MetadataUriUpdated();
    }

    function getMetadataUri() public view override returns(string memory) {
        return _metadata;
    }
}
