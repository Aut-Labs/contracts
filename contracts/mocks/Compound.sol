//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "../daoStandards/ICompound.sol";

/// @title Compound
/// @notice Mock Compound DAO for testing
contract Compound is ICompound {

    mapping(address => address[]) _accountAssets;

    function accountAssets(address member, uint index) external view override returns(address) {
        return _accountAssets[member][index];
    }

    /// @notice Adds member to the DAO
    /// @param member the address of the member
    function addMember(address member) public {
        _accountAssets[member].push(member);
    }
}
