//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./IMembershipChecker.sol";
import "../daoStandards/ITribute.sol";

/// @title NewMembershipChecker
/// @notice Implementation of IMembershipChecker for your new DAO standard
contract TributeMembershipChecker is IMembershipChecker {

    /// @notice Implements a check if an address is a member of a DAO
    /// @param daoAddress the address of the DAO contract
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

        // implement your membership checker logic here
        // return reasonable result ;)
        // return false;
        return ITribute(daoAddress).members(member).flags > 0;
    }
}
