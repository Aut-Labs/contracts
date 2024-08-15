//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract TaskManager is Initializable {

    address public membership;
    address public taskFactory;
    address public hub;
    // address public taskRegistry; // TODO: should every task ever created be put here?

    enum TaskStatus {
        None, Open, Inactive, Complete
    }

    function initialize(
        address _membership,
        address _taskFactory,
        address _hub,
    ) external initializer {
        hub = _hub;
        taskFactory =_taskFactory;
        membership = _membership;
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
}