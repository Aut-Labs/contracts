// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {DeploysInit, individualState, groupState} from "./DeploysInit.t.sol";

import {SocialBotPlugin} from "../contracts/plugins/interactions/SocialBotPlugin.sol";
import {OffchainTaskWithRep} from "../contracts/plugins/interactions/OffchainTaskWithRep.sol";
import {OpenTaskWithRep} from "../contracts/plugins/interactions/OpenTaskWithRep.sol";

import "forge-std/console.sol";

contract MultiPluginLR is DeploysInit {
    OffchainTaskWithRep offTWR;
    OpenTaskWithRep openTWR;
    SocialBotPlugin socBotP;
    uint256 tasksIncrement;

    function setUp() public override {
        super.setUp();

        vm.startPrank(A0);

        offTWR = new OffchainTaskWithRep(address(Nova), A0);
        openTWR = new OpenTaskWithRep(address(Nova));
        socBotP = new SocialBotPlugin(address(Nova));

        uint256[] memory mockdependencies;
        uint256 aDefID1 = IPR.addPluginDefinition(payable(A0), "a metadata string", 0, true, mockdependencies);
        uint256 aDefID2 = IPR.addPluginDefinition(payable(A0), "a metadata string 2", 0, true, mockdependencies);
        uint256 aSocBotID3 = IPR.addPluginDefinition(payable(A0), "a metadata string bot", 0, true, mockdependencies);

        IPR.addPluginToNova(address(offTWR), aDefID1);
        IPR.addPluginToNova(address(openTWR), aDefID2);
        IPR.addPluginToNova(address(socBotP), aSocBotID3);

        vm.stopPrank();

        vm.prank(A1);
        aID.mint("a1username", "urrrll", 1, 5, address(Nova));
        vm.prank(A2);
        aID.mint("a1username", "urrrll", 1, 5, address(Nova));

        uint256 a1bal = aID.balanceOf(A1);
        uint256 a2bal = aID.balanceOf(A2);

        assertTrue(Nova.isMember(A1), "A1 not member");
        assertTrue(Nova.isMember(A2), "A2 not member");

        A1role = aID.getMembershipData(A1, address(Nova)).role;
        A2role = aID.getMembershipData(A2, address(Nova)).role;
    }

    modifier callerIsNotMember() {
        vm.startPrank(address(type(uint160).max / 32));
        _;
        vm.stopPrank();
    }

    function _createOffTasks(uint256 roleID_) public returns (uint256 taskID) {
        vm.prank(A0);
        taskID = offTWR.create(roleID_, "http://URIOFTASKoff.com", block.timestamp + 1, block.timestamp + 3);
    }

    function _createONTasks(uint256 roleID_) public returns (uint256 taskID) {
        vm.prank(A0);
        taskID = openTWR.create(roleID_, "http://URIOFTASKon.com", block.timestamp + 1, block.timestamp + 3);
    }

    function testCreateCheckTask() public returns (uint256 taskid) {
        vm.warp(1000);
        taskid = _createONTasks(A1role);

        vm.expectRevert();
        openTWR.submit(taskid, "urlurl");

        vm.prank(address(34253254));
        vm.expectRevert();
        openTWR.finalizeFor(taskid, address(34253254));

        vm.prank(address(34253254));
        vm.expectRevert();
        openTWR.finalizeFor(taskid, address(43256));

        vm.warp(1099);
        vm.prank(A1);
        vm.expectRevert();
        openTWR.submit(taskid, "urlurl");

        uint256 snap0 = vm.snapshot();

        vm.warp(1002);
        vm.prank(A1);
        openTWR.submit(taskid, "urlurl");

        vm.revertTo(snap0);
    }

    function testSetsWeightForTask(uint16 pointsTime) public returns (uint256 snap1, uint256 task) {
        vm.assume(pointsTime < 999);
        task = testCreateCheckTask();
        assertTrue(openTWR.getRepPointsOfTask(task) == 0, "not what is set");

        vm.expectRevert();
        openTWR.setWeightForTask(task, pointsTime);

        vm.expectRevert();
        openTWR.setWeightForTask(task, pointsTime);

        vm.expectRevert();
        vm.prank(A1);
        openTWR.setWeightForTask(task, pointsTime);

        vm.prank(A0);
        openTWR.setWeightForTask(task, pointsTime);

        assertTrue(openTWR.getRepPointsOfTask(task) == pointsTime, "not what is set");

        snap1 = vm.snapshot();
    }

    function testCreatesOffchainTaskWithWeight(uint16 pointsTime) public returns (uint256 snap1, uint256 task) {
        vm.assume(pointsTime < 999);

        // revert not admin
        vm.expectRevert();
        vm.prank(A2);
        task = openTWR.createOpenTaskWithWeight(1, "http://", 100, 199999999, 7);

        // revert invalid timestamp
        vm.expectRevert();
        vm.prank(A0);
        task = openTWR.createOpenTaskWithWeight(1, "http://", 100, 1, 7);

        snap1 = vm.snapshot();
    }

    function testWorksAsRepProvider() public {
        (uint256 taskid, uint256 snap) = testSetsWeightForTask(306);

        vm.prank(address(43567342568798564));
        individualState memory IA20 = iLR.getIndividualState(A2, address(Nova));

        vm.prank(A2);
        vm.expectRevert();
        openTWR.submit(taskid, "urlurl2");

        vm.warp(1002);

        vm.prank(A2);
        openTWR.submit(taskid, "urlurl2");

        vm.prank(A0);
        openTWR.finalizeFor(taskid, A2);
        individualState memory IA21 = iLR.getIndividualState(A2, address(Nova));

        assertTrue(IA21.GC > 0, "default state");
        assertTrue(IA20.GC == 0, "has unexpected contrib");
        assertTrue((IA20.GC + openTWR.getRepPointsOfTask(taskid)) == IA21.GC, "contrib not registered");
    }

    function testMulti() public {
        (uint256 taskid, uint256 snap) = testSetsWeightForTask(306);

        vm.prank(address(43567342568798564));
        individualState memory IA20 = iLR.getIndividualState(A2, address(Nova));

        vm.prank(A2);
        vm.expectRevert();
        openTWR.submit(taskid, "urlurl2");

        vm.warp(1002);

        vm.prank(A2);
        openTWR.submit(taskid, "urlurl2");

        vm.prank(A0);
        openTWR.finalizeFor(taskid, A2);
        individualState memory IA21 = iLR.getIndividualState(A2, address(Nova));

        assertTrue(IA21.GC > 0, "default state");
        assertTrue(IA20.GC == 0, "has unexpected contrib");
        assertTrue((IA20.GC + openTWR.getRepPointsOfTask(taskid)) == IA21.GC, "contrib not registered");
    }

    function testCreatesWithRepWeight() public {
        vm.prank(A3);
        vm.expectRevert("Only admin.");
        uint256 returnsID = openTWR.createOpenTaskWithWeight(
            1, "http://URIOFTASKoff.com", block.timestamp + 1, block.timestamp + 3, 450
        );

        vm.prank(A3);
        aID.mint("aaa333", "a user url", 1, 3, address(Nova));
        assertTrue(Nova.isMember(A3), "failed to add member");

        vm.prank(A0);
        Nova.addAdmin(A3);
        assertTrue(Nova.isAdmin(A3), "failed to add admin");

        vm.prank(A3);
        returnsID = openTWR.createOpenTaskWithWeight(
            1, "http://URIOFTASKoff.com", block.timestamp + 1, block.timestamp + 3, 450
        );

        assertTrue(returnsID > 0, "id is 0");

        vm.prank(A3);
        returnsID = openTWR.createOpenTaskWithWeight(
            1, "http://URIOFTASKoff.com", block.timestamp + 1, block.timestamp + 3, 950
        );

        vm.warp(block.timestamp + 13245);

        vm.prank(A3);
        returnsID = openTWR.createOpenTaskWithWeight(
            1, "http://URIOFTASKoff.com", block.timestamp + 1, block.timestamp + 3, 450
        );
    }

    function testSocialTaksMultiple() public {
        (uint256 taskid, uint256 snap) = testSetsWeightForTask(306);
    }

    function testNonMembersCanHaveReputation() public {
        (uint256 taskid, uint256 snap) = testSetsWeightForTask(307);

        vm.skip(true);
        /// thesis test that addresses that are not members in a particular nova
        /// potentially useful for onboarding via community aprticipation
    }
}
