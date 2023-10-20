// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {DeploysInit} from "./DeploysInit.t.sol";

import {LocalReputation} from "../contracts/LocalReputation.sol";
import "../contracts/ILocalReputation.sol";
import {SocialBotPlugin} from "../contracts/plugins/interactions/SocialBotPlugin.sol";

import {OffchainTaskWithRep} from "../contracts/plugins/interactions/OffchainTaskWithRep.sol";
import {OpenTaskWithRep} from "../contracts/plugins/interactions/OpenTaskWithRep.sol";

import "forge-std/console.sol";

contract MultiPluginLR is DeploysInit {
    OffchainTaskWithRep offTWR;
    OpenTaskWithRep openTWR;

    function setUp() public override {
        super.setUp();

        vm.startPrank(A0);

        offTWR = new OffchainTaskWithRep(address(Nova));
        openTWR = new OpenTaskWithRep(address(Nova));

        uint256[] memory mockdependencies;
        uint256 aDefID1 = IPR.addPluginDefinition(payable(A0), "a metadata string", 0, true, mockdependencies);
        uint256 aDefID2 = IPR.addPluginDefinition(payable(A0), "a metadata string 2", 0, true, mockdependencies);

        IPR.addPluginToDAO(address(offTWR), aDefID1);
        IPR.addPluginToDAO(address(openTWR), aDefID2);

        vm.stopPrank();
    }
}
