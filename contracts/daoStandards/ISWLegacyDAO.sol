//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
pragma experimental ABIEncoderV2;

/// @title ISWLegacyDAO
/// @notice A minimal SkillWallet Legacy DAO interface for implementing IMembershipExtension
interface ISWLegacyDAO {
    /// @notice Function in the SkillWallet DAO contract for checking for membership
    /// @param member the address for which is going to be checked whether is a member or not
    /// @return true if the address is a member, false otherwise
    function isMember(address member) external view returns (bool);
}
