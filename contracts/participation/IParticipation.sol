//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;


struct MemberParticipation {
    uint128 score;
    uint128 performance;
}

interface IParticipation {
    error InvalidCommitment();

    function initialize(
        address _globalParameters,
        address _membership,
        address _taskManager,
        address _hub,
        address _autId,
        uint32 _period0Start,
        uint32 _initPeriodId
    ) external;

    function join(address who) external;

    function calcPerformanceInPeriod(
        uint32 commitment,
        uint128 pointsGiven,
        uint32 periodId
    ) external view returns (uint128);
    function calcPerformancesInPeriod(
        uint32[] calldata commitments,
        uint128[] calldata pointsGiven,
        uint32 periodId
    ) external view returns (uint128[] memory);

    function calcPerformanceInPeriod(address who, uint32 periodId) external view returns (uint128);
    function calcPerformanceInPeriods(address who, uint32[] calldata periodIds) external view returns (uint128[] memory);
    function calcPerformancesInPeriod(address[] calldata whos, uint32 periodId) external view returns (uint128[] memory);

    function calcExpectedPoints(uint32 commitment, uint32 periodId) external view returns (uint128);
    function calcsExpectedPoints(uint32[] calldata commitments, uint32[] calldata periodIds) external view returns (uint128[] memory);

    function fractionalCommitment(uint32 commitment, uint32 periodId) external view returns (uint128);
    function fractionalsCommitments(uint32[] calldata commitments, uint32[] calldata periodIds) external view returns (uint128[] memory);

    function getMembersToWriteMemberParticipation(uint32 periodId) external view returns (address[] memory);
    function writeMemberParticipation(address who) external;
    function writeMemberParticipations(address[] calldata whos) external;
}
