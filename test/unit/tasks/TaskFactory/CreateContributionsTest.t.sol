//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "test/BaseTest.sol";

contract TaskFactoryCreateContributionsTest is BaseTest {

    function setUp() public override {
        super.setUp();

        // register a task
        Task memory task = Task({uri: "abcde"});
        bytes32 taskId = taskRegistry.registerTask(task);

        // register alice as an admin
        vm.prank(hub.owner());
        hub.addAdmin(alice);
    }


}