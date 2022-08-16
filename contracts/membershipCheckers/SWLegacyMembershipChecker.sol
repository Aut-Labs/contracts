//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./IMembershipChecker.sol";
import "../daoStandards/ISWLegacyDAO.sol";

/// @title SWLegacyMembershipChecker
/// @notice Implementation of IMembershipChecker for SW Legacy DAO type
contract SWLegacyMembershipChecker is IMembershipChecker {
    /// @notice Implements a check if an address is a member of a SW Legacy DAO
    /// @param daoAddress the address of the SW Legacy Contract
    /// @param member the address of the member for which the check is made
    /// @return true if the user address is a member, false otherwise
    function isMember(address daoAddress, address member)
        public
        view
        override
        returns (bool)
    {
        require(daoAddress != address(0), "AutID: daoAddress empty");
        require(member != address(0), "AutID: member empty");

        return ISWLegacyDAO(daoAddress).isMember(member);
    }
}
