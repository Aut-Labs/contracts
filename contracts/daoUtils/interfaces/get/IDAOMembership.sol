//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title IDAOExpander
/// @notice The interface for the extension of each DAO that integrates AutID
interface IDAOMembership {


    function isMember(address member) external view returns (bool);

    function getAllMembers() external view returns (address[] memory);

    function canJoin(address member, uint role) external view returns(bool);

}
