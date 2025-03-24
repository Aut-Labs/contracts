//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {Task, TaskType, RoyaltiesModel, ITaskRegistry} from "./interfaces/ITaskRegistry.sol";
import {RoyaltiesModel} from "contracts/interactions/IInteractionFactory.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract TaskRegistry is ITaskRegistry, OwnableUpgradeable {
    struct TaskRegistryStorage {
        uint256 nextTaskId;
        mapping(uint256 => Task) tasks;
        address approved;
    }

    // keccak256(abi.encode(uint256(keccak256("aut.storage.TaskRegistry")) - 1))
    bytes32 private constant TaskRegistryStorageLocation =
        0xc1f8b0ede512a55dbbda242577f6b0c5214dd214df36b3a4a3854a073de90410;

    function _getTaskRegistryStorage() private pure returns (TaskRegistryStorage storage $) {
        assembly {
            $.slot := TaskRegistryStorageLocation
        }
    }

    function version() external pure returns (uint256 major, uint256 minor, uint256 patch) {
        return (0, 1, 0);
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
        if (!_isApproved()) revert NotApproved();
        _;
    }

    /// @dev returns true if the approved address set to 0 or the msg.sender is the approved address
    function _isApproved() internal view returns (bool) {
        TaskRegistryStorage storage $ = _getTaskRegistryStorage();
        address approved_ = $.approved; // gas
        return (approved_ == address(0) || approved_ == msg.sender);
    }

    /// @inheritdoc ITaskRegistry
    function registerStandardTask(string calldata _uri) external onlyApproved returns (uint256 taskId) {
        TaskRegistryStorage storage $ = _getTaskRegistryStorage();

        taskId = ++$.nextTaskId;
        $.tasks[taskId] = Task({
            taskId: taskId,
            taskType: TaskType.Standard,
            uri: _uri,
            // For standard tasks, the following fields are set to default.
            sourceInteractionContract: address(0),
            sourceInteractionId: 0,
            networkId: 0,
            price: 0,
            royaltiesModel: RoyaltiesModel.PublicGood
        });
        emit StandardTaskRegistered(taskId, _uri);
    }

    /// @inheritdoc ITaskRegistry
    function registerInteractionTask(
        address _sourceInteractionContract,
        uint256 _sourceInteractionId,
        uint256 _networkId,
        uint256 _price,
        RoyaltiesModel _royaltiesModel
    ) external onlyApproved returns (uint256 taskId) {
        TaskRegistryStorage storage $ = _getTaskRegistryStorage();

        taskId = ++$.nextTaskId;
        $.tasks[taskId] = Task({
            taskId: taskId,
            taskType: TaskType.Interaction,
            uri: "", // Not applicable for Interaction Tasks.
            sourceInteractionContract: _sourceInteractionContract,
            sourceInteractionId: _sourceInteractionId,
            networkId: _networkId,
            price: _price,
            royaltiesModel: _royaltiesModel
        });
        emit InteractionTaskRegistered(
            taskId,
            _sourceInteractionContract,
            _sourceInteractionId,
            _networkId,
            _price,
            _royaltiesModel
        );
    }

    /// @inheritdoc ITaskRegistry
    function nextTaskId() external view returns (uint256) {
        TaskRegistryStorage storage $ = _getTaskRegistryStorage();
        return $.nextTaskId;
    }

    /// @inheritdoc ITaskRegistry
    function isTaskId(uint256 taskId) external view returns (bool) {
        TaskRegistryStorage storage $ = _getTaskRegistryStorage();
        return taskId > 0 && taskId <= $.nextTaskId;
    }

    /// @inheritdoc ITaskRegistry
    function getTask(uint256 taskId) external view returns (Task memory) {
        TaskRegistryStorage storage $ = _getTaskRegistryStorage();
        require(taskId > 0 && taskId <= $.nextTaskId, "Task does not exist");
        return $.tasks[taskId];
    }

    /// @inheritdoc ITaskRegistry
    function getAllTasks() external view returns (Task[] memory) {
        TaskRegistryStorage storage $ = _getTaskRegistryStorage();
        uint256 nextTaskId_ = $.nextTaskId;

        Task[] memory allTasks = new Task[](nextTaskId_);
        for (uint256 i = 1; i <= nextTaskId_; i++) {
            allTasks[i - 1] = $.tasks[i];
        }
        return allTasks;
    }

    /// @inheritdoc ITaskRegistry
    function getSomeTasks(uint256 startTaskId, uint256 numTasks) external view returns (Task[] memory) {
        TaskRegistryStorage storage $ = _getTaskRegistryStorage();
        uint256 nextTaskId_ = $.nextTaskId;

        require(startTaskId > 0 && startTaskId + numTasks <= nextTaskId_ + 1, "Too many tasks queried");

        Task[] memory someTasks = new Task[](numTasks);
        uint256 x;
        for (uint256 i = startTaskId; i < startTaskId + numTasks; i++) {
            someTasks[x] = $.tasks[i];
            x++;
        }
        return someTasks;
    }
}
