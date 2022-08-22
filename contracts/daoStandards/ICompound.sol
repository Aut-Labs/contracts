//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title ICompound
/// @notice The minimal interface of the Compound contract needed for implementing IMembershipExtension
interface ICompound {

    /// @notice Function in the Compound contract for fetching a member.
    /// @notice If for index 0 returned address is not empty, then account is a member.
    /// @param member The member address
    /// @param index Array index of the asset
    /// @return The Member struct of the address passed
    function accountAssets(address member, uint index) external view returns(address);
}
