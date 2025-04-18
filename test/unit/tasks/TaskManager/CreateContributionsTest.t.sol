//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "test/BaseTest.sol";

contract TaskManagerCreateContributionsTest is BaseTest {

    // Generic contribution values
    uint256 taskId;
    uint256 role = 1;
    uint32 startDate;
    uint32 endDate;
    uint32 points = 6;
    uint128 quantity = 10;
    string uri = "DiscordJoinIPFSUri";
    Contribution contribution;

    function setUp() public override {
        super.setUp();

        // register alice as an admin
        vm.prank(hub.owner());
        hub.addAdmin(alice);

        // init Contribution for testing
        taskId = taskRegistry.registerStandardTask("abcde");
        startDate = uint32(block.timestamp);
        endDate = startDate + 7 days;
        contribution = Contribution({
            taskId: taskId,
            uri: uri,
            role: role,
            startDate: startDate,
            endDate: endDate,
            points: points,
            quantity: quantity
        });
    }

    function test_CreateContribution_succeeds() public {
        // TODO: pre-action asserts

        // action
        vm.prank(alice);
        // bytes32 contributionId = taskFactory.createContribution(contribution);
        
        // TODO: post-action asserts
    }

    // TODO: revert cases
}