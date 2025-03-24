// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "test/BaseTest.sol";

contract TaskRegistryRegisterTasksUnitTest is BaseTest {

    function setUp() public override {
        super.setUp();
        uint256 nextTaskId = taskRegistry.nextTaskId();
        assertEq(nextTaskId, 11); // registered in DeployAll
    }

    function test_RegisterTasks_succeeds() public {
        taskRegistry.registerStandardTask("abcde");
        taskRegistry.registerStandardTask("fghij");
        taskRegistry.registerStandardTask("klmno");

        uint256 nextTaskId = taskRegistry.nextTaskId();
        assertEq({
            left: nextTaskId,
            right: 14, // 11 registered in DeployAll, 3 registered here
            err: "Incorrect amount of task ids"
        });
    }

}