//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library TimeLibrary {
    uint32 internal constant WEEK = 7 days;
    uint32 internal constant FOUR_WEEKS = 28 days;

    /// @notice Round down the timestamp passed to the start of the period
    function periodStart(uint32 currentTimestamp, uint32 initTimestamp) internal pure returns (uint32) {
        return initTimestamp + numPeriodsCompleted(currentTimestamp, initTimestamp) * FOUR_WEEKS;
    }

    function periodEnd(uint32 currentTimestamp, uint32 initTimestamp) internal pure returns (uint32) {
        return periodStart(currentTimestamp, initTimestamp) + FOUR_WEEKS;
    }

    /// @dev returns the number of full periods betwen the init and current time
    function numPeriodsCompleted(uint32 currentTimestamp, uint32 initTimestamp) internal pure returns (uint32) {
        return (currentTimestamp - initTimestamp) / FOUR_WEEKS;
    }

    /// @dev returns the id of the current period, starting at 1
    function periodId(uint32 currentTimestamp, uint32 initTimestamp) internal pure returns (uint32) {
        return numPeriodsCompleted(currentTimestamp, initTimestamp) + 1;
    }
}
