// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {TokenVesting} from "./TokenVesting.sol";

contract Team is TokenVesting {
    // settings for this vesting contract

    // max amount to vest in this contract
    uint256 constant TOTAL_VEST_AMOUNT = 5000000 ether; // may not be needed as we're using the balance to check this in TokenVesting
    // duration of the vesting period in seconds
    uint256 constant DURATION = 6 * 30 days; // 6 months
    // duration of a slice period for the vesting in seconds
    uint256 constant RELEASE_INTERVAL = 30 days;
    // whether or not the vesting is revocable
    bool constant REVOCABLE = true;

    constructor(address token_, address _owner) TokenVesting(token_, _owner, DURATION, RELEASE_INTERVAL, REVOCABLE) {}
}
