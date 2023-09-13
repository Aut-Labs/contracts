//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "../daoStandards/ITribute.sol";

/// @title Tribute
/// @notice Mock Tribute DAO for testing
contract Tribute is ITribute {
    mapping(address => Member) private _members;

    function addMember(address newMember) external {
        _members[newMember] = Member(5);
    }

    function members(address addr) external view override returns (Member memory) {
        return _members[addr];
    }
}
