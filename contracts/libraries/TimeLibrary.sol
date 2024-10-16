//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library TimeLibrary {
    uint32 internal constant WEEK = 7 days;
    uint32 internal constant FOUR_WEEKS = 28 days;

    /// @notice Round down the timestamp passed to the start of the period
    function periodStart(uint32 timestamp) internal pure returns (uint32) {
        unchecked {
            return timestamp - (timestamp % FOUR_WEEKS);
        }
    }

    /// @notice Round up the timestamp passed to the end of the period
    function periodEnd(uint32 timestamp) internal pure returns (uint32) {
        unchecked {
            return periodStart({timestamp: timestamp}) + FOUR_WEEKS;
        }
    }

    /// @dev returns the id of the current period, starting at 1
    function periodId(uint32 period0Start, uint32 timestamp) internal pure returns (uint32) {
        unchecked {
            return (((periodStart({timestamp: timestamp}) - period0Start) / FOUR_WEEKS) + 1);
        }
    }
}
