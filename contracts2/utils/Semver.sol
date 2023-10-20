// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

contract Semver {
    uint8 public immutable major;
    uint8 public immutable minor;
    uint8 public immutable patch;

    constructor(uint8 major_, uint8 minor_, uint8 patch_) {
        major = major_;
        minor = minor_;
        patch = patch_;
    }
}
