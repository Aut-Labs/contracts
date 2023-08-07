//SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "../daoStandards/IMoloch.sol";

/// @title Moloch
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
