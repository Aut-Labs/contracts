//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title ILepakDAO
/// @notice implements a checker for member in Lepak DAO:
//          Lepak DAO members are Lepak NFT holders , Moderators or Governor
/// @author Carlos Ramos - Lepak DAO

interface ILepakDAO {
    function isMember(address _user) external view returns (bool);
}
