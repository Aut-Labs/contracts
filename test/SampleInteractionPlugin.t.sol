//SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

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

        vm.expectRevert(LocalRep.OnlyAdmin.selector);
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

    // function testWithSameCommitmentPeriod(uint256 membersAmt, uint256 firsPoints, uint256 secondPoints) public {
    //     vm.assume(membersAmt  < 99);

    //     vm.assume(firsPoints < 100);
    //     vm.assume(secondPoints < 100);

    //     bytes[] memory datas = new bytes[](2);
    //     uint256[] memory points = new uint256[](2);

    //     datas[0] = abi.encodePacked(InteractionPlugin.incrementNumberPlusOne.selector);
    //     datas[1] = abi.encodeWithSelector(InteractionPlugin.incrementNumber.selector, "averyrandomstring");

    //     points[0] = firsPoints;
    //     points[1] = secondPoints;

    //     vm.prank(Admin);
    //     iLR.setInteractionWeights(address(InteractionPlugin), datas, points);

    //     uint256 i = 1;
    //     for (i; i< membersAmt;) {

    //     vm.prank(address(uint160(i)));
    //     aID.mint(vm.toString(i), "urlll", 1, 4, address(Nova));

    //     vm.warp(block.timestamp + 1);

    //     vm.prank(address(uint160(i)));
    //     ( i % 2 == 0) ? InteractionPlugin.incrementNumberPlusOne() : InteractionPlugin.incrementNumber("averyrandomstring");

    //     vm.warp(block.timestamp + 1);

    //         unchecked {
    //             ++i;
    //         }
    //                         address[] memory members = Nova.getAllMembers();
    //     groupState memory GSbefore = iLR.getGroupState(address(Nova));
    //     console.log("Members nr - TCL - TCP", members.length, GSbefore.TCL,GSbefore.TCP);

    //     }

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
}
