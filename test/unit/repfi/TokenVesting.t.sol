// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "../../BaseTest.sol";
import "../../../contracts/repfi/token/REPFI.sol";
import "../../../contracts/repfi/vesting/TokenVesting.sol";

contract TokenVestingTest is BaseTest {
    RepFi repfiToken;
    TokenVesting tokenvesting;
    uint startTime;

    uint256 totalAmount = 100000000 ether;
    uint256 amountAlice = 300000 ether;
    uint256 amountBob = 100000 ether;
    uint256 duration = 6 * 28 days;
    uint256 releaseInterval = 28 days;
    bool revocable = true;

    function setUp() public override {
        super.setUp();
        repfiToken = new RepFi();
        tokenvesting = new TokenVesting(address(repfiToken), address(this), duration, releaseInterval, revocable);
        repfiToken.transfer(address(tokenvesting), totalAmount);

        startTime = block.timestamp;

        // create token vesting for bob and alice
        address[] memory recipients = new address[](2);
        recipients[0] = address(alice);
        recipients[1] = address(bob);

        uint256[] memory allocations = new uint256[](2);
        allocations[0] = 75;
        allocations[1] = 25;
        tokenvesting.addRecipients(
            recipients,
            allocations,
            block.timestamp, // start now
            0, // no cliff
            amountAlice + amountBob
        );

        assertEq(tokenvesting.getVestingSchedulesTotalAmount(), amountAlice + amountBob);
    }

    function test_deployment() public {
        TokenVesting tokenvestingTest = new TokenVesting(
            address(repfiToken),
            address(this),
            duration,
            releaseInterval,
            revocable
        );
        assert(address(tokenvestingTest) != address(0));
        assertEq(tokenvestingTest.getToken(), address(repfiToken));
    }

    function test_verifyVestingSchedule() public {
        uint256 numberOfVestingsForAlice = tokenvesting.getVestingSchedulesCountByBeneficiary(address(alice));
        assertEq(numberOfVestingsForAlice, 1, "vesting not initialized");

        bytes32 vestingAtIndexForAlice = tokenvesting.getVestingIdAtIndex(0);
        assert(vestingAtIndexForAlice != "0x");

        TokenVesting.VestingSchedule memory vestingAlice = tokenvesting.getVestingScheduleByAddressAndIndex(
            address(alice),
            0
        );
        assertEq(vestingAlice.beneficiary, address(alice), "beneficiary does not match");
        assertEq(vestingAlice.start, startTime, "start time does not match");
        // assertEq(vestingAlice.cliff, startTime, "cliff does not match");
        assertEq(tokenvesting.duration(), 6 * 28 days, "duration does not match");
        assertEq(tokenvesting.releaseInterval(), 28 days, "period does not match");
        assertEq(tokenvesting.revocable(), true, "revocable does not match");
        assertEq(vestingAlice.amountTotal, amountAlice, "total amount does not match");
        assertEq(vestingAlice.released, 0, "released amount does not match");
        assertEq(vestingAlice.revoked, false, "revoked does not match");

        assertEq(
            vestingAlice.start,
            tokenvesting.getLastVestingScheduleForHolder(address(alice)).start,
            "vesting schedules don't match"
        );

        uint256 numberOfVestingsForBob = tokenvesting.getVestingSchedulesCountByBeneficiary(address(bob));
        assertEq(numberOfVestingsForBob, 1, "vesting not initialized");

        bytes32 vestingAtIndexForBob = tokenvesting.getVestingIdAtIndex(1);
        assert(vestingAtIndexForBob != "0x");

        TokenVesting.VestingSchedule memory vestingBob = tokenvesting.getVestingScheduleByAddressAndIndex(
            address(bob),
            0
        );
        assertEq(vestingBob.beneficiary, address(bob), "beneficiary does not match");
        assertEq(vestingBob.start, startTime, "start time does not match");
        // assertEq(vestingBob.cliff, startTime + 56 days, "cliff does not match");
        assertEq(vestingBob.amountTotal, amountBob, "total amount does not match");
        assertEq(vestingBob.released, 0, "released amount does not match");
        assertEq(vestingBob.revoked, false, "revoked does not match");

        assertEq(
            vestingBob.start,
            tokenvesting.getLastVestingScheduleForHolder(address(bob)).start,
            "vesting schedules don't match"
        );

        vm.expectRevert("TokenVesting: index out of bounds");
        tokenvesting.getVestingIdAtIndex(2);
    }

    function test_addMoreThanTotalBalance() public {
        vm.expectRevert("TokenVesting: cannot create vesting schedule because not sufficient tokens");
        tokenvesting.createVestingSchedule(
            address(bob),
            startTime, // start immediately
            56 days, // cliff after 56 days
            100000000 ether // 100.000.000 tokens
        );
    }

    function test_revertIfNotOwner() public {
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, address(alice)));
        vm.prank(alice);
        tokenvesting.createVestingSchedule(
            address(alice),
            startTime, // start immediately
            0, // no cliff
            amountAlice // 200.000 tokens
        );
    }

    function test_revertIfAmountIsZero() public {
        vm.expectRevert("TokenVesting: amount must be > 0");
        tokenvesting.createVestingSchedule(
            address(alice),
            startTime, // start immediately
            0, // no cliff
            0 // 0 tokens
        );
    }

    function test_revertIfCliffIsGreaterThanDuration() public {
        vm.expectRevert("TokenVesting: duration must be >= cliff");
        tokenvesting.createVestingSchedule(
            address(alice),
            startTime, // start immediately
            7 * 28 days, // 7 periods of 28 days
            amountAlice // 200.000 tokens
        );
    }

    function test_revokeVestingSchedule() public {
        bytes32 vestingAtIndexForBob = tokenvesting.getVestingIdAtIndex(1);
        tokenvesting.revoke(vestingAtIndexForBob);

        vm.startPrank(bob);

        vm.expectRevert();
        tokenvesting.release(vestingAtIndexForBob, 1);

        vm.expectRevert();
        tokenvesting.computeReleasableAmount(vestingAtIndexForBob);

        vm.stopPrank();
    }

    function test_revokeVestingScheduleRevertNotOwner() public {
        bytes32 vestingAtIndexForBob = tokenvesting.getVestingIdAtIndex(1);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, address(alice)));
        vm.prank(alice);
        tokenvesting.revoke(vestingAtIndexForBob);
    }

    // function test_revokeVestingScheduleRevertNonRevocableSchedule() public {
    //     bytes32 vestingAtIndexForAlice = tokenvesting.getVestingIdAtIndex(0);
    //     vm.expectRevert("TokenVesting: vesting is not revocable");
    //     tokenvesting.revoke(vestingAtIndexForAlice);
    // }

    function test_revokeVestingScheduleAlreadyRevoked() public {
        bytes32 vestingAtIndexForBob = tokenvesting.getVestingIdAtIndex(1);
        tokenvesting.revoke(vestingAtIndexForBob);

        vm.expectRevert();
        tokenvesting.revoke(vestingAtIndexForBob);
    }

    // function test_revokeVestingScheduleAfter3Periods() public {
    //     uint256 newtime = block.timestamp + (3 * 28 days);
    //     vm.warp(newtime);

    //     bytes32 vestingAtIndexForBob = tokenvesting.getVestingIdAtIndex(1);
    //     tokenvesting.revoke(vestingAtIndexForBob);

    //     uint256 estimatedVesting = amountBob / 6;
    //     uint256 actualVested = repfiToken.balanceOf(address(bob));

    //     assertEq(estimatedVesting, actualVested, "vested amounts do not match");
    // }

    function test_vestingEnded() public {
        uint256 newtime = block.timestamp + (6 * 28 days);
        vm.warp(newtime);

        bytes32 vestingScheduleId = tokenvesting.getVestingIdAtIndex(0);

        uint256 releaseableAmount = tokenvesting.computeReleasableAmount(vestingScheduleId);
        assertEq(releaseableAmount, amountAlice);

        vm.prank(alice);
        tokenvesting.release(vestingScheduleId, amountAlice);

        uint256 actualVested = repfiToken.balanceOf(address(alice));

        assertEq(amountAlice, actualVested, "vested amounts do not match");
    }

    function test_releaseVestingForOtherUser() public {
        uint256 newtime = block.timestamp + (6 * 28 days);
        vm.warp(newtime);

        bytes32 vestingScheduleId = tokenvesting.getVestingIdAtIndex(0);

        vm.expectRevert("TokenVesting: only beneficiary and owner can release vested tokens");
        vm.prank(bob);
        tokenvesting.release(vestingScheduleId, amountAlice);
    }

    function test_releaseVestingAmountTooHigh() public {
        uint256 newtime = block.timestamp + (6 * 28 days);
        vm.warp(newtime);

        bytes32 vestingScheduleId = tokenvesting.getVestingIdAtIndex(0);

        vm.expectRevert("TokenVesting: cannot release tokens, not enough vested tokens");
        vm.prank(alice);
        tokenvesting.release(vestingScheduleId, amountAlice + 1);
    }

    function test_OwnerCanWithdrawRemainingBalance() public {
        uint256 withdrawableAmount = tokenvesting.getWithdrawableAmount();
        assertEq(withdrawableAmount, totalAmount - amountAlice - amountBob);

        tokenvesting.withdraw(withdrawableAmount);

        uint256 ownerbalance = repfiToken.balanceOf(address(this));
        assertEq(ownerbalance, withdrawableAmount);
        assertEq(repfiToken.balanceOf(address(tokenvesting)), totalAmount - withdrawableAmount);
    }

    function test_UserCannotWithdrawRemainingBalance() public {
        uint256 withdrawableAmount = tokenvesting.getWithdrawableAmount();
        assertEq(withdrawableAmount, totalAmount - amountAlice - amountBob);

        vm.expectRevert();
        vm.prank(alice);
        tokenvesting.withdraw(withdrawableAmount);
    }

    function test_OwnerCannotWithdrawMoreThanRemainingBalance() public {
        uint256 withdrawableAmount = tokenvesting.getWithdrawableAmount();

        vm.expectRevert("TokenVesting: not enough withdrawable funds");
        tokenvesting.withdraw(withdrawableAmount + 1);
    }
}
