//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

struct MemberActivity {
    uint128 participationScore;
    uint128 performance;
}

interface IParticipationScore {
    error InvalidCommitment();
    error InvalidPeriodId();

    /// @notice called when a member joins a hub
    function join(address who) external;

    /// @notice helper to predict performance for any member
    function calcPerformanceInPeriod(
        uint32 commitmentLevel,
        uint128 sumPointsGiven,
        uint32 period
    ) external view returns (uint128);

    /// @notice helper to predict performance for any members
    function calcPerformancesInPeriod(
        uint32[] calldata commitments,
        uint128[] calldata sumPointsGiven,
        uint32 period
    ) external view returns (uint128[] memory);

    /// @notice Calculate the performance for a member of a given period
    /// @dev returns with 1e18 precision
    function calcPerformanceInPeriod(address who, uint32 period) external view returns (uint128);

    /// @notice Calculate the performance for a member of a given array of periods
    function calcPerformanceInPeriods(address who, uint32[] calldata periods) external view returns (uint128[] memory);

    /// @notice Calculate the performance for an array of members of a given period
    function calcPerformancesInPeriod(address[] calldata whos, uint32 period) external view returns (uint128[] memory);

    /// @notice calculate the fractional commitmentLevel * total points active in a period
    function calcExpectedContributionPoints(uint32 commitmentLevel, uint32 period) external view returns (uint128);

    /// @notice Calculate an array of fractional commitments * total points active for an array of periods
    function calcsExpectedContributionPoints(
        uint32[] calldata commitments,
        uint32[] calldata periods
    ) external view returns (uint128[] memory);

    /// @notice Calculate the percentage a commitmentLevel is to the whole of the hub for a period
    function fractionalCommitment(uint32 commitmentLevel, uint32 period) external view returns (uint128);

    /// @notice Calculate an array of percentages of commitments are to the whole of the hub for an array of periods
    function fractionalsCommitments(
        uint32[] calldata commitments,
        uint32[] calldata periods
    ) external view returns (uint128[] memory);

    /// @notice off-chain helper to check which members to write member activty score to
    function getMembersToWriteMemberActivity(uint32 period) external view returns (address[] memory);

    /// @notice write the historical activity (score and performance) of a member to storage
    function writeMemberActivity(address who) external;

    /// @notice write the historical activity (score and performance) of an array of members to storage
    function writeMemberActivities(address[] calldata whos) external;

    /// @notice The constraint factor applied to a members score
    /// @dev defaults to the global constraint factor (set in GlobalParameters) if not set in the hub
    function constraintFactor() external view returns (uint128);

    /// @notice the penalty factor applied to a members score
    /// @dev defaults to the global penalty factor (set in GlobalParameters) if not set in the hub
    function penaltyFactor() external view returns (uint128);
}
