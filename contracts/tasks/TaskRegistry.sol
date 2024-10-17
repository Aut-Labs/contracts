//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {Task, ITaskRegistry} from "./interfaces/ITaskRegistry.sol";

contract TaskRegistry is ITaskRegistry {
    using EnumerableSet for EnumerableSet.Bytes32Set;

    EnumerableSet.Bytes32Set private _taskIds;
    mapping(bytes32 => Task) private _tasks;

    // TODO: access control ?

    /// @inheritdoc ITaskRegistry
    function registerTasks(Task[] calldata tasks) external returns (bytes32[] memory) {
        uint256 length = tasks.length;
        bytes32[] memory newTaskIds = new bytes32[](length);
        for (uint256 i = 0; i < length; i++) {
            newTaskIds[i] = _registerTask(tasks[i]);
        }

        return newTaskIds;
    }

    /// @inheritdoc ITaskRegistry
    function registerTask(Task memory task) external returns (bytes32) {
        return _registerTask(task);
    }

    function _registerTask(Task memory task) internal returns (bytes32) {
        bytes32 taskId = calcTaskId(task);

        if (!_taskIds.add(taskId)) revert TaskAlreadyRegistered();

        _tasks[taskId] = task;

        emit RegisterTask(taskId, msg.sender, task.uri);

        return taskId;
    }

    /// @inheritdoc ITaskRegistry
    function getTaskById(bytes32 taskId) external view returns (Task memory) {
        return _tasks[taskId];
    }

    /// @inheritdoc ITaskRegistry
    function getTaskByIdEncoded(bytes32 taskId) external view returns (bytes memory) {
        Task memory task = _tasks[taskId];
        return encodeTask(task);
    }

    /// @inheritdoc ITaskRegistry
    function taskIds() external view returns (bytes32[] memory) {
        return _taskIds.values();
    }

    /// @inheritdoc ITaskRegistry
    function isTaskId(bytes32 taskId) public view returns (bool) {
        return _taskIds.contains(taskId);
    }

    /// @inheritdoc ITaskRegistry
    function encodeTask(Task memory task) public pure returns (bytes memory) {
        return abi.encodePacked(task.uri);
    }

    /// @inheritdoc ITaskRegistry
    function calcTaskId(Task memory task) public pure returns (bytes32) {
        return keccak256(encodeTask(task));
    }
}
