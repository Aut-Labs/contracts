// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {DeploysInit} from "./DeploysInit.t.sol";

import {SampleInteractionPlugin} from "../contracts/plugins/interactions/SampleInteractionPlugin.sol";

import "forge-std/console.sol";
//// @notice Tests Basic Deployment attainable

contract ModuleSkipTemp is DeploysInit {
    uint256 pluginDefinitionID0;
    uint256 pluginDefinitionID1;
    uint256 pluginDefinitionID2;
    uint256 pluginDefinitionID3;

    SampleInteractionPlugin SampleIP0;
    SampleInteractionPlugin SampleIP1;
    SampleInteractionPlugin SampleIP2;
    SampleInteractionPlugin SampleIP3;

    function setUp() public override {
        super.setUp();

        vm.prank(A0);
        SampleIP0 = new SampleInteractionPlugin(address(Nova));
        vm.label(address(SampleIP0), "plugin0");
        vm.prank(A0);
        SampleIP1 = new SampleInteractionPlugin(address(Nova));
        vm.label(address(SampleIP1), "plugin1");
        vm.prank(A0);
        SampleIP2 = new SampleInteractionPlugin(address(Nova));
        vm.label(address(SampleIP2), "plugin2");
        vm.prank(A0);
        SampleIP3 = new SampleInteractionPlugin(address(Nova));
        vm.label(address(SampleIP3), "plugin3");

        uint256[] memory dependencyModules;

        vm.prank(A0);
        pluginDefinitionID0 = IPR.addPluginDefinition(
            payable(A1), "owner controled metadata might need moderation", 0, true, dependencyModules
        );

        vm.prank(A0);
        pluginDefinitionID1 =
            IPR.addPluginDefinition(payable(A1), "owner controled metadata 2", 0, true, dependencyModules);

        dependencyModules = new uint256[](2);
        dependencyModules[0] = 1;
        dependencyModules[1] = 2;

        vm.prank(A0);
        pluginDefinitionID2 = IPR.addPluginDefinition(
            payable(A1), "owner controled metadata might need moderation", 0, true, dependencyModules
        );

        vm.prank(A0);
        pluginDefinitionID3 =
            IPR.addPluginDefinition(payable(A1), "owner controled metadata not duplicate", 3, true, dependencyModules);
    }

    function testPluginInstallModule() public {
        vm.prank(A0);
        IPR.addPluginToDAO(address(SampleIP1), pluginDefinitionID1);
        vm.prank(A0);
        IPR.addPluginToDAO(address(SampleIP2), pluginDefinitionID2);
    }

    function testInstallSocialBot() public {
        vm.prank(A0);
        IPR.addPluginToDAO(address(SampleIP1), pluginDefinitionID1);
        vm.prank(A0);
        IPR.addPluginToDAO(address(SampleIP2), pluginDefinitionID2);
    }
}
