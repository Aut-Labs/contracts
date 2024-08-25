//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IPeriodUtils {
    function currentPeriodId() external view returns (uint32 periodId);
    function getPeriodId(uint32 timestamp) external view returns (uint32 periodId);
}
