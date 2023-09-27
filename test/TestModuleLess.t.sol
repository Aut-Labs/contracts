// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {DeploysInit} from "./DeploysInit.t.sol";

import {SampleInteractionPlugin} from "../contracts/plugins/interactions/SampleInteractionPlugin.sol";

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
