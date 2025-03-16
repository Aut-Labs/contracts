//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "test/BaseTest.sol";

contract TaskManagerCommitContributionTest is BaseTest {
    // Generic contribution values
    bytes32 taskId;
    uint256 role = 1;
    uint32 startDate;
    uint32 endDate;
    uint32 points = 6;
    uint128 quantity = 10;
    string uri = "DiscordJoinIPFSUri";
    Contribution contribution;
    bytes32 contributionId;

    function setUp() public override {
        super.setUp();

        // register alice as an admin
        vm.prank(hub.owner());
        hub.addAdmin(alice);

        // bob joins hub
        _joinHub(bob, address(hub), "bob");

        // init Contribution for testing
        taskId = taskRegistry.registerTask(Task({uri: "abcde", interactionId: 0, networkId: 0, contractAddress: address(0), functionSignature: ""}));
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

        // create generic contribution
        vm.prank(alice);
        contributionId = taskFactory.createContribution(contribution);
    }

    function test_CommitContribution_succeeds() public {
        // TODO: evaluate event
        vm.prank(bob);
        taskManager.commitContribution({
            contributionId: contributionId,
            who: bob,
            data: "bob#1234@discord"
        });
    }

    // TODO: revert cases

}