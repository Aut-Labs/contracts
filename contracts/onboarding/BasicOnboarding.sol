// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {IOnboarding, IRoleOnboarding} from "./IOnboarding.sol";

contract BasicScoreOnboarding is IOnboarding {
    address[] public roles;

    constructor(address[] memory byRole) {
        for (uint256 i; i != byRole.length; ++i) {
            require(byRole[i] != address(0), "zero address");
            roles.push(byRole[i]);
        }
    }

    function isOnboarded(address who, uint256 roleId) external view returns(bool) {
        address callee = roles[roleId];
        if (roleId < roles.length) {
            return IRoleOnboarding(callee).isOnboarded(who);
        }
        return false;
    }
}
