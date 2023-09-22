//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {DeploysInit} from "./DeploysInit.t.sol";

import {LocalRep} from "../contracts/plugins/interactions/LocalReputation.sol";
import "../contracts/plugins/interactions/ILocalReputation.sol";
import {SampleInteractionPlugin} from "../contracts/plugins/interactions/SampleInteractionPlugin.sol";

import "forge-std/console.sol";

contract TestLRFuzz is DeploysInit {
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
        vm.writeFile(
            "test/testData/LRfuzzDataOut.csv",
            "iGivenContribution,indivContribLevel, sumContribLevel,sumContribPoints,prevScore,newScore \n"
        );
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
        iGC = bound(iGC, 1, 700);
        iCL = bound(iCL, 1, 10);
        TCL = bound(TCL, 10, 3000);
        TCP = bound(TCP, 2, 70000);

        penalty = bound(penalty, 2, 40);
        k = bound(k, 30, 40);

        prevscore = bound(prevscore, 0.01 ether, 9 ether);

        vm.assume(iCL < TCL);
        vm.assume(iGC < TCP);

        score = iLR.calculateLocalReputation(iGC, iCL, TCL, TCP, k, prevscore, penalty);
        vm.writeLine(
            "test/testData/LRfuzzDataOut.csv",
            string.concat(
                string.concat(
                    vm.toString(iGC),
                    ",",
                    vm.toString(iCL),
                    ",",
                    vm.toString(TCL),
                    ",",
                    vm.toString(TCP),
                    ",",
                    vm.toString(prevscore),
                    ",",
                    vm.toString(score)
                )
            )
        );
        assertTrue(score <= 10 ether, "expected max 10");
        assertTrue(score >= 0.01 ether, "expected min 0.01");
    }
}
