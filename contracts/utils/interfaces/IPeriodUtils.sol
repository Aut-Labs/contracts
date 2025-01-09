//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IPeriodUtils {
    /// @notice Get the start time of the curent period
    function currentPeriodStart() external view returns (uint32);

    /// @notice Get the end time of the current period
    function currentPeriodEnd() external view returns (uint32);

    /// @notice Get the current period id (starting at 1)
    function currentPeriodId() external view returns (uint32);

    /// @notice Get the start time of a period which contains the timestamp
    function periodStart(uint32 timestamp) external view returns (uint32);

    /// @notice Get the end time of a period which contains the timestamp
    function periodEnd(uint32 timestamp) external view returns (uint32);

    /// @notice Get the period id for a given timestamp
    function periodId(uint32 timestamp) external view returns (uint32);

    /// @notice Get the timestamp of hub creation
    function initTimestamp() external view returns (uint32);
}
