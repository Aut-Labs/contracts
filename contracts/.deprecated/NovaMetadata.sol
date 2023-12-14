// //SPDX-License-Identifier: MIT
// pragma solidity 0.8.19;

// import "../interfaces/get/INovaMetadata.sol";

// /// @title Nova
// /// @notice The extension of each Nova that integrates Aut
// /// @dev The extension of each Nova that integrates Aut
// abstract contract NovaMetadata is INovaMetadata {
//     event MetadataUriUpdated(string);

//     string public override metadataUrl;

//     function _setMetadataUri(string memory _metadata) internal virtual {
//         require(bytes(_metadata).length > 0, "invalid url");

//         metadataUrl = _metadata;
//         emit MetadataUriUpdated(_metadata);
//     }

//     uint256[10 - 1] private __gap;
// }
