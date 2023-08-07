//SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "./IMembershipChecker.sol";
 
/// @title IMembershipChecker
/// @notice Each DAO standard supported by Aut should have an implementation of this interface for their DAO contract
/// @dev Implement using the logic of the specific DAO contract 
interface IMembershipChecker {
    /// @notice Implements a check if an address is a member of a specific DAO standard
    /// @param daoAddress the address of the membership/DAO contract
    /// @param member the address of the member for which the check is made
    /// @return true if the user address is a member, false otherwise
    function isMember(address daoAddress, address member) external view returns (bool);
}
