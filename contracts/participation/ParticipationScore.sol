//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {TimeLibrary} from "../libraries/TimeLibrary.sol";

contract ParticipationScore is Initializable {
    address public globalParameters;
    address public hub;
    address public membership;
    address public taskManager;
    address public rgn;

    constructor() {
        _disableInitializers();
    }

    struct Participation {
        uint128 score;
        uint128 performance;
    }

    mapping(address who => mapping(uint32 periodId => Participation)) public participations;

    function initialize(
        address _globalParameters,
        address _hub,
        address _membership,
        address _taskManager,
        address _rgn
    ) external initializer {
        globalParameters = _globalParameters;
        hub = _hub;
        membership = _membership;
        taskManager = _taskManager;
        rgn = _rgn;
    }

        /// @notice helper to predict performance score for any user
    function calcPerformanceInPeriod(
        uint32 commitment,
        uint128 givenContributionPoints,
        uint32 periodId
    ) public view returns (uint128) {
        uint32 currentPeriodId = TimeLibrary.periodId({period0Start: period0Start, timestamp: uint32(block.timestamp)});
        if (periodId == 0 || periodId > currentPeriodId) revert InvalidPeriodId();
        return
            _calcPerformanceInPeriod({
                commitment: commitment,
                givenContributionPoints: givenContributionPoints,
                periodId: periodId
            });
    }

    function _calcPerformanceInPeriod(
        uint32 commitment,
        uint128 givenContributionPoints,
        uint32 periodId
    ) internal view returns (uint128) {
        uint128 expectedContributionPoints = _calcExpectedContributionPoints({
            commitment: commitment,
            periodId: periodId
        });
        uint128 performance = (1e18 * givenContributionPoints) / expectedContributionPoints;
        return performance;
    }

    /// @dev returned with 1e18 precision
    function calcPerformanceInPeriod(address who, uint32 periodId) public view returns (uint128) {
        _revertForNotMember(who);
        uint32 currentPeriodId = TimeLibrary.periodId({period0Start: period0Start, timestamp: uint32(block.timestamp)});
        if (periodId == 0 || periodId > currentPeriodId) revert InvalidPeriodId();
        return _calcPerformanceInPeriod(who, periodId);
    }

    function _calcPerformanceInPeriod(address who, uint32 periodId) internal view returns (uint128) {
        return
            _calcPerformanceInPeriod({
                commitment: getCommitment(who, periodId),
                givenContributionPoints: participations[who][periodId].givenContributionPoints,
                periodId: periodId
            });
    }

    // fiCL * TCP
    function calcExpectedContributionPoints(uint32 commitment, uint32 periodId) public view returns (uint128) {
        if (commitment < 1 || commitment > 10) revert InvalidCommitment();
        uint32 currentPeriodId = TimeLibrary.periodId({period0Start: period0Start, timestamp: uint32(block.timestamp)});
        if (periodId == 0 || periodId > currentPeriodId) revert InvalidPeriodId();
        return _calcExpectedContributionPoints(commitment, periodId);
    }

    function _calcExpectedContributionPoints(uint32 commitment, uint32 periodId) internal view returns (uint128) {
        PeriodSummary memory periodSummary = periodSummaries[periodId];
        uint256 numScaled = 1e18 * uint256(commitment) * periodSummary.sumActiveContributionPoints;
        uint256 expectedContributionPoints = numScaled / periodSummary.sumCommitment / 1e18;
        return uint128(expectedContributionPoints);
    }

        function writeParticipations(address[] calldata whos) external {
        // update historical periods if necessary
        uint32 currentPeriodId = TimeLibrary.periodId({period0Start: period0Start, timestamp: uint32(block.timestamp)});
        _writePeriodSummary(currentPeriodId);

        for (uint256 i = 0; i < whos.length; i++) {
            _writeParticipation(whos[i], currentPeriodId);
        }
    }

    function writeParticipation(address who) external {
        // update historical periods if necessary
        uint32 currentPeriodId = TimeLibrary.periodId({period0Start: period0Start, timestamp: uint32(block.timestamp)});
        _writePeriodSummary(currentPeriodId);

        _writeParticipation(who, currentPeriodId);
    }

    // TODO: visibility?
    function _writeParticipation(address who, uint32 currentPeriodId) public {
        // TODO: algorithm
        // NOTE: in periodIdJoined, participation score is default 100.  Only write to following periods
        uint32 periodIdJoined = getPeriodIdJoined(who);

        // We are only writing to the last period which has ended: ie, currentPeriodId - 1
        uint32 periodToStartWrite;
        for (uint32 i = currentPeriodId - 1; i > periodIdJoined; i--) {
            // loop through passed periods and find the oldest period where participation has not yet been written
            if (participations[who][i].score == 0) {
                periodToStartWrite = i;
            } else {
                // we have reached the end of 0 values
                break;
            }
        }

        // return if there is nothing to write
        if (periodToStartWrite == 0) return;

        // Get previous period participation score to use as a starting weight
        uint96 previousScore = participations[who][periodToStartWrite - 1].score;

        // Start at the first empty period and write the participation score given the previous score and c
        // TODO: c from globalParameters
        uint96 constraintFactor = 4e17; // 40%
        uint96 penaltyFactor = 4e17; // 40%
        for (uint32 i = periodToStartWrite; i < currentPeriodId; i++) {
            Participation storage participation = participations[who][i];
            uint128 performance = _calcPerformanceInPeriod({
                commitment: getCommitment({who: who, periodId: i}),
                givenContributionPoints: participation.givenContributionPoints,
                periodId: i
            });

            uint96 delta;
            uint96 score;
            // TODO: precision
            if (performance > 1e18) {
                // exceeded expectations: raise participation score
                delta = uint96(performance) - 1e18;
                if (delta > constraintFactor) delta = constraintFactor;
                score = (previousScore * (1e18 + delta)) / delta;
            } else {
                // underperformed: lower participation score
                delta = 1e18 - uint96(performance);
                if (delta > penaltyFactor) delta = penaltyFactor;
                score = (previousScore * (1e18 - delta)) / delta;
            }

            // write to storage
            participation.score = score;
            participation.performance = performance;

            // overwrite previousScore to use for the next period if needed
            previousScore = score;
        }
    }


}