//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IPeriodUtils} from "../utils/interfaces/IPeriodUtils.sol";
import {IAccessUtils} from "../utils/AccessUtils.sol";

abstract contract TaskManager is IPeriodUtils, IAccessUtils {

    error NotAdmin();

    uint128 public pointsActive;
    uint128 public periodPointsCreated;
    uint128 public periodPointsGiven;
    uint128 public periodPointsRemoved;

    // address public taskRegistry;

    enum TaskStatus {
        None, Open, Inactive, Complete
    }

    struct Task {
        TaskStatus status;
    }

    struct PointSummary {
        bool isSealed;
        uint128 pointsActive;
        uint128 pointsCreated;
        uint128 pointsGiven;
        uint128 pointsRemoved;
    }
    mapping(uint32 periodId => PointSummary) public pointSummaries;

    struct MemberActivity {
        uint128 pointsGiven;
        bytes32[] tasks;
    }
    mapping(address member => mapping(uint32 periodId => MemberActivity)) public memberActivities;

    function currentTaskId() public view returns (uint256) {
        return tasks.length - 1;
    }

    function getTaskStatus(uint256 taskId) external view returns (TaskStatus) {
        // TODO
    }

    function getTaskWeight(uint256 taskId) external view returns (uint128) {
        // TODO
    }

    function getGivenContributionPoints(uint32 periodId) external view returns (uint128) {
        // TODO
    }

    function getActiveTasks(uint32 periodId) external view returns (Task[] memory) {
        // TODO
    }

    function getGivenContributionPoints(address who, uint32 periodId) external view returns (uint128) {
        // TODO
    }

    function getTotalContributionPoints(uint32 periodId) external view returns (uint128) {
        // TODO
    }

    function getCompletedTasks(uint32 periodId) external view returns (Task[] memory) {
        // TODO: how should completed tasks be stored? is it by each time task points
        // are given or when the task is fully completed X many times?
    }

    function addTasks(Task[] calldata _tasks) external {
        if !this.isAdmin(msg.sender) revert NotAdmin();
        writePointSummary();

        uint256 length = _tasks.length;
        for (uint256 i = 0; i < length; i++) {
            _addTask(_tasks[i]);
        }
    }

    function addTask(Task calldata _task) public {
        if !this.isAdmin(msg.sender) revert NotAdmin();
        writePointSummary();

        _addTask(_task);
    }

    function _addTask(Task memory _task) internal {
        // if (_task.contributionPoints == 0 || _task.contributionPoints > 10) revert InvalidTaskContributionPoints();
        // if (_task.quantity == 0 || _task.quantity > members.length + 100) revert InvalidTaskQuantity();
        // // if (!IInteractionRegistry(hubRegistry).isInteractionId(_task.interactionId)) revert InvalidTaskInteractionId();

        // uint128 sumTaskContributionPoints = _task.contributionPoints * _task.quantity;
        // currentSumActiveContributionPoints += sumTaskContributionPoints;
        // currentSumCreatedContributionPoints += sumTaskContributionPoints;

        // tasks.push(_task);
        // TODO: events
    }

    function removeTasks(uint256[] memory _taskIds) external {
        if !this.isAdmin(msg.sender) revert NotAdmin();
        writePointSummary();
        for (uint256 i = 0; i < _taskIds.length; i++) {
            _removeTask(_taskIds[i]);
        }
    }

    function removeTask(uint256 _taskId) external {
        if !this.isAdmin(msg.sender) revert NotAdmin();
        writePointSummary();
        _removeTask(_taskId);
    }

    function _removeTask(uint256 _taskId) internal {
        // Task memory task = tasks[_taskId];
        // if (task.quantity == 0) revert TaskNotActive();
        // // NOTE: does not subtract from created tasks

        // uint128 sumTaskContributionPoints = task.contributionPoints * task.quantity;
        // currentSumActiveContributionPoints -= sumTaskContributionPoints;
        // currentSumRemovedContributionPoints += sumTaskContributionPoints;

        // delete tasks[_taskId];
        // TODO: event
    }

    function giveTasks(uint256[] memory _taskIds, address[] memory _members) external {
        if !this.isAdmin(msg.sender) revert NotAdmin();
        uint256 length = _taskIds.length;
        if (length != _members.length) revert UnequalLengths();
        for (uint256 i = 0; i < length; i++) {
            _giveTask(_taskIds[i], _members[i]);
        }
    }

    function giveTask(uint256 _taskId, address _member) external {
        if !this.isAdmin(msg.sender) revert NotAdmin();
        _giveTask(_taskId, _member);
    }

    function _giveTask(uint256 _taskId, address _member) internal {
        // Task storage task = tasks[_taskId];
        // if (task.quantity == 0) revert TaskNotActive();
        // if (joinedAt[_member] == 0) revert MemberDoesNotExist();

        // Participation storage participation = participations[_member][currentPeriodId()];

        // uint128 contributionPoints = task.contributionPoints;
        // participation.givenContributionPoints += contributionPoints;

        // currentSumGivenContributionPoints += contributionPoints;
        // currentSumActiveContributionPoints -= contributionPoints;

        // task.quantity--;

        // TODO: push task to user balance (as nft)
    }

    /// @notice write sums to history when needed
    function writePointSummary() public {
        _writePointSummary(this.currentPeriodId());
    }

    function _writePointSummary(uint32 _currentPeriodId) internal {
        uint32 initPeriodId_ = initPeriodId; // gas
        uint32 lastPeriodId = _currentPeriodId - 1;

        // What happens if a period passes which doesn't write to storage?
        // It means in period n there was activity, period n + 1 => current period there is no activity
        uint32 i;
        bool writeToHistory;
        for (i = lastPeriodId; i > initPeriodId_ - 1; i--) {
            if (!pointSummaries[i].sealed) {
                writeToHistory = true;
            } else {
                // historical commitment levels are up to date- do nothing
                break;
            }
        }

        if (writeToHistory) {
            // Write data to oldest possible period summary with no data
            pointSummaries[i] = PointSummary({
                isSealed: true,
                pointsActive: pointsActive,
                pointsCreated: periodPointsCreated,
                pointsGiven: periodPointsGiven,
                pointsRemoved: periodPointsRemoved
            });

            // if there's a gap in data- we have inactive periods.
            // How do we know a gap means inactive periods?
            //      Because each interaction with the members tasks write to the task summary, keeping it synced
            if (i < lastPeriodId) {
                for (uint32 j = i + 1; j < _currentPeriodId; j++) {
                    periodSummaries[j] = PointSummary({
                        isSealed: true,
                        pointsActive: pointsActive,
                        pointsCreated: 0,
                        pointsGiven: 0,
                        pointsRemoved: 0
                    });
                }
            }

            // Still in writeToHistory conditional...
            // Clear out the storage only relevant to the period
            delete periodPointsCreated;
            delete periodPointsGiven;
            delete periodPointsRemoved;
        }
    }
}