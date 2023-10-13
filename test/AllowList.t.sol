// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {DeploysInit} from "./DeploysInit.t.sol";

import {IAllowlist} from "../contracts/utils/IAllowlist.sol";

import "forge-std/console.sol";
//// @notice Tests Basic Deployment attainable

contract AllowListT is DeploysInit {
    address notOwner;
    address notOwner2;
    address notOwner3;
    address notOwner4;

    function setUp() public override {
        super.setUp();

        assertTrue(AList.isAllowedOwner(A0), "assumed A0 is owner");

        notOwner = address(324567234565346578676543875867465543200);
        vm.label(notOwner, "notOwner");
        notOwner2 = address(6456723456324999995346578676543875211);
        vm.label(notOwner2, "notOwner2");

        notOwner3 = address(6464593926354346545364752545754574556734563);
        vm.label(notOwner3, "notOwner3");

        notOwner4 = address(12812893475342897583648346);
        vm.label(notOwner4, "notOwner4");
    }

    function testAllowListSequence() public {
        assertFalse(AList.isAllowedOwner(notOwner), "rando is owner");
        assertFalse(AList.canAllowList(notOwner2), "rando can allow");

        vm.expectRevert(IAllowlist.Unallowed.selector);
        vm.prank(notOwner);
        AList.addOwner(notOwner2);

        vm.expectRevert();
        vm.prank(notOwner2);
        AList.addOwner(notOwner2);

        vm.prank(A0);
        AList.addOwner(notOwner);
        address nowOwner = notOwner;
        assertTrue(AList.isOwner(nowOwner), "rando now owner");
        assertTrue(AList.isAllowedOwner(nowOwner), "rando is allowed");
        assertTrue(AList.canAllowList(nowOwner), "expected plus one");

        vm.prank(nowOwner);
        AList.addToAllowlist(notOwner2);
        assertFalse(AList.isOwner(notOwner2), "unexpected as owenr");
        assertTrue(AList.plusOne(notOwner2) == address(0), "expected not allowed 2");

        assertTrue(AList.canAllowList(notOwner2), "is not plusone");

        /// @dev owner can grant plusone

        address[] memory toAddToAllowList = new address[](2);
        toAddToAllowList[0] = notOwner3;
        toAddToAllowList[1] = notOwner4;
        assertFalse(AList.isOwner(notOwner3), "not owner 3");
        assertFalse(AList.isAllowedOwner(notOwner4), "not allowed 4");
        // assertFalse(AList.canAllowList(notOwner3), "cannot allow 3");

        vm.expectRevert();
        AList.addBatchToAllowlist(toAddToAllowList);

        vm.prank(A0);
        AList.addBatchToAllowlist(toAddToAllowList);

        assertFalse(AList.isAllowedOwner(notOwner3), "not allowed 3");
        assertTrue(AList.isAllowed(notOwner4), "has been batch allowed");
        assertTrue(AList.isAllowed(notOwner3), "has been batch allowed");

        assertTrue(AList.plusOne(notOwner4) == address(0), "already plusone");
        assertTrue(AList.isAllowListed(notOwner4), "not allowlisted");
        assertTrue(AList.canAllowList(notOwner4), "cannot allow 4");

        address plussOneTarget = address(1342669543586474559786);
        vm.prank(A0);
        AList.addToAllowlist(plussOneTarget);

        assertTrue(AList.isAllowListed(plussOneTarget), "not allowlisted wut 1");
        assertTrue(AList.canAllowList(plussOneTarget), "cannot plusone 2");
        assertFalse(AList.isOwner(plussOneTarget), "not over 3");

        address cluelessFren = address(23567754634697);
        assertFalse(AList.isAllowed(cluelessFren), "already allowed");

        vm.prank(plussOneTarget);
        AList.addToAllowlist(cluelessFren);

        vm.prank(plussOneTarget);
        vm.expectRevert();
        AList.addToAllowlist(cluelessFren);

        vm.prank(plussOneTarget);
        vm.expectRevert();
        AList.addToAllowlist(address(346787965447987878787878787128128128));
    }
}
