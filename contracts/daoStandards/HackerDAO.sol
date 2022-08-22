//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ISWLegacyDAO.sol";

/// @title HackerDAO
/// @notice A permissionless HackerDAO for integrating 
contract HackerDAO is ISWLegacyDAO {
    event Joined(address member);
    mapping(address => bool) public override isMember;

    /// @notice Adds new member to the DAO
    function join() public {
        isMember[msg.sender] = true;
        emit Joined(msg.sender);
    }
}
