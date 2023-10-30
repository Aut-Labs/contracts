//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/// @title IAutIDAddressSet
/// @notice The extension of each Nova that integrates Aut
/// @dev The extension of each DAO that integrates Aut
interface IAutIDAddressSet {
    function setAutIDAddress(address autIDAddress) external;
}
