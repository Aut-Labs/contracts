//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {DeploysInit} from "./DeploysInit.t.sol";

import {LocalReputation} from "../contracts/LocalReputation.sol";
import "../contracts/ILocalReputation.sol";
import {SampleInteractionPlugin} from "../contracts/plugins/interactions/SampleInteractionPlugin.sol";

import "forge-std/console.sol";

contract TestSampleInteractionPlugin is DeploysInit {
    LocalReputation LocalRepAlgo;
    SampleInteractionPlugin InteractionPlugin;

    uint256 taskPluginId;
    address Admin;

    function setUp() public override {
        uint256 time0 = block.timestamp == 0 ? 1699999999 : block.timestamp;
        vm.warp(time0 + 1);

        super.setUp();

        LocalRepAlgo = new LocalReputation();
        vm.label(address(LocalRepAlgo), "LocalRep");

        vm.prank(IPR.owner());
        IPR.setDefaulLRAddress(address(LocalRepAlgo));

        iLR = ILocalReputation(IPR.defaultLRAddr());
        vm.label(address(iLR), "LocalReputation");

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
        assertFalse(Nova.isMember(Admin), "deployer admin is member");
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
        uint16[] memory points = new uint16[](2);

        datas[0] = abi.encodePacked(InteractionPlugin.incrementNumberPlusOne.selector);
        datas[1] = abi.encodeWithSelector(InteractionPlugin.incrementNumber.selector, "averyrandomstring");

        points[0] = 5;
        points[1] = 9;

        vm.expectRevert(ILocalReputation.OnlyAdmin.selector);
        iLR.setInteractionWeights(address(InteractionPlugin), datas, points);

        vm.prank(Admin);
        iLR.setInteractionWeights(address(InteractionPlugin), datas, points);

        InteractionPlugin.number();
        testUnconfiguredInteraction();
        InteractionPlugin.number();

        individualState memory IS1 = iLR.getIndividualState(A2, address(Nova));

        vm.prank(A2);
        InteractionPlugin.incrementNumberPlusOne();

        individualState memory IS2 = iLR.getIndividualState(A2, address(Nova));
        assertTrue(IS2.GC > 0, "has some points");
        assertTrue(IS1.GC < IS2.GC, "no points gained");

        vm.prank(A1);
        InteractionPlugin.incrementNumber("averyrandomstring");
        individualState memory IS3 = iLR.getIndividualState(A1, address(Nova));
        assertTrue(IS3.GC >= 9, "function arg points mismatch");
        console.log(IS3.GC);
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
        uint16 firsPoints = 1;
        uint16 secondPoints = 5;

        bytes[] memory datas = new bytes[](2);
        uint16[] memory points = new uint16[](2);

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

        vm.expectRevert(ILocalReputation.Unauthorised.selector);
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

    function testperiodTypeDataUpdates() public {
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

        periodData memory periodTypeData = iLR.getPeriodNovaParameters(address(Nova));

        assertTrue(periodTypeData.aDiffMembersLP > 1, "exp members were added");

        assertTrue(uint256(uint32(periodTypeData.bMembersLastLP)) == allMembers.length);
        assertTrue(uint256(uint64(periodTypeData.cAverageRepLP)) == avRep, "should be same lifecycle");
        assertTrue(uint256(uint64(periodTypeData.dAverageCommitmentLP)) == avComm, "all were 4");
    }

    function testperiodTypeUpd2() public {
        testPeriodFlip();
        periodData memory prevperiodTypeData = iLR.getPeriodNovaParameters(address(Nova));

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
        periodData memory periodTypeData = iLR.getPeriodNovaParameters(address(Nova));

        assertTrue(periodTypeData.aDiffMembersLP < 100, "diff still 100");
        console.logInt(periodTypeData.bMembersLastLP);
        console.log(periodTypeData.cAverageRepLP);
        assertTrue(periodTypeData.cAverageRepLP > 100, "members not added");
        assertTrue(periodTypeData.dAverageCommitmentLP > 4, "same average commitment");
    }

    function testMembershipDiff() public {
        testperiodTypeUpd2();

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
        periodData memory periodTypeData = iLR.getPeriodNovaParameters(address(Nova));

        address[] memory allMembers2 = aID.getAllActiveMembers(address(Nova));

        assertTrue(periodTypeData.aDiffMembersLP < 0, "expected negative on lost members");
        assertTrue(members.length > allMembers2.length, "members left for negative diff");
        assertTrue(
            int64(int256(allMembers2.length)) - int64(int256(members.length)) == periodTypeData.aDiffMembersLP,
            "expected diff"
        );

        assertTrue(periodTypeData.ePerformanceLP > 0, "expected performance score");
    }

    function testPerformanceChanges() public {
        testperiodTypeDataUpdates();

        uint256 i = 1;

        for (i; i < 100;) {
            vm.prank(address(uint160(i)));
            (i % 2 == 0)
                ? InteractionPlugin.incrementNumberPlusOne()
                : InteractionPlugin.incrementNumber("averyrandomstring");

            (i % 2 == 0)
                ? InteractionPlugin.incrementNumberPlusOne()
                : InteractionPlugin.incrementNumber("averyrandomstring");

            (i % 2 == 0)
                ? InteractionPlugin.incrementNumberPlusOne()
                : InteractionPlugin.incrementNumber("averyrandomstring");

            (i % 2 == 0)
                ? InteractionPlugin.incrementNumberPlusOne()
                : InteractionPlugin.incrementNumber("averyrandomstring");

            vm.warp(block.timestamp + 1);

            unchecked {
                ++i;
            }
        }
        vm.warp(block.timestamp + 31 days);

        vm.prank(A0);
        iLR.bulkPeriodicUpdate(address(Nova));

        periodData memory periodTypeData = iLR.getPeriodNovaParameters(address(Nova));
        console.log(periodTypeData.ePerformanceLP);
        uint64 performance1 = periodTypeData.ePerformanceLP;

        i = 1;

        for (i; i < 100;) {
            vm.prank(address(uint160(i)));
            (i % 2 == 0)
                ? InteractionPlugin.incrementNumberPlusOne()
                : InteractionPlugin.incrementNumber("averyrandomstring");

            (!(i % 2 == 0))
                ? InteractionPlugin.incrementNumberPlusOne()
                : InteractionPlugin.incrementNumber("averyrandomstring");

            (i % 2 == 0)
                ? InteractionPlugin.incrementNumberPlusOne()
                : InteractionPlugin.incrementNumber("averyrandomstring");

            (i % 2 == 0)
                ? InteractionPlugin.incrementNumberPlusOne()
                : InteractionPlugin.incrementNumber("averyrandomstring");

            vm.warp(block.timestamp + 1);

            unchecked {
                ++i;
            }
        }
        vm.warp(block.timestamp + 31 days);

        vm.prank(A0);
        iLR.bulkPeriodicUpdate(address(Nova));

        periodTypeData = iLR.getPeriodNovaParameters(address(Nova));
        console.log(periodTypeData.ePerformanceLP);
        uint64 performance2 = periodTypeData.ePerformanceLP;

        assertTrue(performance2 != performance1, "equally performant");
    }
}
