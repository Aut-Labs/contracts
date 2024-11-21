//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

struct MemberParticipation {
    uint128 score;
    uint128 performance;
}

interface IParticipationScore {
    error InvalidCommitment();
    error InvalidPeriodId();

    /// @notice called when a member joins a hub
    function join(address who) external;

    /// @notice helper to predict performance score for any member
    function calcPerformanceInPeriod(
        uint32 commitment,
        uint128 pointsGiven,
        uint32 period
    ) external view returns (uint128);

    /// @notice helper to predict performance score for any members
    function calcPerformancesInPeriod(
        uint32[] calldata commitments,
        uint128[] calldata pointsGiven,
        uint32 period
    ) external view returns (uint128[] memory);

    /// @notice Calculate the performance score for a member of a given period
    /// @dev returns with 1e18 precision
    function calcPerformanceInPeriod(address who, uint32 period) external view returns (uint128);

    /// @notice Calculate the performance score for a member of a given array of periods
    function calcPerformanceInPeriods(address who, uint32[] calldata periods) external view returns (uint128[] memory);

    /// @notice Calculate the performance score for an array of members of a given period
    function calcPerformancesInPeriod(address[] calldata whos, uint32 period) external view returns (uint128[] memory);

    /// @notice calculate the fractional commitment * total points active in a period
    function calcExpectedPoints(uint32 commitment, uint32 period) external view returns (uint128);

    /// @notice Calculate an array of fractional commitments * total points active for an array of periods
    function calcsExpectedPoints(
        uint32[] calldata commitments,
        uint32[] calldata periods
    ) external view returns (uint128[] memory);

    /// @notice Calculate the percentage a commitment is to the whole of the hub for a period
    function fractionalCommitment(uint32 commitment, uint32 period) external view returns (uint128);

    /// @notice Calculate an array of percentages of commitments are to the whole of the hub for an array of periods
    function fractionalsCommitments(
        uint32[] calldata commitments,
        uint32[] calldata periods
    ) external view returns (uint128[] memory);

    /// @notice off-chain helper to check which members to write historical participation score to
    function getMembersToWriteMemberParticipation(uint32 period) external view returns (address[] memory);

    /// @notice write the historical participation (score and performance) of a member to storage
    function writeMemberParticipation(address who) external;

    /// @notice write the historical participation (score and performance) of an array of members to storage
    function writeMemberParticipations(address[] calldata whos) external;

    /// @notice The constraint factor applied to a members score
    /// @dev defaults to the global constraint factor (set in GlobalParameters) if not set in the hub
    function constraintFactor() external view returns (uint128);

    /// @notice the penalty factor applied to a members score
    /// @dev defaults to the global penalty factor (set in GlobalParameters) if not set in the hub
    function penaltyFactor() external view returns (uint128);
}
