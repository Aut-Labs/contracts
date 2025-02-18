// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {TokenVesting} from "./TokenVesting.sol";

contract EarlyContributors is TokenVesting {
    // settings for this vesting contract

    // duration of the vesting period in seconds
    uint256 constant DURATION = 12 * 30 days; // 12 months
    // duration of a slice period for the vesting in seconds
    uint256 constant RELEASE_INTERVAL = 30 days;
    // whether or not the vesting is revocable
    bool constant REVOCABLE = true;

    constructor(address token_, address _owner) TokenVesting(token_, _owner, DURATION, RELEASE_INTERVAL, REVOCABLE) {}
}
