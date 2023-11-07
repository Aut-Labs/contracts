//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/// @title INova
/// @notice The interface for the extension of each Nova that integrates AutID
interface INovaAdmin {
    function isAdmin(address member) external view returns (bool);

    function getAdmins() external view returns (address[] memory);
}
