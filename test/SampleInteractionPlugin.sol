//SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {DeploysInit} from "./DeploysInit.t.sol";

import {LocalRep} from "../contracts/plugins/interactions/LocalReputation.sol";
import {ILocalReputation} from "../contracts/plugins/interactions/ILocalReputation.sol";
import {SampleInteractionPlugin} from "../contracts/plugins/interactions/SampleInteractionPlugin.sol";

contract TestSampleInteractionPlugin is DeploysInit {
    LocalRep LocalRepAlgo;
    ILocalReputation iLR;
    SampleInteractionPlugin InteractionPlugin;

    uint256 taskPluginId;

    function setUp() public override {
        super.setUp();

        LocalRepAlgo = new LocalRep();
        vm.label(address(LocalRepAlgo), "LocalRep");

        iLR = ILocalReputation(address(LocalRepAlgo));

        InteractionPlugin = new SampleInteractionPlugin(address(Nova), address(iLR) );
        vm.label(address(InteractionPlugin), "InteractionPlugin");

        vm.prank(A1);
        aID.mint("a Name","urlll",1,4,address(Nova));



        uint256[] memory depmodrek;

        vm.prank(A0);
        uint256 pluginDefinitionID =
            IPR.addPluginDefinition(payable(A1), "owner can spoof metadata", 0, true, depmodrek);

        vm.prank(A0);
        IPR.addPluginToDAO(address(InteractionPlugin), pluginDefinitionID);

        taskPluginId = IPR.tokenIdFromAddress(address(InteractionPlugin));
    }

    function testUnconfiguredInteraction() public {
        uint256 number1 = InteractionPlugin.number();
        InteractionPlugin.incrementNumber();
    }
}
