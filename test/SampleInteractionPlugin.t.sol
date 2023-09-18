//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {DeploysInit} from "./DeploysInit.t.sol";

import {LocalRep} from "../contracts/plugins/interactions/LocalReputation.sol";
import "../contracts/plugins/interactions/ILocalReputation.sol";
import {SampleInteractionPlugin} from "../contracts/plugins/interactions/SampleInteractionPlugin.sol";

import "forge-std/console.sol";

contract TestSampleInteractionPlugin is DeploysInit {
    LocalRep LocalRepAlgo;
    ILocalReputation iLR;
    SampleInteractionPlugin InteractionPlugin;

    uint256 taskPluginId;
    address Admin;

    function setUp() public override {
        uint256 time0 = block.timestamp == 0 ? 1699999999 : block.timestamp;
        vm.warp(time0 + 1);

        super.setUp();

        LocalRepAlgo = new LocalRep();
        vm.label(address(LocalRepAlgo), "LocalRep");

        vm.prank(IPR.owner());
        IPR.setDefaulLRAddress(address(LocalRepAlgo));

        iLR = ILocalReputation(IPR.defaultLRAddr());

        vm.prank(A1);
        aID.mint("a Name", "urlll", 1, 4, address(Nova));

        InteractionPlugin = new SampleInteractionPlugin(address(Nova) );
        vm.label(address(InteractionPlugin), "InteractionPlugin");

        uint256[] memory depmodrek;

        vm.prank(A0);
        uint256 pluginDefinitionID =
            IPR.addPluginDefinition(payable(A1), "owner can spoof metadata", 0, true, depmodrek);

        vm.prank(A0);
        IPR.addPluginToDAO(address(InteractionPlugin), pluginDefinitionID);

        taskPluginId = IPR.tokenIdFromAddress(address(InteractionPlugin));

        Admin = A0;
        assertTrue(Nova.isAdmin(Admin), "expected deployer admin");
        assertFalse(Nova.isMember(Admin), "admin is member - maybe should be the case");
    }

    function testUnconfiguredInteraction() public {
        vm.startPrank(A1);
        uint256 number1 = InteractionPlugin.number();
        InteractionPlugin.incrementNumber("");
        uint256 number2 = InteractionPlugin.number();
        InteractionPlugin.incrementNumber("averyrandomstring");
        uint256 number3 = InteractionPlugin.number();
        assertTrue(number1 + number2 == number3, "Not Incremented");

        vm.stopPrank();
    }

    function testSetWeight() public {
        bytes[] memory datas = new bytes[](2);
        uint256[] memory points = new uint256[](2);

        datas[0] = abi.encodePacked(InteractionPlugin.incrementNumberPlusOne.selector);
        datas[1] = abi.encodeWithSelector(InteractionPlugin.incrementNumber.selector, "averyrandomstring");

        points[0] = 5;
        points[1] = 500;

        vm.expectRevert(ILocalReputation.OnlyAdmin.selector);
        iLR.setInteractionWeights(address(InteractionPlugin), datas, points);

        vm.prank(Admin);
        iLR.setInteractionWeights(address(InteractionPlugin), datas, points);

        uint256 number1 = InteractionPlugin.number();
        testUnconfiguredInteraction();
        uint256 number2 = InteractionPlugin.number();

        individualState memory IS1 = iLR.getIndividualState(A2, address(Nova));

        vm.prank(A2);
        InteractionPlugin.incrementNumberPlusOne();

        individualState memory IS2 = iLR.getIndividualState(A2, address(Nova));
        assertTrue(IS2.GC > 0, "has some points");
        assertTrue(IS1.GC < IS2.GC, "no points gained");

        vm.prank(A1);
        InteractionPlugin.incrementNumber("averyrandomstring");
        individualState memory IS3 = iLR.getIndividualState(A1, address(Nova));
        assertTrue(IS3.GC >= 500, "function arg points mismatch");
    }

    function testGroupInitDefault() public {
        groupState memory GS0 = iLR.getGroupState(address(Nova));

        assertTrue(GS0.k == 30, "k not default 30");
        assertTrue(GS0.p == 30 days, "min period not 30 days");
        assertTrue(GS0.lastPeriod >= block.timestamp, "last peridon uninit");

        address[] memory members = Nova.getAllMembers();
        assertTrue(members.length == 1, "not more than 1 member");
        assertTrue(GS0.TCL == 4, "1 member tcl in setup");
    }

    function testWithSameCommitmentPeriod() public {
        uint256 membersAmt = 3;
        uint256 firsPoints = 1;
        uint256 secondPoints = 5;

        bytes[] memory datas = new bytes[](2);
        uint256[] memory points = new uint256[](2);

        datas[0] = abi.encodePacked(InteractionPlugin.incrementNumberPlusOne.selector);
        datas[1] = abi.encodeWithSelector(InteractionPlugin.incrementNumber.selector, "averyrandomstring");

        points[0] = firsPoints;
        points[1] = secondPoints;

        vm.prank(Admin);
        iLR.setInteractionWeights(address(InteractionPlugin), datas, points);

        uint256 i = 1;
        for (i; i < 100;) {
            vm.prank(address(uint160(i)));
            aID.mint(vm.toString(i), "urlll", 1, 4, address(Nova));

            vm.warp(block.timestamp + 1);

            vm.prank(address(uint160(i)));
            (i % 2 == 0)
                ? InteractionPlugin.incrementNumberPlusOne()
                : InteractionPlugin.incrementNumber("averyrandomstring");

            vm.warp(block.timestamp + 1);

            unchecked {
                ++i;
            }

            address[] memory members = Nova.getAllMembers();
            groupState memory GSbefore = iLR.getGroupState(address(Nova));

            iLR.updateCommitmentLevels(address(Nova));
        }
        assertTrue(iLR.getGroupState(address(Nova)).lastPeriod > 1, "lastPeriod not block.timestamp");
    }

    function testSimpleGroupPeriodicUpdate() public {
        vm.warp(block.timestamp + 100 days);
        testWithSameCommitmentPeriod();
        groupState memory GSbefore = iLR.getGroupState(address(Nova));

        vm.prank(A0);
        uint256 nextUpdateAt = iLR.periodicGroupStateUpdate(address(Nova));
        vm.prank(A0);
        iLR.bulkPeriodicUpdate(address(Nova));

        groupState memory GSafer = iLR.getGroupState(address(Nova));

        nextUpdateAt = GSafer.lastPeriod + GSafer.p;

        assertTrue(nextUpdateAt >= block.timestamp, "should be later");
        assertTrue(nextUpdateAt >= GSbefore.lastPeriod + GSbefore.p, "period increment fault");
    }

    function testIndividualLRUpdate() public {
        address A55 = address(5);

        vm.expectRevert(ILocalReputation.OnlyAdmin.selector);
        uint256 prevScore = iLR.updateIndividualLR(A55, address(Nova));

        vm.expectRevert(ILocalReputation.ZeroUnallawed.selector);
        vm.prank(A0);
        prevScore = iLR.updateIndividualLR(A55, address(Nova));

        assertTrue(prevScore == 0, "No update score is blank");
        testWithSameCommitmentPeriod();

        vm.warp(block.timestamp + 31 days);
        vm.startPrank(A0);
        uint256 newScore = iLR.updateIndividualLR(A55, address(Nova));
        assertTrue(newScore > 1, "not updated");

        uint256 nextUpdateAt = iLR.periodicGroupStateUpdate(address(Nova));

        vm.warp(nextUpdateAt + 1);
        iLR.periodicGroupStateUpdate(address(Nova));

        newScore = iLR.updateIndividualLR(A55, address(Nova));
        assertTrue(newScore > 1, "has actual score");
        vm.stopPrank();
    }

    function testPeriodFlip() public {
        testWithSameCommitmentPeriod();

        vm.expectRevert(ILocalReputation.PeriodUnelapsed.selector);
        vm.prank(A0);
        uint256[] memory scores1 = iLR.bulkPeriodicUpdate(address(Nova));

        vm.warp(block.timestamp + (30 * 1 days));
        vm.prank(A0);
        scores1 = iLR.bulkPeriodicUpdate(address(Nova));
    }

    function testArchetypeDataUpdates() public {
        testPeriodFlip();

        vm.warp(block.timestamp + 1);

        (uint256 avComm, uint256 avRep) = iLR.getAvReputationAndCommitment(address(Nova));
        address[] memory allMembers = Nova.getAllMembers();
        uint256[] memory allCommitments = aID.getCommitmentsOfFor(allMembers, address(Nova));

        assertTrue(allMembers.length == allCommitments.length, "member comm. len mismatch");
        assertTrue(allCommitments[1] == allCommitments[2], "all have same commitment");

        assertTrue(avRep >= 0.01 ether, "1 members only ");
        assertTrue(avRep < 10 ether, "1 members only ");

        assertTrue(avComm == 4, "all have 4, expeced 4");

        int64[4] memory archetypeData = iLR.getArchetypeData(address(Nova));

        assertTrue(archetypeData[0] > 1, "exp members were added");

        assertTrue(uint256(uint64(archetypeData[1])) == allMembers.length);
        assertTrue(uint256(uint64(archetypeData[2])) == avRep, "should be same lifecycle");
        assertTrue(uint256(uint64(archetypeData[3])) == avComm, "all were 4");

        // console.logInt(archetypeData[0]);
        // console.log(uint64(archetypeData[1]));
        // console.log(uint64(archetypeData[2]));
        // console.log(uint64(archetypeData[3]));
    }

    function testArchetypeUpd2() public {
        testPeriodFlip();
        int64[4] memory prevArchetypeData = iLR.getArchetypeData(address(Nova));

        uint256 i = 8888888888888888;
        for (i; i < 8888888888888948;) {
            vm.prank(address(uint160(i)));
            aID.mint(vm.toString(i), "https://", 1, 9, address(Nova));

            vm.prank(address(uint160(i)));
            (i % 2 == 0)
                ? InteractionPlugin.incrementNumberPlusOne()
                : InteractionPlugin.incrementNumber("averyrandomstring");

            unchecked {
                ++i;
            }
        }

        vm.warp(block.timestamp + 31 days);
        vm.prank(Admin);
        iLR.bulkPeriodicUpdate(address(Nova));
        (uint256 avComm, uint256 avRep) = iLR.getAvReputationAndCommitment(address(Nova));
        int64[4] memory archetypeData = iLR.getArchetypeData(address(Nova));

        assertTrue(archetypeData[0] < 100, "diff still 100");
        console.logInt(archetypeData[1]);
        assertTrue(archetypeData[1] > 100, "members not added");
        assertTrue(archetypeData[3] > 4, "same average commitment");
        assertTrue(prevArchetypeData[2] != archetypeData[2], "average reputation unchanged");

        // console.logInt(archetypeData[0]);
        // console.log(uint64(archetypeData[1]));
        // console.log(uint64(archetypeData[2]));
        // console.log(uint64(archetypeData[3]));
    }

    function testMembershipDiff() public {
        testArchetypeUpd2();

        address[] memory members = aID.getAllActiveMembers(address(Nova));

        uint256 i = 5;

        for (i; i < members.length;) {
            if (i % 2 == 0) {
                vm.prank(members[i]);
                InteractionPlugin.incrementNumber("averyrandomstring");
                vm.prank(members[i]);
                aID.withdraw(address(Nova));
            }

            unchecked {
                ++i;
            }
        }

        vm.warp(block.timestamp + 31 days);

        vm.prank(Admin);
        iLR.bulkPeriodicUpdate(address(Nova));

        (uint256 avComm, uint256 avRep) = iLR.getAvReputationAndCommitment(address(Nova));
        int64[4] memory archetypeData = iLR.getArchetypeData(address(Nova));

        address[] memory allMembers2 = aID.getAllActiveMembers(address(Nova));

        assertTrue(archetypeData[0] < 0, "expected negative on lost members");
        assertTrue(members.length > allMembers2.length, "members left for negative diff");
        assertTrue(
            int64(int256(allMembers2.length)) - int64(int256(members.length)) == archetypeData[0], "expected diff"
        );

        // console.logInt(archetypeData[0]);
        // console.log(uint64(archetypeData[1]));
        // console.log(uint64(archetypeData[2]));
        // console.log(uint64(archetypeData[3]));
    }
}
