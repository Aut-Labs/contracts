//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "../standards/ISWLegacyDAO.sol";

/// @title SWLegacyDAO
/// @notice Mock SW Legacy DAO for testing
contract SWLegacyDAO is ISWLegacyDAO {
    mapping(address => bool) public override isMember;

    /// @notice Adds member to the DAO
    /// @param member the address of the member
    function addMember(address member) public {
        isMember[member] = true;
    }
}
