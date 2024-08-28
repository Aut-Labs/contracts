//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {TaskType, ITaskRegistry} from "./interfaces/ITaskRegistry.sol";

contract TaskRegistry is ITaskRegistry {
    using EnumerableSet for EnumerableSet.Bytes32Set;

    // TODO: interactionId validation

    EnumerableSet.Bytes32Set private _registeredTaskSet;
    mapping(bytes32 => TaskType) private _registeredTasks;

    function registeredTasks(bytes32 taskId) external view returns (TaskType memory) {
        return _registeredTasks[taskId];
    }

    function registeredTaskSet() external view returns (bytes32[] memory) {
        return _registeredTaskSet.values();
    }

    function isRegisteredTask(bytes32 taskId) public view returns (bool) {
        return _registeredTaskSet.contains(taskId);
    }

    // TODO: access control

    function registerTasks(TaskType[] calldata tasks) external {
        for (uint256 i = 0; i < tasks.length; i++) {
            _registerTask(tasks[i]);
        }
    }

    function registerTask(TaskType memory task) external {
        _registerTask(task);
    }

    function _registerTask(TaskType memory task) internal returns (bool) {
        bytes32 taskId = encodeTask(task);

        if (!_registeredTaskSet.add(taskId)) revert TaskAlreadyRegistered();

        _registeredTasks[taskId] = task;
    }

    function unregisterTasks(TaskType[] calldata tasks) external {
        for (uint256 i = 0; i < tasks.length; i++) {
            _unregisterTask(tasks[i])
        }
    }

    function unregisterTask(TaskType calldata task) external {
        _unregisterTask(task);
    }

    function _unregisterTask(TaskType memory task) internal {
        bytes32 taskId = encodeTask(task);

        if (!_registeredTaskSet.remove(taskId)) revert TaskNotRegistered();

        delete _registeredTasks[taskId];
    }

    function encodeTask(TaskType memory task) public pure returns (bytes32) {
        return keccak256(abi.encode(task.description, task.interactionId));
    }
}
