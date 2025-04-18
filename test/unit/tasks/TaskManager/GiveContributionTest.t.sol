//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "test/BaseTest.sol";

contract TaskManagerGiveContributionTest is BaseTest {
    // Generic contribution values
    uint256 taskId;
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

        // create generic contribution
        vm.prank(alice);
        contributionId = taskFactory.createContribution(contribution);
    
        // bob commits (note: used for off-chain verification)
        vm.prank(bob);
        taskManager.commitContribution({
            contributionId: contributionId,
            who: bob,
            data: "bob#1234@discord"
        });
    
    }

    function test_GiveContribution_succeeds() public {
        uint32 currentPeriod = taskManager.currentPeriodId();

        // pre-action asserts
        MemberActivity memory memberActivity = taskManager.getMemberActivity(bob, currentPeriod);
        assertEq(memberActivity.pointsGiven, 0);
        assertEq(memberActivity.contributionIds.length, 0);

        // action
        vm.prank(alice); // alice is admin
        taskManager.giveContribution({
            contributionId: contributionId,
            who: bob
        });

        // post-action asserts (TODO)
        // memberActivity = taskManager.getMemberActivity(bob, currentPeriod);
        // assertEq(memberActivity.sumPointsGiven, points);
        // assertEq(memberActivity.contributionIds.length, 1);
        // assertEq(memberActivity.contributionIds[0], contributionId);
    }

    // TODO: revert cases

}