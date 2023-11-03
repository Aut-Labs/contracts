// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {DeploysInit} from "./DeploysInit.t.sol";
// import {INova} from "../contracts/nova/interfaces/INova.sol";
import {Nova} from "../contracts/nova/interfaces/Nova.sol";

//// @notice Tests Basic Nova Deploy
contract BasicNovaDeploy is DeploysInit {

        function setUp() public override {
        super.setUp();

        }


        function testDeploysNova() public {
            vm.prank(A0);
            address NovaInstance = INR.deployNova(2, "stringMetadata",6);
            
            assertTrue(address(NovaInstance).code.length > 0, "no code at address");
            assertTrue(INova(NovaInstance).admins().length >=1, "first admin not A0");


        }

}