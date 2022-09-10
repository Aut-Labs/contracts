//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IMembershipChecker.sol";
import "../daoStandards/ILepakDAO.sol";

/// @title LepakMembershipChecker
/// @notice Implementation of IMembershipChecker for LepakDAO
contract LepakMembershipChecker is IMembershipChecker {

    /// @notice Implements a check if an address is a member of a Lepak DAO
    /// @param daoAddress the address of the DAO Core contract
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
        return ILepakDAO(daoAddress).isMember(member);
    }
}
