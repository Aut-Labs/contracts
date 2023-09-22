//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {DeploysInit} from "./DeploysInit.t.sol";

import {QuestOnboardingPlugin} from "../contracts/plugins/onboarding/QuestOnboardingPlugin.sol";
import {QuestPlugin} from "../contracts/plugins/quests/QuestPlugin.sol";

import {OffchainVerifiedTaskPlugin} from "../contracts/plugins/tasks/OffchainVerifiedTaskPlugin.sol";
import "forge-std/console.sol";
//// @notice Tests Basic Deployment attainable

contract ModuleSkip is DeploysInit {
    function setUp() public override {
        super.setUp();
    }

    function testPluginInstallModule() public {
        vm.skip(true);
    }



}