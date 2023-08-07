//SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "../daoStandards/ICompound.sol";

/// @title Compound
/// @notice Mock Compound DAO for testing
contract Compound is ICompound {
    mapping(address => address[]) _accountAssets;

    function accountAssets(address member, uint256 index) external view override returns (address) {
        return _accountAssets[member][index];
    }

    /// @notice Adds member to the DAO
    /// @param member the address of the member
    function addMember(address member) public {
        _accountAssets[member].push(member);
    }
}
