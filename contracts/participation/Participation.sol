//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {TimeLibrary} from "../libraries/TimeLibrary.sol";
import {TaskManager} from "../tasks/TaskManager.sol";
import {PeriodUtils} from "../utils/PeriodUtils.sol";
import {AccessUtils} from "../utils/AccessUtils.sol";
import {IGlobalParameters} from "../globalParameters/IGlobalParameters.sol";
import {IMembership} from "../membership/IMembership.sol";
import {ITaskManager} from "../tasks/interfaces/ITaskManager.sol";
import {IParticipation, MemberParticipation} from "./IParticipation.sol";

contract Participation is IParticipation, Initializable, PeriodUtils, AccessUtils {
    mapping(address who => mapping(uint32 periodId => MemberParticipation)) public memberParticipations;

    function initialize(address _hub, uint32 _period0Start, uint32 _initPeriodId) external initializer {
        _init_AccessUtils({_hub: _hub, _autId: address(0)});
        _init_PeriodUtils({_period0Start: _period0Start, _initPeriodId: _initPeriodId});
    }

    function join(address who) external {
        _revertIfNotHub();

        // store initial participation
        memberParticipations[who][currentPeriodId()] = MemberParticipation({score: 1e18, performance: 0});
    }

    /// @notice helper to predict performance score for any user
    function calcPerformanceInPeriod(
        uint32 commitment,
        uint128 pointsGiven,
        uint32 periodId
    ) public view returns (uint128) {
        if (periodId < initPeriodId() || periodId > currentPeriodId()) revert InvalidPeriodId();
        return _calcPerformanceInPeriod({commitment: commitment, pointsGiven: pointsGiven, periodId: periodId});
    }

    function calcPerformancesInPeriod(
        uint32[] calldata commitments,
        uint128[] calldata pointsGiven,
        uint32 periodId
    ) external view returns (uint128[] memory) {
        uint256 length = commitments.length;
        uint128[] memory performances = new uint128[](length);
        for (uint256 i = 0; i < length; i++) {
            performances[i] = calcPerformanceInPeriod({
                commitment: commitments[i],
                pointsGiven: pointsGiven[i],
                periodId: periodId
            });
        }
        return performances;
    }

    function _calcPerformanceInPeriod(
        uint32 commitment,
        uint128 pointsGiven,
        uint32 periodId
    ) internal view returns (uint128) {
        uint128 expectedContributionPoints = _calcExpectedPoints({commitment: commitment, periodId: periodId});
        uint128 performance = (1e18 * pointsGiven) / expectedContributionPoints;
        return performance;
    }

    /// @dev returned with 1e18 precision
    function calcPerformanceInPeriod(address who, uint32 periodId) public view returns (uint128) {
        _revertIfNotMember(who);
        if (periodId < IMembership(membership()).getPeriodIdJoined(who) || periodId > currentPeriodId())
            revert InvalidPeriodId();
        return _calcPerformanceInPeriod(who, periodId);
    }

    function calcPerformanceInPeriods(
        address who,
        uint32[] calldata periodIds
    ) external view returns (uint128[] memory) {
        uint256 length = periodIds.length;
        uint128[] memory performances = new uint128[](length);
        for (uint256 i = 0; i < length; i++) {
            performances[i] = calcPerformanceInPeriod({who: who, periodId: periodIds[i]});
        }
        return performances;
    }

    function calcPerformancesInPeriod(
        address[] calldata whos,
        uint32 periodId
    ) external view returns (uint128[] memory) {
        uint256 length = whos.length;
        uint128[] memory performances = new uint128[](length);
        for (uint256 i = 0; i < length; i++) {
            performances[i] = calcPerformanceInPeriod({who: whos[i], periodId: periodId});
        }
        return performances;
    }

    function _calcPerformanceInPeriod(address who, uint32 periodId) internal view returns (uint128) {
        return
            _calcPerformanceInPeriod({
                commitment: IMembership(membership()).getCommitment(who, periodId),
                pointsGiven: ITaskManager(taskManager()).getMemberPointsGiven(who, periodId),
                periodId: periodId
            });
    }

    // fiCL * TCP
    function calcExpectedPoints(uint32 commitment, uint32 periodId) public view returns (uint128) {
        if (commitment < 1 || commitment > 10) revert InvalidCommitment();
        if (periodId == 0 || periodId > currentPeriodId()) revert InvalidPeriodId();
        return _calcExpectedPoints(commitment, periodId);
    }

    function calcsExpectedPoints(
        uint32[] calldata commitments,
        uint32[] calldata periodIds
    ) external view returns (uint128[] memory) {
        uint256 length = commitments.length;
        require(length == periodIds.length);
        uint128[] memory eps = new uint128[](length);
        for (uint256 i = 0; i < length; i++) {
            eps[i] = calcExpectedPoints({commitment: commitments[i], periodId: periodIds[i]});
        }
        return eps;
    }

    function _calcExpectedPoints(uint32 commitment, uint32 periodId) internal view returns (uint128) {
        return
            (fractionalCommitment({commitment: commitment, periodId: periodId}) *
                ITaskManager(taskManager()).getPointsActive(periodId)) / 1e18;
    }

    function fractionalCommitment(uint32 commitment, uint32 periodId) public view returns (uint128) {
        return (1e18 * uint128(commitment)) / commitmentSum(periodId);
    }

    function fractionalsCommitments(
        uint32[] calldata commitments,
        uint32[] calldata periodIds
    ) external view returns (uint128[] memory) {
        uint256 length = commitments.length;
        require(length == periodIds.length);
        uint128[] memory fcs = new uint128[](length);
        for (uint256 i = 0; i < length; i++) {
            fcs[i] = fractionalCommitment({commitment: commitments[i], periodId: periodIds[i]});
        }
        return fcs;
    }

    function commitmentSum(uint32 periodId) internal view returns (uint128) {
        return IMembership(membership()).commitmentSums(periodId);
    }

    /// @notice off-chain helper to check which members to write participation score to
    // TODO: seal member participation if all written?
    function getMembersToWriteMemberParticipation(uint32 periodId) external view returns (address[] memory) {
        uint256 numMembersToWrite = 0;
        address[] memory members = IMembership(membership()).members();
        uint256 length = members.length;
        address[] memory membersCopy = new address[](length);
        for (uint256 i = 0; i < length; i++) {
            address member = members[i];
            if (memberParticipations[member][periodId].score == 0) {
                membersCopy[numMembersToWrite++] = member;
            }
        }

        address[] memory arrMembersToWrite = new address[](numMembersToWrite);
        for (uint256 i = 0; i < numMembersToWrite; i++) {
            arrMembersToWrite[i] = membersCopy[i];
        }
        return arrMembersToWrite;
    }

    function writeMemberParticipation(address who) external {
        // update historical periods if necessary
        ITaskManager(taskManager()).writePointSummary();

        _writeMemberParticipation(who, currentPeriodId());
    }

    function writeMemberParticipations(address[] calldata whos) external {
        // update historical periods if necessary
        ITaskManager(taskManager()).writePointSummary();

        uint32 currentPeriodId_ = currentPeriodId();
        for (uint256 i = 0; i < whos.length; i++) {
            _writeMemberParticipation(whos[i], currentPeriodId_);
        }
    }

    // TODO: visibility?
    function _writeMemberParticipation(address who, uint32 _currentPeriodId) internal {
        // TODO: algorithm
        // NOTE: in periodIdJoined, participation score is default 100.  Only write to following periods
        uint32 periodIdJoined = IMembership(membership()).getPeriodIdJoined(who);

        // We are only writing to the last period which has ended: ie, _currentPeriodId - 1
        uint32 periodToStartWrite;
        for (uint32 i = _currentPeriodId - 1; i > periodIdJoined; i--) {
            // loop through passed periods and find the oldest period where participation has not yet been written
            if (memberParticipations[who][i].score == 0) {
                periodToStartWrite = i;
            } else {
                // we have reached the end of 0 values
                break;
            }
        }

        // return if there is nothing to write
        if (periodToStartWrite == 0) return;

        // Get previous period participation score to use as a starting weight
        uint128 previousScore = memberParticipations[who][periodToStartWrite - 1].score;

        // Start at the first empty period and write the participation score given the previous score and c
        for (uint32 i = periodToStartWrite; i < _currentPeriodId; i++) {
            MemberParticipation storage memberParticipation = memberParticipations[who][i];
            uint128 performance = _calcPerformanceInPeriod({
                commitment: IMembership(membership()).getCommitment({who: who, periodId: i}),
                pointsGiven: ITaskManager(taskManager()).getMemberPointsGiven(who, i),
                periodId: i
            });

            uint128 delta;
            uint128 factor;
            uint128 score;
            // TODO: precision
            if (performance > 1e18) {
                // exceeded expectations: raise memberParticipation score
                delta = performance - 1e18;
                factor = constraintFactor();
                if (delta > factor) delta = factor;
                score = (previousScore * (1e18 + delta)) / delta;
            } else {
                // underperformed: lower memberParticipation score
                delta = 1e18 - performance;
                factor = penaltyFactor();
                if (delta > factor) delta = factor;
                score = (previousScore * (1e18 - delta)) / delta;
            }

            // write to storage
            memberParticipation.score = score;
            memberParticipation.performance = performance;

            // overwrite previousScore to use for the next period if needed
            previousScore = score;
        }
    }

    // TODO: make these configurable

    function constraintFactor() public view returns (uint128) {
        return IGlobalParameters(hub()).constraintFactor();
    }

    function penaltyFactor() public view returns (uint128) {
        return IGlobalParameters(hub()).penaltyFactor();
    }
}
