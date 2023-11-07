//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/// @title IAutIDAddress
/// @notice The extension of each Nova that integrates Aut
/// @dev The extension of each Nova that integrates Aut
interface IAutIDAddress {
    function getAutIDAddress() external view returns (address);
}
