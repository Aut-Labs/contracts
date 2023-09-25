// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {DeploysInit} from "./DeploysInit.t.sol";

import {QuestOnboardingPlugin} from "../contracts/plugins/onboarding/QuestOnboardingPlugin.sol";
import {QuestPlugin} from "../contracts/plugins/quests/QuestPlugin.sol";

import {OffchainVerifiedTaskPlugin} from "../contracts/plugins/tasks/OffchainVerifiedTaskPlugin.sol";
import "forge-std/console.sol";
//// @notice Tests Basic Deployment attainable

contract MembershipSets is DeploysInit {
    function setUp() public override {
        super.setUp();

        vm.prank(A2);
        aID.mint("AnnaWannabein", "urlll", 1, 9, address(Nova));

        vm.prank(A3);
        aID.mint("AnnaWannabein", "urlll", 1, 9, address(Nova));
    }

    function testSetupAdminAdd() public {
        assertFalse(Nova.isAdmin(A2), "Agent2 Admin by default");
        assertFalse(Nova.isAdmin(A3), "Agent3 Admin by default");

        vm.prank(A4_outsider);
        vm.expectRevert("Not an admin!");
        Nova.addAdmin(A4_outsider);

        vm.prank(A0);
        vm.expectRevert("Not a member");
        Nova.addAdmin(A4_outsider);
        assertFalse(Nova.isAdmin(A4_outsider), "admin somehow");

        vm.prank(A4_outsider);
        aID.mint("AnnaWannabein", "urlll", 1, 9, address(Nova));

        assertTrue(Nova.isMember(A4_outsider), "made member");
        assertFalse(Nova.isAdmin(A4_outsider), "admin somehow2");

        uint256 snapid = vm.snapshot();

        address agentNotMember = address(256000000000256);
        vm.label(agentNotMember, "agent not member");

        address[] memory adminsToAdd = new address[](4);
        address[] memory adminListReturned;

        adminsToAdd[0] = agentNotMember;
        adminsToAdd[1] = A4_outsider;
        adminsToAdd[2] = A2;
        adminsToAdd[3] = A3;

        vm.expectRevert("Not an admin!");
        vm.prank(A3);
        Nova.addAdmins(adminsToAdd);

        vm.prank(A0);
        adminListReturned = Nova.addAdmins(adminsToAdd);

        assertTrue(Nova.isMember(A2), "A2 not member");
        assertTrue(Nova.isMember(A3), "A2 not member");

        assertTrue(Nova.isAdmin(A3), "A3 not added as admin");
        assertTrue(Nova.isAdmin(A2), "A2 not admin");

        assertFalse(Nova.isAdmin(agentNotMember), "not member should skip");
        assertTrue(Nova.isAdmin(A4_outsider), "member but not admin");

        assertTrue(adminListReturned[0] == address(0), "non-member skipped");
        assertTrue(adminListReturned[1] == A4_outsider, "outsider added as admin");
        assertTrue(adminListReturned[2] == A2, "a2 not added as admin");
        assertTrue(adminListReturned[3] == A3, "a2 not added as admin");

        // vm.revertTo(snapid);
    }
}
