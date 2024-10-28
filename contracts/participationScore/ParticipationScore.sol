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
import {IParticipationScore, MemberParticipation} from "./IParticipationScore.sol";

contract ParticipationScore is IParticipationScore, Initializable, PeriodUtils, AccessUtils {
    struct ParticipationScoreStorage {
        mapping(address who => mapping(uint32 periodId => MemberParticipation)) memberParticipations;
    }

    // keccak256(abi.encode(uint256(keccak256("aut.storage.ParticipationScore")) - 1))
    bytes32 private constant ParticipationScoreStorageLocation =
        0x5466d550951de733d9f954489dbcc381088fa34c16e4ea6d7884e8847b39ab74;

    function _getParticipationScoreStorage() private pure returns (ParticipationScoreStorage storage $) {
        assembly {
            $.slot := ParticipationScoreStorageLocation
        }
    }

    function version() external view returns (uint256 major, uint256 minor, uint256 patch) {
        return (0, 1, 0);
    }

    constructor() {
        _disableInitializers();
    }

    function initialize(address _hub, uint32 _period0Start, uint32 _initPeriodId) external initializer {
        _init_AccessUtils({_hub: _hub, _autId: address(0)});
        _init_PeriodUtils({_period0Start: _period0Start, _initPeriodId: _initPeriodId});
    }

    /// @inheritdoc IParticipationScore
    function join(address who) external {
        _revertIfNotHub();

        ParticipationScoreStorage storage $ = _getParticipationScoreStorage();

        // store initial participation
        $.memberParticipations[who][currentPeriodId()] = MemberParticipation({score: 1e18, performance: 0});
    }

    function memberParticipations(address who, uint32 periodId) external view returns (MemberParticipation memory) {
        ParticipationScoreStorage storage $ = _getParticipationScoreStorage();
        return $.memberParticipations[who][periodId];
    }

    /// @inheritdoc IParticipationScore
    function calcPerformanceInPeriod(
        uint32 commitment,
        uint128 pointsGiven,
        uint32 periodId
    ) public view returns (uint128) {
        if (periodId < initPeriodId() || periodId > currentPeriodId()) revert InvalidPeriodId();
        return _calcPerformanceInPeriod({commitment: commitment, pointsGiven: pointsGiven, periodId: periodId});
    }

    /// @inheritdoc IParticipationScore
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

    /// @inheritdoc IParticipationScore
    function calcPerformanceInPeriod(address who, uint32 periodId) public view returns (uint128) {
        _revertIfNotMember(who);
        if (periodId < IMembership(membership()).getPeriodIdJoined(who) || periodId > currentPeriodId())
            revert InvalidPeriodId();
        return _calcPerformanceInPeriod(who, periodId);
    }

    /// @inheritdoc IParticipationScore
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

    /// @inheritdoc IParticipationScore
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

    /// @inheritdoc IParticipationScore
    function calcExpectedPoints(uint32 commitment, uint32 periodId) public view returns (uint128) {
        if (commitment < 1 || commitment > 10) revert InvalidCommitment();
        if (periodId == 0 || periodId > currentPeriodId()) revert InvalidPeriodId();
        return _calcExpectedPoints(commitment, periodId);
    }

    /// @inheritdoc IParticipationScore
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

    /// @inheritdoc IParticipationScore
    function fractionalCommitment(uint32 commitment, uint32 periodId) public view returns (uint128) {
        return (1e18 * uint128(commitment)) / IMembership(membership()).getCommitmentSum(periodId);
    }

    /// @inheritdoc IParticipationScore
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

    // TODO: seal member participation if all written?
    /// @inheritdoc IParticipationScore
    function getMembersToWriteMemberParticipation(uint32 periodId) external view returns (address[] memory) {
        ParticipationScoreStorage storage $ = _getParticipationScoreStorage();
        uint256 numMembersToWrite = 0;
        address[] memory members = IMembership(membership()).members();
        uint256 length = members.length;
        address[] memory membersCopy = new address[](length);

        for (uint256 i = 0; i < length; i++) {
            address member = members[i];
            if ($.memberParticipations[member][periodId].score == 0) {
                membersCopy[numMembersToWrite++] = member;
            }
        }

        address[] memory arrMembersToWrite = new address[](numMembersToWrite);
        for (uint256 i = 0; i < numMembersToWrite; i++) {
            arrMembersToWrite[i] = membersCopy[i];
        }
        return arrMembersToWrite;
    }

    /// @inheritdoc IParticipationScore
    function writeMemberParticipation(address who) external {
        // update historical periods if necessary
        ITaskManager(taskManager()).writePointSummary();

        _writeMemberParticipation(who, currentPeriodId());
    }

    /// @inheritdoc IParticipationScore
    function writeMemberParticipations(address[] calldata whos) external {
        // update historical periods if necessary
        ITaskManager(taskManager()).writePointSummary();

        uint32 currentPeriodId_ = currentPeriodId();
        for (uint256 i = 0; i < whos.length; i++) {
            _writeMemberParticipation(whos[i], currentPeriodId_);
        }
    }

    function _writeMemberParticipation(address who, uint32 _currentPeriodId) internal {
        ParticipationScoreStorage storage $ = _getParticipationScoreStorage();

        // NOTE: in periodIdJoined, participation score is default 100.  Only write to following periods
        uint32 periodIdJoined = IMembership(membership()).getPeriodIdJoined(who);

        // We are only writing to the last period which has ended: ie, _currentPeriodId - 1
        uint32 periodToStartWrite;
        for (uint32 i = _currentPeriodId - 1; i > periodIdJoined; i--) {
            // loop through passed periods and find the oldest period where participation has not yet been written
            if ($.memberParticipations[who][i].score == 0) {
                periodToStartWrite = i;
            } else {
                // we have reached the end of 0 values
                break;
            }
        }

        // return if there is nothing to write
        if (periodToStartWrite == 0) return;

        // Get previous period participation score to use as a starting weight
        uint128 previousScore = $.memberParticipations[who][periodToStartWrite - 1].score;

        // Start at the first empty period and write the participation score given the previous score and c
        for (uint32 i = periodToStartWrite; i < _currentPeriodId; i++) {
            MemberParticipation storage memberParticipation = $.memberParticipations[who][i];
            uint128 performance = _calcPerformanceInPeriod({
                commitment: IMembership(membership()).getCommitment({who: who, periodId: i}),
                pointsGiven: ITaskManager(taskManager()).getMemberPointsGiven(who, i),
                periodId: i
            });

            uint128 delta;
            uint128 factor;
            uint128 score;

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

    /// @inheritdoc IParticipationScore
    function constraintFactor() public view returns (uint128) {
        return IGlobalParameters(hub()).constraintFactor();
    }

    /// @inheritdoc IParticipationScore
    function penaltyFactor() public view returns (uint128) {
        return IGlobalParameters(hub()).penaltyFactor();
    }
}
