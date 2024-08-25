//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {TimeLibrary} from "../libraries/TimeLibrary.sol";
import {TaskManager} from "../tasks/TaskManager.sol";
import {PeriodUtils} from "../utils/PeriodUtils.sol";
import {AccessUtils} from "../utils/AccessUtils.sol";
import {IGlobalParameters} from "../globalParameters/IGlobalParameters.sol";
import {IMembership} from "../membership/IMembership.sol";
import {ITaskManager} from "../tasks/ITaskManager.sol";

contract Participation is Initializable, PeriodUtils, AccessUtils {
    address public globalParameters;
    address public membership;
    address public taskManager;

    struct MemberParticipation {
        uint128 score;
        uint128 performance;
    }
    mapping(address who => mapping(uint32 periodId => MemberParticipation)) public memberParticipations;

    error NotMember();
    error InvalidCommitment();

    function initialize(
        address _globalParameters,
        address _membership,
        address _taskManager,
        address _hub,
        address _autId,
        uint32 _period0Start,
        uint32 _initPeriodId
    ) external initializer {
        globalParameters = _globalParameters;
        membership = _membership;
        taskManager = _taskManager;

        _init_AccessUtils({_hub: _hub, _autId: _autId});
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

    function _calcPerformanceInPeriod(
        uint32 commitment,
        uint128 pointsGiven,
        uint32 periodId
    ) internal view returns (uint128) {
        uint128 expectedContributionPoints = _calcExpectedContributionPoints({
            commitment: commitment,
            periodId: periodId
        });
        uint128 performance = (1e18 * pointsGiven) / expectedContributionPoints;
        return performance;
    }

    /// @dev returned with 1e18 precision
    function calcPerformanceInPeriod(address who, uint32 periodId) public view returns (uint128) {
        if (!IMembership(membership).isMember(who)) revert NotMember();
        if (periodId < IMembership(membership).getPeriodIdJoined(who) || periodId > currentPeriodId())
            revert InvalidPeriodId();
        return _calcPerformanceInPeriod(who, periodId);
    }

    function _calcPerformanceInPeriod(address who, uint32 periodId) internal view returns (uint128) {
        return
            _calcPerformanceInPeriod({
                commitment: IMembership(membership).getCommitment(who, periodId),
                pointsGiven: ITaskManager(taskManager).getMemberPointsGiven(who, periodId),
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
        uint256 numScaled = 1e18 * uint256(commitment) * ITaskManager(taskManager).getPointsActive(periodId);
        uint256 expectedContributionPoints = numScaled / commitmentSum(periodId) / 1e18;
        return uint128(expectedContributionPoints);
    }

    function commitmentSum(uint32 periodId) internal view returns (uint128) {
        return IMembership(membership).commitmentSums(periodId);
    }

    function writeMemberParticipations(address[] calldata whos) external {
        // update historical periods if necessary
        ITaskManager(taskManager).writePointSummary();

        uint32 currentPeriodId_ = currentPeriodId();
        for (uint256 i = 0; i < whos.length; i++) {
            _writeMemberParticipation(whos[i], currentPeriodId_);
        }
    }

    /// @notice off-chain helper to check which members to write participation score to
    function getMembersToWriteMemberParticipation(uint32 periodId) external view returns (address[] memory) {
        uint256 numMembersToWrite = 0;
        address[] memory members = IMembership(membership).members();
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
        ITaskManager(taskManager).writePointSummary();

        _writeMemberParticipation(who, currentPeriodId());
    }

    // TODO: visibility?
    function _writeMemberParticipation(address who, uint32 _currentPeriodId) public {
        // TODO: algorithm
        // NOTE: in periodIdJoined, participation score is default 100.  Only write to following periods
        uint32 periodIdJoined = IMembership(membership).getPeriodIdJoined(who);

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
            MemberParticipation storage participation = memberParticipations[who][i];
            uint128 performance = _calcPerformanceInPeriod({
                commitment: IMembership(membership).getCommitment({who: who, periodId: i}),
                pointsGiven: ITaskManager(taskManager).getMemberPointsGiven(who, i),
                periodId: i
            });

            uint128 delta;
            uint128 factor;
            uint128 score;
            // TODO: precision
            if (performance > 1e18) {
                // exceeded expectations: raise participation score
                delta = performance - 1e18;
                factor = constraintFactor();
                if (delta > factor) delta = factor;
                score = (previousScore * (1e18 + delta)) / delta;
            } else {
                // underperformed: lower participation score
                delta = 1e18 - performance;
                factor = penaltyFactor();
                if (delta > factor) delta = factor;
                score = (previousScore * (1e18 - delta)) / delta;
            }

            // write to storage
            participation.score = score;
            participation.performance = performance;

            // overwrite previousScore to use for the next period if needed
            previousScore = score;
        }
    }

    function constraintFactor() public view returns (uint128) {
        return IGlobalParameters(hub()).constraintFactor();
    }

    function penaltyFactor() public view returns (uint128) {
        return IGlobalParameters(hub()).penaltyFactor();
    }
}
