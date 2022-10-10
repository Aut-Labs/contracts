//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title IDAOExpander
/// @notice The interface for the extension of each DAO that integrates AutID
interface IDAOAdmin {

    event AdminMemberAdded(address member);
    event AdminMemberRemoved(address member);

    function isAdmin(address member) external view returns (bool);

    function addAdmin(address member) external;

    function removeAdmin(address member) external;

    function getAdmins() external view returns (address[] memory);
}
