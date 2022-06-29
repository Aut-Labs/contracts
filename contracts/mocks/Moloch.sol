//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "../communities/IMoloch.sol";

/// @title Community
/// @notice Mock community for testing
contract Moloch is IMoloch {
    mapping(address => Member) private mems;

    /// @notice Adds member to the community
    /// @param member the address of the member
    function addMember(address member) public {
        mems[member] = Member(address(0), 5, 5, true, 1, 1);
    }

    function members(address member) public override view returns(Member memory) {
        return mems[member];
    }
}
