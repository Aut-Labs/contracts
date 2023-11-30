// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {DeploysInit} from "./DeploysInit.t.sol";
import {IAllowlist} from "../contracts/utils/IAllowlist.sol";
import {INova} from "../contracts/nova/interfaces/INova.sol";
import {Nova} from "../contracts/nova/Nova.sol";
import "forge-std/console.sol";

//// @notice Tests Basic Nova Deploy
contract SpecificDesignTests is DeploysInit {

    function setUp() public override {
        super.setUp();
    }

    function testInteractionIDSpace(address A, bytes memory X) public {
        console.log("=========", vm.toString(A), vm.toString(X)); 
        uint256 id = iLR.interactionID(A, X);
        assertTrue(id > 1 ether);
    }

}

