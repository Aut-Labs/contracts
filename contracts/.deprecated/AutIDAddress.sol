// //SPDX-License-Identifier: MIT
// pragma solidity ^0.8.20;

// import "../interfaces/get/IAutIDAddress.sol";
// import "../../autid/IAutID.sol";

// /// @title Nova
// /// @notice The extension of each Nova that integrates Aut
// /// @dev The extension of each Nova that integrates Aut
// abstract contract AutIDAddress is IAutIDAddress {
//     IAutID private _autID;

//     /// @dev Modifier for check of access of the admin member functions
//     modifier onlyAutID() {
//         require(msg.sender == address(_autID), "Only AutID");
//         _;
//     }

//     function getAutIDAddress() public view override returns (address) {
//         return address(_autID);
//     }

//     function _setAutIDAddress(IAutID autIDAddress) internal {
//         _autID = IAutID(autIDAddress);
//     }

//     uint256[49] private __gap;
// }
