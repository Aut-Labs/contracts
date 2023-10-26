// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {DeploysInit} from "./DeploysInit.t.sol";

import {LocalReputation} from "../contracts/LocalReputation.sol";
import "../contracts/ILocalReputation.sol";
import {SocialBotPlugin} from "../contracts/plugins/interactions/SocialBotPlugin.sol";

import {OffchainTaskWithRep} from "../contracts/plugins/interactions/OffchainTaskWithRep.sol";
import {OpenTaskWithRep} from "../contracts/plugins/interactions/OpenTaskWithRep.sol";

import "forge-std/console.sol";

contract MultiPluginLR is DeploysInit {
    OffchainTaskWithRep offTWR;
    OpenTaskWithRep openTWR;

    function setUp() public override {
        super.setUp();

        vm.startPrank(A0);

        offTWR = new OffchainTaskWithRep(address(Nova));
        openTWR = new OpenTaskWithRep(address(Nova));

        uint256[] memory mockdependencies;
        uint256 aDefID1 = IPR.addPluginDefinition(payable(A0), "a metadata string", 0, true, mockdependencies);
        uint256 aDefID2 = IPR.addPluginDefinition(payable(A0), "a metadata string 2", 0, true, mockdependencies);

        IPR.addPluginToDAO(address(offTWR), aDefID1);
        IPR.addPluginToDAO(address(openTWR), aDefID2);

        vm.stopPrank();

        vm.prank(A1);
        aID.mint("A1USERNAME", "urrrll", 1, 5, address(Nova));
        vm.prank(A2);
        aID.mint("A1USERNAME", "urrrll", 1, 5, address(Nova));

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
        taskid = _createOffTasks(A1role);

        vm.expectRevert();
        offTWR.submit(taskid, "urlurl");

        vm.prank(address(34253254));
        vm.expectRevert();
        offTWR.finalizeFor(taskid, address(34253254));

        vm.prank(address(34253254));
        vm.expectRevert();
        offTWR.finalizeFor(taskid, address(43256));

        vm.warp(1099);
        vm.prank(A1);
        vm.expectRevert();
        offTWR.submit(taskid, "urlurl");

        vm.warp(1002);
        vm.prank(A1);
        offTWR.submit(taskid, "urlurl");

    }

    function testSetsWeightForTask() public {
        uint256 snap1 = vm.snapshot();

        uint256 task = testCreateCheckTask();

        vm.expectRevert();
        offTWR.setWeightForTask(task, 320);

        vm.expectRevert();
        offTWR.setWeightForTask(task, 11320);

        vm.expectRevert();
        vm.prank(A1);
        offTWR.setWeightForTask(task, 320);

        vm.prank(A0);
        offTWR.setWeightForTask(task, 320);

        assertTrue(offTWR.getRepPointsOfTask(task) == 320, "not what is set");
        
    }

    function testWorksAsRepProvider() public {

    }

    function testNonMembersCanHaveReputation() public {
        vm.skip(true);
        /// test that addresses that are not members in a particular nova
        /// potentially useful collateral feature
    }
}
