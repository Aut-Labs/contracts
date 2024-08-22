//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {TimeLibrary} from "../libraries/TimeLibrary.sol";
import {TaskManager} from "../tasks/TaskManager.sol";
import {Membership} from "../membership/Membership.sol";
import {PeriodUtils} from "../utils/PeriodUtils.sol";
import {AccessUtils} from "../utils/AccessUtils.sol";
import {IGlobalParametersAlpha} from "../globalParameters/IGlobalParametersAlpha.sol";

contract ParticipationScore is PeriodUtils, AccessUtils, Initializable, TaskManager, Membership {

    address public globalParameters;

    struct Participation {
        uint128 score;
        uint128 performance;
    }
    mapping(address who => mapping(uint32 periodId => Participation)) public participations;

    error NotMember();
    error InvalidCommitment();

    function initialize(
        address _globalParameters,
        address _hub,
        address _autId,
        uint32 _period0Start,
        uint32 _initPeriodId
    ) external initializer {
        globalParameters = _globalParameters;

        _init_AccessUtils({_hub: _hub, _autId: _autId});
        _init_PeriodUtils({_period0Start: _period0Start, _initPeriodId: _initPeriodId});
    }

    function join(address who, uint256 role, uint8 commitment) public override {
        // Call join of membership
        super.join();
        
        // store initial participation
        participations[who][currentPeriodId()] = Participation({
            score: 1e18,
            performance: 0
        });
    }

    /// @notice helper to predict performance score for any user
    function calcPerformanceInPeriod(
        uint32 commitment,
        uint128 givenContributionPoints,
        uint32 periodId
    ) public view returns (uint128) {
        if (periodId == 0 < initPeriodId || periodId > currentPeriodId()) revert InvalidPeriodId();
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
        if (!isMember(who)) revert NotMember();
        if (periodId < getPeriodId(who) || periodId > currentPeriodId()) revert InvalidPeriodId();
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
        if (periodId == 0 || periodId > currentPeriodId()) revert InvalidPeriodId();
        return _calcExpectedContributionPoints(commitment, periodId);
    }

    function _calcExpectedContributionPoints(uint32 commitment, uint32 periodId) internal view returns (uint128) {
        uint256 numScaled = 1e18 * uint256(commitment) * pointSummaries[periodId].pointsActive;
        uint256 expectedContributionPoints = numScaled / commitmentSum[periodId] / 1e18;
        return uint128(expectedContributionPoints);
    }

    function writeParticipations(address[] calldata whos) external {
        // update historical periods if necessary
        uint32 currentPeriodId_ = currentPeriodId();
        _writePointSummary(currentPeriodId_);

        for (uint256 i = 0; i < whos.length; i++) {
            _writeParticipation(whos[i], currentPeriodId_);
        }
    }

    // function getMembersToWriteParticipation(uint32 periodId) external view returns (address[] memory) {
    //     uint256 numMembersToWrite = 0;
    //     uint256 length = members.length;
    //     address[] memory membersCopy = new address[](length);
    //     for (uint256 i = 0; i < length; i++) {
    //         address member = members[i];
    //         if (participations[member][periodId].score == 0) {
    //             membersCopy[numMembersToWrite++] = member;
    //         }
    //     }

    //     address[] memory arrMembersToWrite = new address[](numMembersToWrite);
    //     for (uint256 i = 0; i < numMembersToWrite; i++) {
    //         arrMembersToWrite[i] = membersCopy[i];
    //     }
    //     return arrMembersToWrite;
    // }

    function writeParticipation(address who) external {
        // update historical periods if necessary
        uint32 currentPeriodId_ = currentPeriodId();
        _writePointSummary(currentPeriodId_);

        _writeParticipation(who, currentPeriodId_);
    }

    // TODO: visibility?
    function _writeParticipation(address who, uint32 _currentPeriodId) public {
        // TODO: algorithm
        // NOTE: in periodIdJoined, participation score is default 100.  Only write to following periods
        uint32 periodIdJoined = getPeriodIdJoined(who);

        // We are only writing to the last period which has ended: ie, _currentPeriodId - 1
        uint32 periodToStartWrite;
        for (uint32 i = _currentPeriodId - 1; i > periodIdJoined; i--) {
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
        for (uint32 i = periodToStartWrite; i < _currentPeriodId; i++) {
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
                if (delta > constraintFactor()) delta = constraintFactor;
                score = (previousScore * (1e18 + delta)) / delta;
            } else {
                // underperformed: lower participation score
                delta = 1e18 - uint96(performance);
                if (delta > penaltyFactor()) delta = penaltyFactor;
                score = (previousScore * (1e18 - delta)) / delta;
            }

            // write to storage
            participation.score = score;
            participation.performance = performance;

            // overwrite previousScore to use for the next period if needed
            previousScore = score;
        }
    }

    function constraintFactor() public view returns (uint96) {
        return IGlobalParametersAlpha(hub()).constraintFactor();
    }

    function penaltyFactor() public view returns (uint96) {
        return IGlobalParametersAlpha(hub()).penaltyFactor();
    }
}