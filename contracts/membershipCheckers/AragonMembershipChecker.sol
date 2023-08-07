//SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "./IMembershipChecker.sol";
import {IAragonApp} from "../daoStandards/IAragon.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IMiniMeToken} from "../daoStandards/IAragon.sol";

/// @title AragonMembershipChecker
/// @notice Implementation of IMembershipChecker for Aragon DAO type
contract AragonMembershipChecker is IMembershipChecker {
    /// @notice Implements a check if an address is a member of a DAO
    /// @param daoAppAddress the address of the DAO contract
    /// @param member the address of the member for which the check is made
    /// @return true if the user address is a member, false otherwise
    function isMember(address daoAppAddress, address member) public view override returns (bool) {
        require(daoAppAddress != address(0), "AutID: daoAppAddress empty");
        require(member != address(0), "AutID: member empty");

        return IMiniMeToken(IAragonApp(daoAppAddress).token()).balanceOf(member) > 0;
    }
}
