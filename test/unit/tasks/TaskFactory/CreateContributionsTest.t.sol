//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "test/BaseTest.sol";

contract TaskFactoryCreateContributionsTest is BaseTest {

    // Generic contribution values
    bytes32 taskId;
    uint256 role = 1;
    uint32 startDate;
    uint32 endDate;
    uint32 points = 6;
    uint128 quantity = 10;
    string uri = "someUri";
    Contribution contribution;

    function setUp() public override {
        super.setUp();

        // register alice as an admin
        vm.prank(hub.owner());
        hub.addAdmin(alice);

        // init Contribution for testing
        taskId = taskRegistry.registerTask(Task({uri: "abcde"}));
        startDate = uint32(block.timestamp);
        endDate = startDate + 7 days;
        contribution = Contribution({
            taskId: taskId,
            role: role,
            startDate: startDate,
            endDate: endDate,
            points: points,
            quantity: quantity,
            uri: uri
        });
    }

    function test_CreateContribution_succeeds() public {
        // pre-action asserts
        bytes32[] memory contributionIds = taskFactory.contributionIds();
        assertEq(contributionIds.length, 0);
        
        uint32 currentPeriodId = taskFactory.currentPeriodId();
        bytes32[] memory contributionIdsInPeriod = taskFactory.contributionIdsInPeriod(currentPeriodId);
        assertEq(contributionIdsInPeriod.length, 0);

        // action
        vm.prank(alice);
        bytes32 contributionId = taskFactory.createContribution(contribution);
        
        // post-action asserts
        assertTrue(contributionId != bytes32(0x0));
        assertTrue(taskFactory.isContributionId(contributionId));

        Contribution memory queriedContribution = taskFactory.getContributionById(contributionId);
        assertEq(queriedContribution.taskId, taskId);
        assertEq(queriedContribution.role, role);
        assertEq(queriedContribution.startDate, startDate);
        assertEq(queriedContribution.endDate, endDate);
        assertEq(queriedContribution.points, points);
        assertEq(queriedContribution.quantity, quantity);
        assertEq(
            keccak256(abi.encodePacked(queriedContribution.uri)),
            keccak256(abi.encodePacked(uri))
        );

        contributionIds = taskFactory.contributionIds();
        assertEq(contributionIds.length, 1);
        assertEq(contributionIds[0], contributionId);

        contributionIdsInPeriod = taskFactory.contributionIdsInPeriod(currentPeriodId);
        assertEq(contributionIdsInPeriod.length, 1);
        assertEq(contributionIdsInPeriod[0], contributionId);
    }

    // TODO: revert cases
}