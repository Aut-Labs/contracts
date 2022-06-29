//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

/// @title ISWLegacyCommunity
/// @notice A minimal SkillWallet Legacy Community interface for implementing IMembershipExtension
interface ISWLegacyCommunity {
    /// @notice Function in the SkillWallet Community contract for checking for membership
    /// @param member the address for which is going to be checked whether is a member or not 
    /// @return true if the address is a member, false otherwise
    function isMember(address member) external view returns (bool);
}
