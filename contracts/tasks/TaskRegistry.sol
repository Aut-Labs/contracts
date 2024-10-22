//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {Task, ITaskRegistry} from "./interfaces/ITaskRegistry.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract TaskRegistry is ITaskRegistry, OwnableUpgradeable {
    using EnumerableSet for EnumerableSet.Bytes32Set;

    struct TaskRegistryStorage {
        EnumerableSet.Bytes32Set taskIds;
        mapping(bytes32 => Task) tasks;
        address approved;
    }

    // keccak256(abi.encode(uint256(keccak256("aut.storage.TaskRegistry")) - 1))
    bytes32 private constant TaskRegistryStorageLocation = 0xc1f8b0ede512a55dbbda242577f6b0c5214dd214df36b3a4a3854a073de90410;

    function _getTaskRegistryStorage() private pure returns (TaskRegistryStorage storage $) {
        assembly {
            $.slot := TaskRegistryStorageLocation
        }
    }

    constructor() {
        _disableInitializers();
    }

    function initialize() external initializer {
        __Ownable_init(msg.sender);
    }

    // Access control to register tasks

    function approved() external view returns (address) {
        TaskRegistryStorage storage $ = _getTaskRegistryStorage();
        return $.approved;
    }

    function setApproved(address _approved) external onlyOwner {
        TaskRegistryStorage storage $ = _getTaskRegistryStorage();
        $.approved = _approved;
    }

    error NotApproved();
    modifier onlyApproved() {
        if (!_isApproved(msg.sender)) revert NotApproved();
        _;
    }

    /// @dev returns true if the approved address set to 0 or the msg.sender is the approved address
    function _isApproved(address who) internal view returns (bool) {
        TaskRegistryStorage storage $ = _getTaskRegistryStorage();
        address approved_ = $.approved; // gas
        return (approved_ == address(0) || approved_ == msg.sender);
    }

    /// @inheritdoc ITaskRegistry
    function registerTasks(Task[] calldata tasks) external onlyApproved returns (bytes32[] memory) {
        uint256 length = tasks.length;
        bytes32[] memory newTaskIds = new bytes32[](length);
        for (uint256 i = 0; i < length; i++) {
            newTaskIds[i] = _registerTask(tasks[i]);
        }

        return newTaskIds;
    }

    /// @inheritdoc ITaskRegistry
    function registerTask(Task memory task) external onlyApproved returns (bytes32) {
        return _registerTask(task);
    }

    function _registerTask(Task memory task) internal returns (bytes32) {
        TaskRegistryStorage storage $ = _getTaskRegistryStorage();
        
        bytes32 taskId = calcTaskId(task);

        if (!$.taskIds.add(taskId)) revert TaskAlreadyRegistered();

        $.tasks[taskId] = task;

        emit RegisterTask(taskId, msg.sender, task.uri);

        return taskId;
    }

    /// @inheritdoc ITaskRegistry
    function getTaskById(bytes32 taskId) external view returns (Task memory) {
        TaskRegistryStorage storage $ = _getTaskRegistryStorage();
        return $.tasks[taskId];
    }

    /// @inheritdoc ITaskRegistry
    function getTaskByIdEncoded(bytes32 taskId) external view returns (bytes memory) {
        TaskRegistryStorage storage $ = _getTaskRegistryStorage();
        Task memory task = $.tasks[taskId];
        return encodeTask(task);
    }

    /// @inheritdoc ITaskRegistry
    function taskIds() external view returns (bytes32[] memory) {
        TaskRegistryStorage storage $ = _getTaskRegistryStorage();
        return $.taskIds.values();
    }

    /// @inheritdoc ITaskRegistry
    function isTaskId(bytes32 taskId) public view returns (bool) {
        TaskRegistryStorage storage $ = _getTaskRegistryStorage();
        return $.taskIds.contains(taskId);
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
