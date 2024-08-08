//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

interface IMembership {
    function join(address, uint256, uint8) external;
    function roles(address) external view returns (uint256);
    function isMember(address) external view returns (bool);
}

contract Membership is Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;

    uint256 public constant MIN_COMMITMENT = 1;
    uint256 public constant MAX_COMMITMENT = 10;

    uint256 public immutable period0Start;
    uint32 public immutable initTimestamp;
    uint32 public immutable initPeriodId;

    uint32 public initTimestamp;
    uint32 public initPeriodId;
    uint128 currentSumCommitmentLevel;
    uint128 currentSumCreatedContributionPoints;
    uint128 currentSumActiveContributionPoints;
    uint128 currentSumGivenContributionPoints;
    uint128 currentSumRemovedContributionPoints;

    mapping(address => uint32) public joinedAt;
    mapping(address => uint8) public currentCommitmentLevels;
    mapping(address => uint256) public roles;
    mapping(address => uint256) public accountMasks;

    EnumerableSet.AddressSet[] private _members;

    struct Task {
        uint32 contributionPoints;
        uint128 quantity;
        bytes32 interactionId;
        // TODO: further identifiers
    }
    Task[] public tasks;

    struct Participation {
        uint32 commitmentLevel;
        uint128 givenContributionPoints;
        // TODO: array of completed tasks
    }
    mapping(
        address who => mapping(
            uint32 periodId => Participation participation
        )
    ) public participations;

    struct PeriodSummary {
        bool inactive;
        uint128 sumCommitmentLevel;
        uint128 sumCreatedContributionPoints;
        uint128 sumActiveContributionPoints;
        uint128 sumGivenContributionPoints;
        uint128 sumRemovedContributionPoints;
    }
    mapping(
        uint32 periodId => PeriodSummary periodSummary
    ) public periodSummaries;

    constructor(
        address _owner,
        uint64 _period0Start
    ) Ownable(_owner) {
        period0Start = _period0Start;
    }

    // ------------------------------------------------------
    //                        ROLES
    // ------------------------------------------------------

    function members() external view returns (address[] memory) {
        return _members.values();
    }

    function isMember(address who) public view returns (bool) {
        return _members.contains(who);
    }

    error AlreadyMember();
    function join(address who, uint256 role, uint8 commitmentLevel) external onlyOwner {
        roles[who] = role;
        if (!_members.add(who)) revert AlreadyMember();
        joinedAt[who] = uint32(block.timestamp);

        uint32 currentPeriodId = IGlobalParametersAlpha(novaRegistry).currentPeriodId();
        participations[who][currentPeriodId].commitmentLevel = commitmentLevel;
        currentCommitmentLevels[who] = commitmentLevel;

        _writePeriodSummary(currentPeriodId);
        currentSumCommitmentLevel += uint128(commitmentLevel);
    }

    // ------------------------------------------------------
    //                   COMMITMENT LEVEL
    // ------------------------------------------------------

    /// @notice get the commitment level of a member at a particular period id
    function getCommitmentLevel(address who, uint32 periodId) external view returns (uint32) {
        if (periodId < getPeriodIdJoined(who)) revert MemberHasNotYetCommited();

        Participation memory participation = participations[who][periodId];
        if (participation.commitmentLevel != 0) {
            // user has changed their commitmentLevel in a period following `periodId`.  We know this becuase
            // participation.commitmentLevel state is non-zero as it is written following a commitmentLevel change.
            return participation.commitmentLevel;
        } else {
            // User has *not* changed their commitment level: meaning their commitLevel is sync to current
            return currentCommitmentLevels[who];
        }
    }


    function changeCommitmentLevel(uint8 newCommitmentLevel) external {
        uint8 oldCommitmentLevel = currentCommitmentLevels[msg.sender];
        if (newCommitmentLevel == oldCommitmentLevel) revert SameCommitmentLevel();

        // TODO: globalParam
        if (newCommitmentLevel == 0 || newCommitmentLevel > 10) revert InvalidCommitmentLevel();

        uint32 periodIdJoined = getPeriodIdJoined(msg.sender);
        uint32 currentPeriodId = IGlobalParametersAlpha(novaRegistry).currentPeriodId();

        // write to storage for all 0 values- as the currentCommitmentLevels is now different
        for (uint32 i = currentPeriodId; i > periodIdJoined - 1; i--) {
            Participation storage participation = participations[msg.sender][i];
            if (participation.commitmentLevel == 0) {
                participation.commitmentLevel = oldCommitmentLevel;
            } else {
                // we have reached the end of zero values
                break;
            }
        }

        currentCommitmentLevels[msg.sender] = newCommitmentLevel;

        _writePeriodSummary(currentPeriodId);
        currentSumCommitmentLevel = currentSumCommitmentLevel - oldCommitmentLevel + newCommitmentLevel;

        emit ChangeCommitmentLevel({
            who: msg.sender,
            oldCommitmentLevel: oldCommitmentLevel,
            newCommitmentLevel: newCommitmentLevel
        });
    }

    // ------------------------------------------------------
    //                        TASKS
    // ------------------------------------------------------

    function currentTaskId() public view returns (uint256) {
        return tasks.length - 1;
    }

    function addTasks(Task[] calldata _tasks) external {
        _revertForNotAdmin(msg.sender);
        writePeriodSummary();

        uint256 length = _tasks.length;
        for (uint256 i = 0; i < length; i++) {
            _addTask(_tasks[i]);
        }
    }

    function addTask(Task calldata _task) public {
        _revertForNotAdmin(msg.sender);
        writePeriodSummary();

        _addTask(_task);
    }

    function _addTask(Task memory _task) internal {
        if (_task.contributionPoints == 0 || _task.contributionPoints > 10) revert InvalidTaskContributionPoints();
        if (_task.quantity == 0 || _task.quantity > members.length + 100) revert InvalidTaskQuantity();
        if (!IInteractionRegistry(novaRegistry).isInteractionId(_task.interactionId)) revert InvalidTaskInteractionId();

        uint128 sumTaskContributionPoints = _task.contributionPoints * _task.quantity;
        currentSumActiveContributionPoints += sumTaskContributionPoints;
        currentSumCreatedContributionPoints += sumTaskContributionPoints;

        tasks.push(_task);
        // TODO: events
    }

    function removeTasks(uint256[] memory _taskIds) external {
        _revertForNotAdmin(msg.sender);
        writePeriodSummary();
        for (uint256 i = 0; i < _taskIds.length; i++) {
            _removeTask(_taskIds[i]);
        }
    }

    function removeTask(uint256 _taskId) external {
        _revertForNotAdmin(msg.sender);
        writePeriodSummary();
        _removeTask(_taskId);
    }

    error TaskNotActive();
    function _removeTask(uint256 _taskId) internal {
        Task memory task = tasks[_taskId];
        if (task.quantity == 0) revert TaskNotActive();
        // NOTE: does not subtract from created tasks

        uint128 sumTaskContributionPoints = task.contributionPoints * task.quantity;
        currentSumActiveContributionPoints -= sumTaskContributionPoints;
        currentSumRemovedContributionPoints += sumTaskContributionPoints;

        delete tasks[_taskId];
        // TODO: event
    }

    error UnequalLengths();
    function giveTasks(uint256[] memory _taskIds, address[] memory _members) external {
        _revertForNotAdmin(msg.sender);
        uint256 length = _taskIds.length;
        if (length != _members.length) revert UnequalLengths();
        for (uint256 i = 0; i < length; i++) {
            _giveTask(_taskIds[i], _members[i]);
        }
    }

    function giveTask(uint256 _taskId, address _member) external {
        _revertForNotAdmin(msg.sender);
        _giveTask(_taskId, _member);
    }

    function _giveTask(uint256 _taskId, address _member) internal {
        Task storage task = tasks[_taskId];
        if (task.quantity == 0) revert TaskNotActive();
        if (joinedAt[_member] == 0) revert MemberDoesNotExist();

        uint32 currentPeriodId = IGlobalParametersAlpha(novaRegistry).currentPeriodId();
        Participation storage participation = participations[_member][currentPeriodId];

        uint128 contributionPoints = task.contributionPoints;
        participation.givenContributionPoints += contributionPoints;

        currentSumGivenContributionPoints += contributionPoints;
        currentSumActiveContributionPoints -= contributionPoints;

        task.quantity--;

        // TODO: push task to user balance (as nft)
    }

    // ------------------------------------------------------
    //                     PERIODS
    // ------------------------------------------------------

    /// @notice return the period id the member joined the hub
    function getPeriodIdJoined(address who) public view returns (uint32) {
        uint32 periodIdJoined = TimeLibrary.periodId({
            period0Start: IGlobalParametersAlpha(novaRegistry).period0Start(),
            timestamp: joinedAt[who]
        });
        if (periodIdJoined == 0) revert MemberDoesNotExist();
        return periodIdJoined;
    }

    /// @notice write sums to history when needed
    function writePeriodSummary() public {
        uint32 currentPeriodId = IGlobalParametersAlpha(novaRegistry).currentPeriodId();
        _writePeriodSummary(currentPeriodId);
    }

    function _writePeriodSummary(uint32 _currentPeriodId) internal {
        uint32 initPeriodId_ = initPeriodId; // gas
        uint32 lastPeriodId = _currentPeriodId - 1;

        // What happens if a period passes which doesn't write to storage?
        // It means in period n there was activity, period n + 1 => current period there is no activity
        uint32 i;
        bool writeToHistory;
        for (i = lastPeriodId; i > initPeriodId_ - 1; i--) {
            PeriodSummary storage periodSummary = periodSummaries[i];
            if (periodSummary.sumCommitmentLevel == 0) {
                writeToHistory = true;
            } else {
                // historical commitment levels are up to date- do nothing
                break;
            }
        }

        if (writeToHistory) {
            // Write data to oldest possible period summary with no data
            periodSummaries[i] = PeriodSummary({
                inactive: false,
                sumCommitmentLevel: currentSumCommitmentLevel,
                sumActiveContributionPoints: currentSumActiveContributionPoints,
                sumCreatedContributionPoints: currentSumCreatedContributionPoints,
                sumGivenContributionPoints: currentSumGivenContributionPoints,
                sumRemovedContributionPoints: currentSumRemovedContributionPoints
            });

            // if there's a gap in data- we have inactive periods. Fill up with inactive flag and empty values where possible
            if (i < lastPeriodId) {
                for (uint32 j = i + 1; j < _currentPeriodId; j++) {
                    periodSummaries[j] = PeriodSummary({
                        inactive: true,
                        sumCommitmentLevel: currentSumCommitmentLevel,
                        sumCreatedContributionPoints: 0,
                        sumActiveContributionPoints: currentSumActiveContributionPoints,
                        sumGivenContributionPoints: 0,
                        sumRemovedContributionPoints: 0
                    });
                }
            }

            // Still in writeToHistory conditional: clear out storage where applicable
            delete currentSumCreatedContributionPoints;
            delete currentSumGivenContributionPoints;
            delete currentSumRemovedContributionPoints;
        }
    }

}