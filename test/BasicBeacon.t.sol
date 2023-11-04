// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {DeploysInit} from "./DeploysInit.t.sol";
import {IAllowlist} from "../contracts/utils/IAllowlist.sol";
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

    function testCannotMultiDeploywAllow() public {
        //// thesis: logic bug in feature that conditions that while allowlist is live, only 1 new nova per address

        /// deployer can do this
        vm.prank(A0);
        INR.deployNova(1, "stringMetadata1", 6);
                vm.prank(A0);
        INR.deployNova(2, "stringMetadata2", 7);
                vm.prank(A0);
        INR.deployNova(3, "stringMetadata3", 8);

        /// any other address cannot
        assertFalse(AList.isAllowed(A1), "not allowed");
        vm.prank(A0);
        AList.addOwner(A1);
        assertTrue(AList.isAllowed(A1), "not allowed");
        vm.prank(A1);
        INR.deployNova(1, "stringMetadata1", 6);
        
        vm.prank(A1);
        vm.expectRevert(IAllowlist.AlreadyDeployedANova.selector);
        INR.deployNova(2, "stringMetadata2", 7);

    }
}
