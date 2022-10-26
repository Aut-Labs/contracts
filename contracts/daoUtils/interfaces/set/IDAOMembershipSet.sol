//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title IDAOExpander
/// @notice The interface for the extension of each DAO that integrates AutID
interface IDAOMembershipSet {

    function join(address newMember) external;

}
