//SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

/// @title IMoloch
/// @notice The minimal interface of the Moloch contract needed for implementing IMembershipExtension
interface IMoloch {

  struct Member {
        address delegateKey;
        uint256 shares;
        uint256 loot;
        bool exists;
        uint256 highestIndexYesVote;
        uint256 jailed;
       }

    /// @notice Function in the Moloch contract for fetching a member 
    /// @param member the member address
    /// @return The Member struct of the address passed
    function members(address member) external view returns(Member memory);
}
