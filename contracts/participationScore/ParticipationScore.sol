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
import {IParticipationScore, MemberActivity} from "./IParticipationScore.sol";

contract ParticipationScore is IParticipationScore, Initializable, PeriodUtils, AccessUtils {
    struct ParticipationScoreStorage {
        mapping(address who => mapping(uint32 period => MemberActivity)) memberActivities;
    }

    // keccak256(abi.encode(uint256(keccak256("aut.storage.ParticipationScore")) - 1))
    bytes32 private constant ParticipationScoreStorageLocation =
        0x5466d550951de733d9f954489dbcc381088fa34c16e4ea6d7884e8847b39ab74;

    function _getParticipationScoreStorage() private pure returns (ParticipationScoreStorage storage $) {
        assembly {
            $.slot := ParticipationScoreStorageLocation
        }
    }

    function version() external pure returns (uint256 major, uint256 minor, uint256 patch) {
        return (0, 1, 0);
    }

    constructor() {
        _disableInitializers();
    }

    function initialize(address _hub) external initializer {
        _init_AccessUtils({_hub: _hub, _autId: address(0)});
        _init_PeriodUtils();
    }

    /// @inheritdoc IParticipationScore
    function join(address who) external {
        _revertIfNotHub();

        ParticipationScoreStorage storage $ = _getParticipationScoreStorage();

        // store initial participation
        $.memberActivities[who][currentPeriodId()] = MemberActivity({participationScore: 1e18, performance: 0});
    }

    function memberActivities(address who, uint32 period) external view returns (MemberActivity memory) {
        ParticipationScoreStorage storage $ = _getParticipationScoreStorage();
        return $.memberActivities[who][period];
    }

    /// @inheritdoc IParticipationScore
    function calcPerformanceInPeriod(
        uint32 commitmentLevel,
        uint128 sumPointsGiven,
        uint32 period
    ) public view returns (uint128) {
        if (period == 0 || period > currentPeriodId()) revert InvalidPeriodId();
        return
            _calcPerformanceInPeriod({
                commitmentLevel: commitmentLevel,
                sumPointsGiven: sumPointsGiven,
                period: period
            });
    }

    /// @inheritdoc IParticipationScore
    function calcPerformancesInPeriod(
        uint32[] calldata commitments,
        uint128[] calldata sumPointsGiven,
        uint32 period
    ) external view returns (uint128[] memory) {
        uint256 length = commitments.length;
        uint128[] memory performances = new uint128[](length);
        for (uint256 i = 0; i < length; i++) {
            performances[i] = calcPerformanceInPeriod({
                commitmentLevel: commitments[i],
                sumPointsGiven: sumPointsGiven[i],
                period: period
            });
        }
        return performances;
    }

    function _calcPerformanceInPeriod(
        uint32 commitmentLevel,
        uint128 sumPointsGiven,
        uint32 period
    ) internal view returns (uint128) {
        uint128 expectedContributionPoints = _calcExpectedContributionPoints({
            commitmentLevel: commitmentLevel,
            period: period
        });
        uint128 performance = (1e18 * sumPointsGiven) / expectedContributionPoints;
        return performance;
    }

    /// @inheritdoc IParticipationScore
    function calcPerformanceInPeriod(address who, uint32 period) public view returns (uint128) {
        _revertIfNotMember(who);
        if (period < IMembership(membership()).getPeriodJoined(who) || period > currentPeriodId())
            revert InvalidPeriodId();
        return _calcPerformanceInPeriod(who, period);
    }

    /// @inheritdoc IParticipationScore
    function calcPerformanceInPeriods(address who, uint32[] calldata periods) external view returns (uint128[] memory) {
        uint256 length = periods.length;
        uint128[] memory performances = new uint128[](length);
        for (uint256 i = 0; i < length; i++) {
            performances[i] = calcPerformanceInPeriod({who: who, period: periods[i]});
        }
        return performances;
    }

    /// @inheritdoc IParticipationScore
    function calcPerformancesInPeriod(address[] calldata whos, uint32 period) external view returns (uint128[] memory) {
        uint256 length = whos.length;
        uint128[] memory performances = new uint128[](length);
        for (uint256 i = 0; i < length; i++) {
            performances[i] = calcPerformanceInPeriod({who: whos[i], period: period});
        }
        return performances;
    }

    function _calcPerformanceInPeriod(address who, uint32 period) internal view returns (uint128) {
        return
            _calcPerformanceInPeriod({
                commitmentLevel: IMembership(membership()).getCommitmentLevel(who, period),
                sumPointsGiven: ITaskManager(taskManager()).getMemberPointsGiven(who, period),
                period: period
            });
    }

    /// @inheritdoc IParticipationScore
    function calcExpectedContributionPoints(uint32 commitmentLevel, uint32 period) public view returns (uint128) {
        if (commitmentLevel < 1 || commitmentLevel > 10) revert InvalidCommitment();
        if (period == 0 || period > currentPeriodId()) revert InvalidPeriodId();
        return _calcExpectedContributionPoints(commitmentLevel, period);
    }

    /// @inheritdoc IParticipationScore
    function calcsExpectedContributionPoints(
        uint32[] calldata commitments,
        uint32[] calldata periods
    ) external view returns (uint128[] memory) {
        uint256 length = commitments.length;
        require(length == periods.length);
        uint128[] memory eps = new uint128[](length);
        for (uint256 i = 0; i < length; i++) {
            eps[i] = calcExpectedContributionPoints({commitmentLevel: commitments[i], period: periods[i]});
        }
        return eps;
    }

    function _calcExpectedContributionPoints(uint32 commitmentLevel, uint32 period) internal view returns (uint128) {
        return
            (fractionalCommitment({commitmentLevel: commitmentLevel, period: period}) *
                ITaskManager(taskManager()).getSumPeriodPoints(period)) / 1e18;
    }

    /// @inheritdoc IParticipationScore
    function fractionalCommitment(uint32 commitmentLevel, uint32 period) public view returns (uint128) {
        return (1e18 * uint128(commitmentLevel)) / IMembership(membership()).getSumCommitmentLevel(period);
    }

    /// @inheritdoc IParticipationScore
    function fractionalsCommitments(
        uint32[] calldata commitments,
        uint32[] calldata periods
    ) external view returns (uint128[] memory) {
        uint256 length = commitments.length;
        require(length == periods.length);
        uint128[] memory fcs = new uint128[](length);
        for (uint256 i = 0; i < length; i++) {
            fcs[i] = fractionalCommitment({commitmentLevel: commitments[i], period: periods[i]});
        }
        return fcs;
    }

    // TODO: seal member participation if all written?
    /// @inheritdoc IParticipationScore
    function getMembersToWriteMemberActivity(uint32 period) external view returns (address[] memory) {
        ParticipationScoreStorage storage $ = _getParticipationScoreStorage();
        uint256 numMembersToWrite = 0;
        address[] memory members = IMembership(membership()).members();
        uint256 length = members.length;
        address[] memory membersCopy = new address[](length);

        for (uint256 i = 0; i < length; i++) {
            address member = members[i];
            if ($.memberActivities[member][period].participationScore == 0) {
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
    function writeMemberActivity(address who) external {
        // update historical periods if necessary
        ITaskManager(taskManager()).writePointSummary();

        _writeMemberActivity(who, currentPeriodId());
    }

    /// @inheritdoc IParticipationScore
    function writeMemberActivities(address[] calldata whos) external {
        // update historical periods if necessary
        ITaskManager(taskManager()).writePointSummary();

        uint32 currentPeriod = currentPeriodId();
        for (uint256 i = 0; i < whos.length; i++) {
            _writeMemberActivity(whos[i], currentPeriod);
        }
    }

    function _writeMemberActivity(address who, uint32 _currentPeriod) internal {
        ParticipationScoreStorage storage $ = _getParticipationScoreStorage();

        // NOTE: in periodJoined, participationScore is default 100.  Only write to following periods
        uint32 periodJoined = IMembership(membership()).getPeriodJoined(who);

        // We are only writing to the last period which has ended: ie, _currentPeriod - 1
        uint32 periodToStartWrite;
        for (uint32 i = _currentPeriod - 1; i > periodJoined; i--) {
            // loop through passed periods and find the oldest period where participation has not yet been written
            if ($.memberActivities[who][i].participationScore == 0) {
                periodToStartWrite = i;
            } else {
                // we have reached the end of 0 values
                break;
            }
        }

        // return if there is nothing to write
        if (periodToStartWrite == 0) return;

        // Get previous period participationScore to use as a starting weight
        uint128 previousScore = $.memberActivities[who][periodToStartWrite - 1].participationScore;

        // Start at the first empty period and write the participationScore given the previous participationScore
        for (uint32 i = periodToStartWrite; i < _currentPeriod; i++) {
            MemberActivity storage memberActivity = $.memberActivities[who][i];
            uint128 performance = _calcPerformanceInPeriod({
                commitmentLevel: IMembership(membership()).getCommitmentLevel({who: who, period: i}),
                sumPointsGiven: ITaskManager(taskManager()).getMemberPointsGiven(who, i),
                period: i
            });

            uint128 delta;
            uint128 factor;
            uint128 participationScore;

            if (performance > 1e18) {
                // exceeded expectations: raise MemberActivity participationScore
                delta = performance - 1e18;
                factor = constraintFactor();
                if (delta > factor) delta = factor;
                participationScore = (previousScore * (1e18 + delta)) / delta;
            } else {
                // underperformed: lower MemberActivity participationScore
                delta = 1e18 - performance;
                factor = penaltyFactor();
                if (delta > factor) delta = factor;
                participationScore = (previousScore * (1e18 - delta)) / delta;
            }

            // write to storage
            memberActivity.participationScore = participationScore;
            memberActivity.performance = performance;

            // overwrite previousScore to use for the next period if needed
            previousScore = participationScore;
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
