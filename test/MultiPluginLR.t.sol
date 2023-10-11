// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {DeploysInit} from "./DeploysInit.t.sol";

import {LocalReputation} from "../contracts/LocalReputation.sol";
import "../contracts/ILocalReputation.sol";
import {SocialBotPlugin} from "../contracts/plugins/interactions/SocialBotPlugin.sol";

import "forge-std/console.sol";

contract MultiPluginLR is DeploysInit {
    function setUp() public override {
        super.setUp();
    }
}
