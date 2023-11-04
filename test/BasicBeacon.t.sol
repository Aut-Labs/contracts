// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {DeploysInit} from "./DeploysInit.t.sol";
// import {INova} from "../contracts/nova/interfaces/INova.sol";
import {INova} from "../contracts/nova/interfaces/INova.sol";
import {Nova} from "../contracts/nova/Nova.sol";

import "forge-std/console.sol";

//// @notice Tests Basic Nova Deploy
contract BasicNovaDeploy is DeploysInit {
    function setUp() public override {
        super.setUp();
    }

    function testDeploysNova() public returns (address NovaInstance) {
        vm.prank(A0);
        NovaInstance = INR.deployNova(2, "stringMetadata", 6);

        assertTrue(address(NovaInstance).code.length > 0, "no code at address");
        // assertTrue(INova(NovaInstance).admins().length >=1, "first admin not A0");
    }

    function testBeaconProxy() public {
        address n = testDeploysNova();
        console.log("=========");
        assertTrue(INova(n).getAdmins()[0] == A0, "deployer not admin");

        vm.prank(A0);
        INova(n).setMetadataUri("a metadata uri httppp sdgfsd");

        assertTrue(INova(n).deployer() == A0, "deployer should be a0");
        assertFalse(INova(n).isMember(A1), "member why");
        assertFalse(INova(n).isMember(A0), "member not");
    }
}
