//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface ITaskManager {
    function writePointSummary() external;
    function join(address who) external;

    function initialize(address _hub, address _autId, uint32 _period0Start, uint32 _initPeriodId) external;

    function getPointsActive(uint32 periodId) external view returns (uint128);
    function getPointsGiven(uint32 periodId) external view returns (uint128);
    function getMemberPointsGiven(address who, uint32 periodId) external view returns (uint128);
}
