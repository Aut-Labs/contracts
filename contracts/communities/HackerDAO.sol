//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./ISWLegacyDAO.sol";

/// @title HackerDAO
/// @notice A permissionless HackerDAO for integrating on hackathons
contract HackerDAO is ISWLegacyDAO {
    mapping(address => bool) public override isMember;

    /// @notice Adds member to the DAO
    /// @param member the address of the member
    function addMember(address member) public {
        isMember[member] = true;
    }
}
