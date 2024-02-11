//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IOnboarding.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SimpleAllowlistOnboarding is IRoleOnboarding, Ownable {
    mapping(address => bool) internal _allowset;

    constructor(address initialOwner) Ownable(initialOwner) {}

    function isOnboarded(address who) external view returns (bool) {
        return _allowset[who];
    }

    function addToAllowlist(address target) external {
        _checkOwner();

        _addToAllowlist(target);
    }

    function addBatchToAllowlist(address[] memory list) external {
        _checkOwner();

        for (uint256 i; i != list.length; ++i) {
            _addToAllowlist(list[i]);
        }
    }

    function _addToAllowlist(address who) internal {
        _allowset[who] = true;
    }
}
