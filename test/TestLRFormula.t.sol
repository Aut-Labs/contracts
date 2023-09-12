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
    }


    function testfuzzLRFormula(
        uint256 iGC,
        uint256 iCL,
        uint256 TCL,
        uint256 TCP,
        uint256 k,
        uint256 prevscore,
        uint256 penalty
    ) public returns (uint256 score) {
        iGC = bound(iGC, 1, 10234);
        iCL = bound(iCL, 2, 10);
        TCL = bound(TCL, 10, 1 ether);
        TCP = bound(TCP, 2, 1 ether);

        penalty = bound(penalty, 2, 99);
        k = bound(k, 1000, 10_000);

        prevscore = bound(prevscore, 100, 10_000);
        vm.assume(iCL < TCL);
        vm.assume(iGC < TCP);

        score = iLR.calculateLocalReputation(iGC, iCL, TCL, TCP, k, prevscore, penalty);
        console.log(score);
    }




}
