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

        iLR = ILocalReputation(address(LocalRepAlgo));

        vm.prank(A1);
        aID.mint("a Name", "urlll", 1, 4, address(Nova));

        InteractionPlugin = new SampleInteractionPlugin(address(Nova), address(iLR) );
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

    function testPluginIsAutohrised() public {
        assertTrue(iLR.isAuthorised(address(InteractionPlugin), address(Nova)), "expected plugin authorised via init");
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

        uint256 i = 1;
        for (i; i < 100;) {
            points[0] = firsPoints;
            points[1] = secondPoints;

            vm.prank(Admin);
            iLR.setInteractionWeights(address(InteractionPlugin), datas, points);

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

            console.log("Members nr - TCL - TCP", members.length, GSbefore.TCL, GSbefore.TCP);
        }
        assertTrue(iLR.getGroupState(address(Nova)).lastPeriod > 1, "lastPeriod not block.timestamp");
    }

    function testSimpleGroupPeriodicUpdate() public {
        vm.warp(block.timestamp + 100 days);
        testWithSameCommitmentPeriod();
        groupState memory GSbefore = iLR.getGroupState(address(Nova));

        uint256 nextUpdateAt = iLR.periodicGroupStateUpdate(address(Nova));
        iLR.bulkPeriodicUpdate(address(Nova));

        groupState memory GSafer = iLR.getGroupState(address(Nova));

        nextUpdateAt = GSafer.lastPeriod + GSafer.p;

        assertTrue(nextUpdateAt >= block.timestamp, "should be later");
        assertTrue(nextUpdateAt >= GSbefore.lastPeriod + GSbefore.p, "period increment fault");
    }

    function testIndividualLRUpdate() public {
        address A55 = address(5);
        vm.expectRevert(ILocalReputation.ZeroUnallawed.selector);
        uint256 prevScore = iLR.updateIndividualLR(A55, address(Nova));
        assertTrue(prevScore == 0, "No update score is blank");
        testWithSameCommitmentPeriod();

        vm.warp(block.timestamp + 31 days);
        uint256 newScore = iLR.updateIndividualLR(A55, address(Nova));
        assertTrue(newScore > 1, "not updated");

        uint256 nextUpdateAt = iLR.periodicGroupStateUpdate(address(Nova));

        vm.warp(nextUpdateAt + 1);
        iLR.periodicGroupStateUpdate(address(Nova));

        newScore = iLR.updateIndividualLR(A55, address(Nova));
        assertTrue(newScore > 1, "has actual score");
    }

    function testPeriodFlip() public {
        console.log("ILR23r323r", address(iLR));

        testWithSameCommitmentPeriod();

        vm.expectRevert(ILocalReputation.PeriodUnelapsed.selector);
        uint256[] memory scores1 = iLR.bulkPeriodicUpdate(address(Nova));

        vm.warp(block.timestamp + (30 * 1 days));
        scores1 = iLR.bulkPeriodicUpdate(address(Nova));

        uint256 i;

        for (i; i < scores1.length;) {
            console.log("agent ", vm.toString(i), " -- ", scores1[i]);
            unchecked {
                ++i;
            }
        }
    }

    // function skiptestLRSimulFormula() public {
    //     return;
    //     uint256 numberOfPeriods = 10;
    //     uint256 numberOfMembers = 3;
    //     uint256 TCMgrowth = 10;
    //     uint256 TCMdecline = 5000;

    //     uint256 iGC = 100;
    //     uint256 TCL = 300;
    //     uint256 TCP = 1000;
    //     uint256 k = 30;
    //     uint256 prevScore = 1;

    //     uint256 i;
    //     for (i; i < 10;) {
    //         prevScore *= TCMgrowth;
    //         if (i < 3) {} else {}
    //         uint256 score = iLR.calculateLocalReputation(iGC, 9999, TCL, TCP, k, prevScore);

    //         console.log(vm.toString(i), "  -  ", vm.toString(score));

    //         ++i;
    //     }
    // }
}
