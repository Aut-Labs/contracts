// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "../../BaseTest.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Staking, Pausable} from "../../../contracts/repfi/staking/Staking.sol";

contract StakingTest is BaseTest {
    Staking public staking;

    uint256 _duration = 10 weeks;
    uint256 _rate = 150;
    uint256 _penalty = 50;
    uint256 _allocation = 10000 ether;
    address user1 = vm.addr(1);

    function setUp() public override {
        super.setUp();
        staking = new Staking(address(aut), address(owner));
    }

    // owner functions

    function test_deployment() public {
        Staking newStaking = new Staking(address(aut), address(owner));
        assert(address(newStaking) != address(0));
        assertEq(newStaking.getBaseAsset(), address(aut), "tokens do not match");
    }

    function test_createSchedule() public {
        uint256 scheduleCounterBefore = staking.scheduleCounter();
        console.log("scheduleCounterBefore", scheduleCounterBefore);

        // vm.expectEmit(address(staking));
        staking.createStakingSchedule(_duration, _rate, _penalty, _allocation);

        uint256 scheduleCounterAfter = staking.scheduleCounter();
        console.log("scheduleCounterAfter", scheduleCounterAfter);

        assert(scheduleCounterAfter > scheduleCounterBefore);

        Staking.StakingSchedule memory schedule = staking.getStakingScheduleDetails(1);

        //     struct StakingSchedule {
        //     uint256 duration;
        //     uint256 rate;
        //     uint256 penalty;
        //     uint256 allocation;
        //     StakeDistribution balance;
        //     StakeStatus status;
        // }

        assertEq(schedule.duration, _duration, "duration does not match");
        assertEq(schedule.rate, _rate, "rate does not match");
        assertEq(schedule.penalty, _penalty, "penalty does not match");
        assertEq(schedule.allocation, _allocation, "allocation does not match");
        // @todo balance
        assertEq(uint256(schedule.status), 0, "status does not match");
    }

    function test_failCreateSchedule() public {
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, address(user1)));
        staking.createStakingSchedule(_duration, _rate, _penalty, _allocation);

        vm.expectRevert((Staking.InvalidDurationSettings.selector));
        staking.createStakingSchedule(0, _rate, _penalty, _allocation);

        vm.expectRevert((Staking.InvalidDurationSettings.selector));
        staking.createStakingSchedule(60 * 60 - 1, _rate, _penalty, _allocation);

        vm.expectRevert((Staking.InvalidRateSettings.selector));
        staking.createStakingSchedule(_duration, 0, _penalty, _allocation);

        vm.expectRevert((Staking.InvalidRateSettings.selector));
        staking.createStakingSchedule(_duration, 1000, _penalty, _allocation);

        vm.expectRevert((Staking.InvalidPenaltySettings.selector));
        staking.createStakingSchedule(_duration, _rate, 401, _allocation);

        vm.expectRevert((Staking.TokenAmountIsZero.selector));
        staking.createStakingSchedule(_duration, _rate, _penalty, 0);

        staking.pause();
        vm.expectRevert((Pausable.EnforcedPause.selector));
        staking.createStakingSchedule(_duration, _rate, _penalty, _allocation);

        staking.unpause();
    }

    function test_startStakingSchedule() public {
        staking.createStakingSchedule(_duration, _rate, _penalty, _allocation);
        staking.startStakingSchedule(1);

        assertEq(staking.getActiveScheduleIds().length, 1, "active schedule count does not match");
    }

    function test_failStartStakingSchedule() public {
        vm.expectRevert((Staking.InvalidScheduleID.selector));
        staking.startStakingSchedule(1);

        staking.createStakingSchedule(_duration, _rate, _penalty, _allocation);

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, address(user1)));
        staking.startStakingSchedule(1);

        staking.startStakingSchedule(1);

        vm.expectRevert((Staking.ScheduleAlreadyStarted.selector));
        staking.startStakingSchedule(1);

        staking.pause();
        vm.expectRevert((Pausable.EnforcedPause.selector));
        staking.startStakingSchedule(1);
    }

    function test_completeStakingSchedule() public {
        staking.createStakingSchedule(_duration, _rate, _penalty, _allocation);
        staking.startStakingSchedule(1);
        staking.completeStakingSchedule(1);
    }

    function test_failCompleteStakingSchedule() public {
        staking.createStakingSchedule(_duration, _rate, _penalty, _allocation);

        vm.expectRevert((Staking.ScheduleCanNotBeCompleted.selector));
        staking.completeStakingSchedule(1);

        staking.startStakingSchedule(1);
        staking.completeStakingSchedule(1);

        vm.expectRevert((Staking.ScheduleCanNotBeCompleted.selector));
        staking.completeStakingSchedule(1);

        staking.pause();
        vm.expectRevert((Pausable.EnforcedPause.selector));
        staking.completeStakingSchedule(1);
    }

    function test_updateMinimumThresholdForDuration() public {
        staking.updateMinimumThresholdForDuration(60 * 70);

        vm.expectRevert((Staking.InvalidDurationSettings.selector));
        staking.updateMinimumThresholdForDuration(0);

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, address(user1)));
        staking.updateMinimumThresholdForDuration(60 * 70);

        staking.pause();
        vm.expectRevert((Pausable.EnforcedPause.selector));
        staking.updateMinimumThresholdForDuration(60 * 70);
    }

    function test_updateMaximumThresholdForRates() public {
        staking.updateMaximumThresholdForRates(399);

        vm.expectRevert((Staking.InvalidRateSettings.selector));
        staking.updateMaximumThresholdForRates(0);

        vm.expectRevert((Staking.InvalidRateSettings.selector));
        staking.updateMaximumThresholdForRates(1001);

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, address(user1)));
        staking.updateMaximumThresholdForRates(399);

        staking.pause();
        vm.expectRevert((Pausable.EnforcedPause.selector));
        staking.updateMaximumThresholdForRates(399);
    }

    function test_updateMinimumStakeAmount() public {
        staking.updateMinimumStakeAmount(200);

        vm.expectRevert((Staking.TokenAmountIsZero.selector));
        staking.updateMinimumStakeAmount(0);

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, address(user1)));
        staking.updateMinimumStakeAmount(200);

        staking.pause();
        vm.expectRevert((Pausable.EnforcedPause.selector));
        staking.updateMinimumStakeAmount(200);
    }

    function test_rescueTokens() public {
        vm.expectRevert((Staking.TokenAmountIsZero.selector));
        staking.rescueTokens(address(aut), user1, 0);

        vm.expectRevert((Staking.InvalidContractInteraction.selector));
        staking.rescueTokens(address(0), user1, 1000 ether);

        vm.expectRevert((Staking.InvalidContractInteraction.selector));
        staking.rescueTokens(address(user1), user1, 1000 ether);

        vm.expectRevert((Staking.InvalidAddressInteraction.selector));
        staking.rescueTokens(address(aut), address(0), 1000 ether);

        // insufficient funds
        vm.expectRevert();
        staking.rescueTokens(address(aut), address(owner), 1000 ether);

        deal(address(aut), address(staking), 1000 ether);
        staking.rescueTokens(address(aut), address(owner), 1000 ether);
    }

    // Staking tests

    function test_stake() public {
        staking.createStakingSchedule(_duration, _rate, _penalty, _allocation);
        staking.startStakingSchedule(1);

        // give the user some tokens
        deal(address(aut), user1, 1000 ether);

        vm.startPrank(user1);
        // @todo add allowance specific error
        vm.expectRevert();
        staking.stake(1000 ether, 1);

        vm.expectRevert((Staking.ExceedsAllocation.selector));
        staking.stake(_allocation + 1, 1);

        aut.approve(address(staking), 1000 ether);
        staking.stake(1000 ether, 1);

        //     struct Agreements {
        //     uint256 amount;
        //     uint256 stakingScheduleId;
        //     uint256 expectedReward;
        //     uint256 totalClaimed;
        //     uint256 lastClaim;
        //     uint256 penalization;
        //     uint256 refundAmount;
        //     bool unstaked;
        //     bool claimed;
        // }

        Staking.Agreements memory agreement = staking.getAgreementDetails(address(user1), 1, 1);
        assertEq(agreement.amount, 1000 ether, "amounts do not match");
        assertEq(agreement.stakingScheduleId, 1, "stakingScheduleId does not match");
        assertEq(agreement.expectedReward, 1000 ether + (1000 ether * _rate) / 1000, "rewardAmounts do not match");
        assertEq(agreement.totalClaimed, 0, "totalClaimed does not match");
        assertEq(agreement.lastClaim, block.timestamp, "claim dates do not match");
        assertEq(agreement.penalization, 0, "penalisation does not match");
        assertEq(agreement.refundAmount, 0, "penalisation does not match");
        assertFalse(agreement.unstaked);
        assertFalse(agreement.claimed);

        uint256[] memory userAgreements = staking.getUserAgreementIdsForSchedule(user1, 1);
        assertEq(userAgreements.length, 1, "user agreement count does not match");

        uint256[] memory activeUserAgreements = staking.getUserActiveAgreementIdsForSchedule(user1, 1);
        assertEq(activeUserAgreements.length, 1, "user agreement count does not match");

        assertEq(staking.getUserTotalStakedForSchedule(user1, 1), 1000 ether, "staking amounts do not match");
        assertEq(staking.getTotalStakedTokens(), 1000 ether, "staking amounts do not match");
        assertEq(staking.getTotalStakersCount(), 1, "staker amounts do not match");

        vm.stopPrank();
    }

    function test_unstake() public {
        staking.createStakingSchedule(_duration, _rate, _penalty, _allocation);
        staking.startStakingSchedule(1);

        // give the user some tokens
        deal(address(aut), user1, 1000 ether);

        vm.startPrank(user1);

        aut.approve(address(staking), 1000 ether);
        staking.stake(1000 ether, 1);

        staking.unstake(1, 1);
        console.log("user1 balance", aut.balanceOf(user1));
        assertEq(aut.balanceOf(user1), 1000 ether - (1000 ether * _penalty) / 1000);

        skip(_duration);

        vm.expectRevert((Staking.StakeAlreadyCompleted.selector));
        staking.unstake(1, 1);

        vm.stopPrank();
    }

    function test_completeStake() public {
        staking.createStakingSchedule(_duration, _rate, _penalty, _allocation);
        staking.startStakingSchedule(1);

        // give the user some tokens
        deal(address(aut), user1, 1000 ether);

        vm.startPrank(user1);

        aut.approve(address(staking), 1000 ether);
        staking.stake(1000 ether, 1);

        vm.expectRevert((Staking.StakeDurationNotExceeded.selector));
        staking.completeStake(1, 1);

        skip(_duration);

        // @todo check Staking.InsufficientTokenBalance.selector specific error
        vm.expectRevert();
        staking.completeStake(1, 1);

        deal(address(aut), address(staking), 1000 ether + (1000 ether * _rate) / 1000);

        staking.completeStake(1, 1);
        console.log("user1 balance", aut.balanceOf(user1));
        assertEq(aut.balanceOf(user1), 1000 ether + (1000 ether * _rate) / 1000);

        // @todo check Staking.AlreadyClaimed.selector specific error
        vm.expectRevert();
        staking.completeStake(1, 1);

        vm.stopPrank();
    }
}
