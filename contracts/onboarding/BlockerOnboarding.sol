// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {IOnboarding} from "./IOnboarding.sol";

contract BlockerOnboarding {
    function isOnboarded(address, uint256) external pure returns(bool) {
        return false;
    }
}
