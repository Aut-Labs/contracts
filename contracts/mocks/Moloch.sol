//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "../daoStandards/IMoloch.sol";

/// @title Molock
/// @notice Mock Moloch DAO for testing
contract Moloch is IMoloch {
    mapping(address => Member) private mems;

    /// @notice Adds member to the DAO
    /// @param member the address of the member
    function addMember(address member) public {
        mems[member] = Member(address(0), 5, 5, true, 1, 1);
    }

    function members(address member) public override view returns(Member memory) {
        return mems[member];
    }
}
