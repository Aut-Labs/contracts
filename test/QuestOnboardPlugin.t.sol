// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {DeploysInit} from "./DeploysInit.t.sol";

import {QuestOnboardingPlugin} from "../contracts/plugins/onboarding/QuestOnboardingPlugin.sol";
import {QuestPlugin} from "../contracts/plugins/quests/QuestPlugin.sol";

import {OffchainVerifiedTaskPlugin} from "../contracts/plugins/tasks/OffchainVerifiedTaskPlugin.sol";
import "forge-std/console.sol";
//// @notice Tests Basic Deployment attainable

contract TestQuestPlugin is DeploysInit {
    QuestOnboardingPlugin QOP;
    QuestPlugin QuestP;
    OffchainVerifiedTaskPlugin TaskPlugin;

    address offchainVerifier = address(256128256128000);
    uint256 taskPluginId;

    function setUp() public override {
        super.setUp();

        QOP = new QuestOnboardingPlugin(address(Nova));
        vm.label(address(QOP), "QuestOnboardingPlugin");

        QuestP = QuestPlugin(QOP.getQuestsPluginAddress());
        vm.label(address(QuestP), "QuestPlugin");

        TaskPlugin = new OffchainVerifiedTaskPlugin(address(Nova), offchainVerifier );
        vm.label(address(TaskPlugin), "TasksPlugin");

        uint256[] memory depmodrek;

        vm.prank(A0);
        uint256 pluginDefinitionID =
            IPR.addPluginDefinition(payable(A1), "owner can spoof metadata", 0, true, depmodrek);

        console.log("Created plugin definitinion ID --- :  ", pluginDefinitionID);
        vm.prank(A0);
        IPR.addPluginToDAO(address(TaskPlugin), pluginDefinitionID);

        taskPluginId = IPR.tokenIdFromAddress(address(TaskPlugin));
    }

    function testActivateQuest() public {
        vm.prank(A1);
        vm.expectRevert("Not an admin.");
        QOP.setActive(true);

        vm.startPrank(A0); //deployer is admin
        skip(100);

        vm.expectRevert("at least one quest needs to be defined");
        QOP.setActive(true);

        uint256 questID = QuestP.create(1, "uriCID", block.timestamp + 10, 1);
        assertTrue(questID != 0, "expected id");

        vm.expectRevert("at least one quest must have tasks");
        QOP.setActive(true);

        console.log(taskPluginId);
        QuestP.createTask(questID, taskPluginId, "taskUriMetadata");

        QOP.setActive(true); /////// sets active in

        QuestP.setQuestState(true, questID);
    }
}
