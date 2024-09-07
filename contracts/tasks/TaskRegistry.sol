//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {Task, ITaskRegistry} from "./interfaces/ITaskRegistry.sol";

contract TaskRegistry is ITaskRegistry {
    using EnumerableSet for EnumerableSet.Bytes32Set;

    EnumerableSet.Bytes32Set private _taskIds;
    mapping(bytes32 => Task) private _tasks;

    // TODO: access control

    function registerTasks(Task[] calldata tasks) external {
        for (uint256 i = 0; i < tasks.length; i++) {
            _registerTask(tasks[i]);
        }
    }

    function registerTask(Task memory task) external {
        _registerTask(task);
    }

    function _registerTask(Task memory task) internal {
        bytes32 taskId = calcTaskId(task);

        if (!_taskIds.add(taskId)) revert TaskAlreadyRegistered();

        _tasks[taskId] = task;
    }

    function unregisterTasks(Task[] calldata tasks) external {
        for (uint256 i = 0; i < tasks.length; i++) {
            _unregisterTask(tasks[i]);
        }
    }

    function unregisterTask(Task calldata task) external {
        _unregisterTask(task);
    }

    function _unregisterTask(Task memory task) internal {
        bytes32 taskId = calcTaskId(task);

        if (!_taskIds.remove(taskId)) revert TaskNotRegistered();

        delete _tasks[taskId];
    }

    function getTaskById(bytes32 taskId) external view returns (Task memory) {
        return _tasks[taskId];
    }

    function getTaskByIdEncoded(bytes32 taskId) external view returns (bytes memory) {
        Task memory task = _tasks[taskId];
        return encodeTask(task);
    }

    function taskIds() external view returns (bytes32[] memory) {
        return _taskIds.values();
    }

    function isTaskId(bytes32 taskId) public view returns (bool) {
        return _taskIds.contains(taskId);
    }

    function encodeTask(Task memory task) public pure returns (bytes memory) {
        return abi.encodePacked(task.uri);
    }

    function calcTaskId(Task memory task) public pure returns (bytes32) {
        return keccak256(encodeTask(task));
    }
}
