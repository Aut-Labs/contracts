//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/// @title INova
/// @notice The interface for the extension of each Nova that integrates AutID
interface INovaAdminSet {
    event AdminMemberAdded(address member);
    event AdminMemberRemoved(address member);

    function addAdmin(address member) external;

    function addAdmins(address[] memory adminAddr) external returns (address[] memory);

    function removeAdmin(address member) external;
}
