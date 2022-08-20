//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./IMembershipChecker.sol";
import "../daoStandards/IColony.sol";

/// @title ColonyMembershipChecker
/// @notice Implementation of IMembershipChecker for your new DAO standard
contract ColonyMembershipChecker is IMembershipChecker {

    /// @notice Implements a check if an address is a member of a Colony
    /// @param daoAddress the address of the Colony contract
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

        if (IColony(daoAddress).owner() == member) {
            return true;
        }

        address whitelist = IColonyNetwork(IColony(daoAddress).getColonyNetwork()).getExtensionInstallation(
            keccak256("Whitelist"),
            daoAddress
        );

        if (whitelist != address(0)) {
            return IColonyWhitelist(whitelist).isApproved(member);
        }

        return false;
    }
}
