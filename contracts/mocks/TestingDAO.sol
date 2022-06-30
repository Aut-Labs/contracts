//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "../communities/ISWLegacyCommunity.sol";

/// @title TestingDAO
/// @notice Mock SW Legacy community for testing
contract TestingDAO is ISWLegacyCommunity {
    /// @notice Adds member to the community
    /// @param member the address of the member
    function isMember(address member) public override view returns (bool) {
        require(member != address(0), "Zero address not a member");
        return true;
    }
}
