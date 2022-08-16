//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "../daoStandards/ISWLegacyDAO.sol";

/// @title TestingDAO
/// @notice Mock SW Legacy DAO for testing
contract TestingDAO is ISWLegacyDAO {
    /// @notice Adds member to the DAO
    /// @param member the address of the member
    function isMember(address member) public override view returns (bool) {
        require(member != address(0), "Zero address not a member");
        return true;
    }
}
