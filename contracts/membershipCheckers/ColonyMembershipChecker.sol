//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./IMembershipChecker.sol";
import "../daoStandards/IColony.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

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

        return IERC20(IColony(daoAddress).token()).balanceOf(member) > 0;
    }
}
