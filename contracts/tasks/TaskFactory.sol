//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract TaskFactory is Initializable {

    uint128 currentSumCreatedContributionPoints;
    uint128 currentSumActiveContributionPoints;
    uint128 currentSumGivenContributionPoints;
    uint128 currentSumRemovedContributionPoints;

    address public hub;
    address public membership;

    struct Task {
        bytes32 interactionId;
        uint256 role;
        uint128 quantity;
        uint32 periodIdDeployed;
        uint32 startDate;
        uint32 endDate;
        string description;
        uint32 weight;
        // TODO: further identifiers
    }
    Task[] public tasks;

    struct TaskSummary {
        uint128 sumCreatedContributionPoints;
        uint128 sumActiveContributionPoints;
        uint128 sumGivenContributionPoints;
        uint128 sumRemovedContributionPoints;
    }
    mapping(uint32 periodId => TaskSummary) public taskSummaries;

    function initialize(
        address _hub,
        address _membership
    ) external initializer {
        hub = _hub;
        membership = _membership;
    }

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
        // if (!IInteractionRegistry(novaRegistry).isInteractionId(_task.interactionId)) revert InvalidTaskInteractionId();

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

        uint32 currentPeriodId = TimeLibrary.periodId({period0Start: period0Start, timestamp: uint32(block.timestamp)});
        Participation storage participation = participations[_member][currentPeriodId];

        uint128 contributionPoints = task.contributionPoints;
        participation.givenContributionPoints += contributionPoints;

        currentSumGivenContributionPoints += contributionPoints;
        currentSumActiveContributionPoints -= contributionPoints;

        task.quantity--;

        // TODO: push task to user balance (as nft)
    }
}