//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./IMembershipChecker.sol";
import "../daoStandards/IMoloch.sol";

/// @title MolochV2MembershipChecker
/// @notice Implementation of IMembershipChecker for Moloch DAO type
contract MolochV2MembershipChecker is IMembershipChecker {
    /// @notice Implements a check if an address is a member of a Moloch DAO
    /// @param daoAddress the address of the Moloch contract
    /// @param member the address of the member for which the check is made
    /// @return true if the user address is a member, false otherwise
    function isMember(address daoAddress, address member) public view override returns (bool) {
        require(daoAddress != address(0), "AutID: daoAddress empty");
        require(member != address(0), "AutID: member empty");

        return IMoloch(daoAddress).members(member).shares > 0 || IMoloch(daoAddress).members(member).loot > 0;
    }
}
