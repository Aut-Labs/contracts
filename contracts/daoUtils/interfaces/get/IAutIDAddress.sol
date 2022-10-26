//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title IAutIDAddress
/// @notice The extension of each DAO that integrates Aut
/// @dev The extension of each DAO that integrates Aut
interface IAutIDAddress {
    function getAutIDAddress() external view returns (address);
}
