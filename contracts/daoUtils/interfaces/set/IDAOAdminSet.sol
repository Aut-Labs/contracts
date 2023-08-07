//SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

/// @title IDAOExpander
/// @notice The interface for the extension of each DAO that integrates AutID
interface IDAOAdminSet {
    event AdminMemberAdded(address member);
    event AdminMemberRemoved(address member);

    function addAdmin(address member) external;

    function removeAdmin(address member) external;
}
