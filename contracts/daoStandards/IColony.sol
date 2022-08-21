//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

/// @title IColony
/// @notice The minimal interface of the Colony contract needed for implementing IMembershipExtension
interface IColony {

    /// @notice Colony reputation ERC-20 token. User's token balance greater than 0 means that user is a member.
    function token() external view returns (address);
}
