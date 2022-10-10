//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IDAOMetadata.sol";

/// @title DAOExpander
/// @notice The extension of each DAO that integrates Aut
/// @dev The extension of each DAO that integrates Aut
abstract contract DAOMetadata is IDAOMetadata {

    string _metadata;

    function setMetadataUri(string memory metadata)
        public
        virtual
        override
    {
        require(bytes(metadata).length > 0, "metadata uri missing");

        _metadata = metadata;
        emit MetadataUriUpdated();
    }

    function getMetadataUri() public override view returns(string memory) {
        return _metadata;
    }
}
