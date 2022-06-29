//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "../communities/ISWLegacyCommunity.sol";

/// @title SWLegacyCommunity
/// @notice Mock SW Legacy community for testing
contract SWLegacyCommunity is ISWLegacyCommunity {
    mapping(address => bool) public override isMember;

    /// @notice Adds member to the community
    /// @param member the address of the member
    function addMember(address member) public {
        isMember[member] = true;
    }
}
