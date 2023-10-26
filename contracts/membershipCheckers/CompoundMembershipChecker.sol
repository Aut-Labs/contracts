//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./IMembershipChecker.sol";
import "../standards/ICompound.sol";

/// @title CompoundMembershipChecker
/// @notice Implementation of IMembershipChecker for your new DAO standard
contract CompoundMembershipChecker is IMembershipChecker {
    /// @notice Implements a check if an address is a member of a Compound
    /// @param daoAddress the address of the Compound Comptroller contract
    /// @param member the address of the member for which the check is made
    /// @return true if the user address is a member, false otherwise
    function isMember(address daoAddress, address member) public view override returns (bool) {
        require(daoAddress != address(0), "AutID: daoAddress empty");
        require(member != address(0), "AutID: member empty");

        try ICompound(daoAddress).accountAssets(member, 0) {
            return true;
        } catch {}

        return false;
    }
}
