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
        BotPlugin.applyEventConsequences(participants, participationPoints, maxPossiblePointsPerUser, categoryOrDescription);

        vm.prank(A0);
        BotPlugin.applyEventConsequences(participants, participationPoints, maxPossiblePointsPerUser, categoryOrDescription);

        assertTrue(BotPlugin.getAllBotInteractions().length  == 1, "not one interaction");
    }
}
