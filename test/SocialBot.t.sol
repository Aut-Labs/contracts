//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {DeploysInit} from "./DeploysInit.t.sol";

import {LocalReputation} from "../contracts/LocalReputation.sol";
import "../contracts/ILocalReputation.sol";
import {SocialBotPlugin} from "../contracts/plugins/interactions/SocialBotPlugin.sol";

import "forge-std/console.sol";

contract TestSocialBotPlugin is DeploysInit {
    LocalReputation LocalRepAlgo;
    SocialBotPlugin BotPlugin;

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

        vm.prank(A2);
        aID.mint("a Name", "urlll", 1, 6, address(Nova));

        vm.prank(A3);
        aID.mint("a Name", "urlll", 1, 9, address(Nova));

        vm.prank(A0);
        BotPlugin = new SocialBotPlugin(address(Nova) );
        vm.label(address(BotPlugin), "InteractionPlugin");

        uint256[] memory depmodrek;

        vm.prank(A0);
        uint256 pluginDefinitionID =
            IPR.addPluginDefinition(payable(A1), "owner can spoof metadata", 0, true, depmodrek);

        vm.prank(A0);
        IPR.addPluginToDAO(address(BotPlugin), pluginDefinitionID);

        taskPluginId = IPR.tokenIdFromAddress(address(BotPlugin));

        Admin = A0;
        assertTrue(Nova.isAdmin(Admin), "expected deployer admin");
        assertFalse(Nova.isMember(Admin), "deployer admin is member");
    }

    function testSocialBot() public {
        address[] memory participants = new address[](1);
        uint16[] memory participationPoints = new uint16[](1);
        uint16 maxPossiblePointsPerUser = 1000;
        string memory categoryOrDescription = "Community Meeting 7";

        vm.expectRevert(SocialBotPlugin.NotAdmin.selector);
        BotPlugin.applyEventConsequences(
            participants, participationPoints, maxPossiblePointsPerUser, categoryOrDescription
        );

        vm.prank(A0);
        BotPlugin.applyEventConsequences(
            participants, participationPoints, maxPossiblePointsPerUser, categoryOrDescription
        );

        assertTrue(BotPlugin.getAllBotInteractions().length == 1, "not one interaction");
    }

    function testBotAltersLR() public {
        address[] memory participants = new address[](2);
        uint16[] memory participationPoints = new uint16[](2);
        uint16 maxPossiblePointsPerUser = 640;
        string memory categoryOrDescription = "Community Meeting 7";
        address novaAddr = address(Nova);

        participants[0] = A2;
        participants[1] = A3;
        participationPoints[0] = 80;
        participationPoints[1] = 240;

        assertTrue(Nova.isMember(A2), "A2 not member");
        assertTrue(Nova.isMember(A3), "A3 not member");

        vm.expectRevert(SocialBotPlugin.NotAdmin.selector);
        BotPlugin.applyEventConsequences(
            participants, participationPoints, maxPossiblePointsPerUser, categoryOrDescription
        );

        periodData memory P0 = iLR.getPeriodNovaParameters(address(novaAddr));
        groupState memory GS0 = iLR.getGroupState(novaAddr);
        individualState memory IS0 = iLR.getIndividualState(A1, novaAddr);

        console.log("Average rep. | Average perf. | A1 givenC ", P0.cAverageRepLP, P0.ePerformanceLP, IS0.GC);

        vm.prank(A0);
        BotPlugin.applyEventConsequences(
            participants, participationPoints, maxPossiblePointsPerUser, categoryOrDescription
        );

        periodData memory P1 = iLR.getPeriodNovaParameters(address(novaAddr));
        groupState memory GS1 = iLR.getGroupState(novaAddr);
        individualState memory IS1 = iLR.getIndividualState(A1, novaAddr);

        console.log("Average rep. | Average perf. | A1 givenC ", P1.cAverageRepLP, P1.ePerformanceLP, IS1.GC);

        vm.expectRevert();
        iLR.bulkPeriodicUpdate(novaAddr);
        individualState memory IS2 = iLR.getIndividualState(A2, novaAddr);

        skip(block.timestamp + 32 days);

        vm.prank(A0);
        iLR.bulkPeriodicUpdate(novaAddr);

        periodData memory P2 = iLR.getPeriodNovaParameters(address(novaAddr));
        groupState memory GS2 = iLR.getGroupState(novaAddr);

        vm.prank(A0);
        BotPlugin.applyEventConsequences(
            participants, participationPoints, maxPossiblePointsPerUser, categoryOrDescription
        );

        IS2 = iLR.getIndividualState(A2, novaAddr);

        console.log("Average rep. | Average perf. | A1 givenC ", P2.cAverageRepLP, P2.ePerformanceLP, IS2.GC);
    }

    function testMemebrshpInversePerformance() public {
        vm.skip(true);
        testBotAltersLR();
    }

    function testNonMemberReputation() public {
        vm.skip(true);
        /// thesis: non-members can have reputation obtained through meeting attendence
        /// outcome: social participation can be a potential onboarding strategy
        testBotAltersLR();
    }
}
