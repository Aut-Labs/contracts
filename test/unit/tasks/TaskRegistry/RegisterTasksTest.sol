// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "test/BaseTest.sol";

contract TaskRegistryRegisterTasksUnitTest is BaseTest {

    function setUp() public override {
        super.setUp();
        bytes32[] memory taskIds = taskRegistry.taskIds();
        assertEq(taskIds.length, 11); // registered in DeployAll
    }

    function test_RegisterTasks_succeeds() public {
        Task[] memory tasks = new Task[](3);
        tasks[0] = Task({uri: "abcde"});
        tasks[1] = Task({uri: "fghij"});
        tasks[2] = Task({uri: "klmno"});

        taskRegistry.registerTasks(tasks);

        for (uint256 i=0; i<tasks.length; i++) {
            _verifyTask(tasks[i]);
        }

        bytes32[] memory taskIds = taskRegistry.taskIds();
        assertEq({
            left: taskIds.length,
            right: 14, // 11 registered in DeployAll, 3 registered here
            err: "Incorrect amount of task ids"
        });
    }

    function test_RegisterTask_TaskAlreadyRegistered_reverts() public {
        Task memory task = Task({uri: "abcde"});
        taskRegistry.registerTask(task);
        vm.expectRevert(ITaskRegistry.TaskAlreadyRegistered.selector);
        taskRegistry.registerTask(task);
    }

    function _verifyTask(Task memory task) internal view {
        bytes32 taskId = taskRegistry.calcTaskId(task);

        assertTrue(taskRegistry.isTaskId(taskId));

        Task memory queriedTask = taskRegistry.getTaskById(taskId);
        assertEq({
            left: taskRegistry.calcTaskId(queriedTask),
            right: taskId,
            err: "task incorrectly encoded"
        });
    }
}