// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../../BaseTest.sol";

contract ReputationMiningTest is BaseTest {
    Aut autToken;
    CAut cAutToken;
    address circular;
    ReputationMining reputationMiningContract;
    uint256 initialCAutBalance = 36000000 ether; // 36 million tokens
    uint256 public constant MAX_MINT_PER_PERIOD = 100 ether;

    function setUp() public override {
        super.setUp();
        autToken = new Aut();
        cAutToken = new CAut(address(this), address(utilsRegistry));
        reputationMiningContract = new ReputationMining();
        circular = makeAddr("circular");

        ReputationMining reputationMiningImplementation = new ReputationMining();
        AutProxy reputationMiningProxy = new AutProxy(
            address(reputationMiningImplementation),
            address(this),
            abi.encodeWithSelector(
                ReputationMining.initialize.selector,
                address(this),
                address(autToken),
                address(cAutToken),
                circular,
                address(peerValue),
                address(autId)
            )
        );
        reputationMiningContract = ReputationMining(address(reputationMiningProxy));

        // set reputationMining as burner for cAutToken
        cAutToken.grantRole(cAutToken.BURNER_ROLE(), address(reputationMiningContract));

        // configure reputationMining as a plugin
        utilsRegistry.registerPlugin(address(reputationMiningContract), "ReputationMiningTest");
        utilsRegistry.registerPlugin(owner, "TestContract");

        // send tokens to reputationMining
        autToken.transfer(address(reputationMiningContract), initialCAutBalance);
        cAutToken.transfer(address(reputationMiningContract), initialCAutBalance);

        vm.label(address(this), "ReputationMiningTest");
    }

    function test_activateMiningNotOwner() public {
        vm.expectRevert();
        vm.prank(alice);
        reputationMiningContract.activateMining();
    }

    function test_activateMining() public {
        uint256 remainingCAutBalance = initialCAutBalance;
        reputationMiningContract.activateMining();
        // update through all the periods (should mine 0 tokens from period 49 onwards)
        for (uint256 i = 1; i < 50; i++) {
            remainingCAutBalance -= reputationMiningContract.getTokensForPeriod(i - 1);
            console.log("remaining balance for period", i, remainingCAutBalance);
            assertEq(reputationMiningContract.currentPeriod(), i);

            uint256 tokensForPeriod = 0;
            if (i <= 24) {
                tokensForPeriod = 500000 ether;
            }

            if (i > 24 && i <= 48) {
                tokensForPeriod = 1000000 ether;
            }

            assertEq(reputationMiningContract.getTokensForPeriod(i), tokensForPeriod, "tokensforperiod error");
            assertEq(reputationMiningContract.tokensLeft(i), tokensForPeriod, "tokensleft currentperiod error");

            if (i > 1) {
                reputationMiningContract.cleanupPeriod(i - 1);
            }

            // check if tokens from previous period are burned
            assertEq(reputationMiningContract.tokensLeft(i - 1), 0, "tokensleft error");
            assertEq(cAutToken.balanceOf(address(reputationMiningContract)), remainingCAutBalance, "balance error");

            skip(28 days);
        }
    }

    function test_claimCAutTokensWithoutAutID() public {
        // start first period
        reputationMiningContract.activateMining();

        uint256 cAutBalanceBefore = cAutToken.balanceOf(address(alice));
        assertEq(cAutBalanceBefore, 0, "initial balance is not zero");

        vm.startPrank(bob);
        vm.expectRevert("not an Aut user");
        reputationMiningContract.claimConditionalToken();
    }

    function test_claimCAutTokens() public {
        // start first period
        reputationMiningContract.activateMining();

        uint256 cAutBalanceBefore = cAutToken.balanceOf(address(alice));
        assertEq(cAutBalanceBefore, 0, "initial balance is not zero");

        vm.startPrank(alice);
        reputationMiningContract.claimConditionalToken();
        uint256 randomPeerValue = randomNumberGenerator.getRandomNumberForAccount(address(alice), 80, 160);
        uint randomGlobalReputation = randomNumberGenerator.getRandomNumberForAccount(address(alice), 80000, 160000);
        vm.stopPrank();

        uint256 tokensForPeriod = 500000 ether;
        uint256 givenAmount = randomPeerValue * (tokensForPeriod / randomGlobalReputation);
        if (givenAmount > MAX_MINT_PER_PERIOD) {
            givenAmount = MAX_MINT_PER_PERIOD;
        }
        console.log("given amount", givenAmount);

        uint256 cAutBalanceAfter = cAutToken.balanceOf(address(alice));

        assertEq(cAutBalanceAfter - cAutBalanceBefore, givenAmount, "received c-aut doesn't match");
        assertLe(
            cAutBalanceAfter,
            reputationMiningContract.MAX_MINT_PER_PERIOD(),
            "distribution exceeded maximum amount"
        );

        skip(28 days);

        uint256 autBalanceBefore = autToken.balanceOf(address(alice));
        uint256 circularAutBalanceBefore = autToken.balanceOf(address(circular));
        assertEq(autBalanceBefore, 0, "initial balance is not zero");

        vm.prank(alice);
        reputationMiningContract.claim();

        uint256 autBalanceAfter = autToken.balanceOf(address(alice));

        // since alice didn't do anything with her c-aut tokens, she won't be rewarded any tokens
        // uint256 calculatedRewards = (cAutBalanceAfter / 60) * 100;
        uint256 calculatedRewards = 0;
        assertEq(autBalanceAfter, 0, "reward amounts do not match");
        // The other 40% should be transferred to the circular contract
        assertEq(
            autToken.balanceOf(address(circular)),
            cAutBalanceAfter - calculatedRewards + circularAutBalanceBefore,
            "circular contract didn't receive appropriate leftover amount"
        );

        // alice claims conditional tokens again
        vm.prank(alice);
        reputationMiningContract.claimConditionalToken();
    }

    function test_claimAutTokens() public {
        // start first period
        reputationMiningContract.activateMining();

        uint256 cAutBalanceBefore = cAutToken.balanceOf(address(alice));
        assertEq(cAutBalanceBefore, 0, "initial balance is not zero");

        vm.startPrank(alice);
        reputationMiningContract.claimConditionalToken();
        uint256 randomPeerValue = randomNumberGenerator.getRandomNumberForAccount(address(alice), 80, 160);
        uint randomGlobalReputation = randomNumberGenerator.getRandomNumberForAccount(address(alice), 80000, 160000);
        vm.stopPrank();

        uint256 tokensForPeriod = 500000 ether;
        uint256 givenAmount = randomPeerValue * (tokensForPeriod / randomGlobalReputation);
        if (givenAmount > MAX_MINT_PER_PERIOD) {
            givenAmount = MAX_MINT_PER_PERIOD;
        }
        console.log("given amount", givenAmount);

        uint256 cAutBalanceAfter = cAutToken.balanceOf(address(alice));

        assertEq(cAutBalanceAfter - cAutBalanceBefore, givenAmount, "received c-aut doesn't match");
        assertLe(
            cAutBalanceAfter,
            reputationMiningContract.MAX_MINT_PER_PERIOD(),
            "distribution exceeded maximum amount"
        );

        // alice stakes 60% c-aut tokens in one of the tools and gets a reward for it after the period ends, we will use this contract as a "tool" for now to simulate this
        uint256 stakedAmount = (givenAmount * 50) / 100;
        console.log("staked amount", stakedAmount);
        vm.prank(alice);
        cAutToken.approve(address(this), stakedAmount);

        // put the tokens in this contract for now
        cAutToken.transferFrom(address(alice), address(this), stakedAmount);

        skip(28 days);

        uint256 autBalanceBefore = autToken.balanceOf(address(alice));
        uint256 circularAutBalanceBefore = autToken.balanceOf(address(circular));
        assertEq(autBalanceBefore, 0, "initial balance is not zero");

        vm.prank(alice);
        reputationMiningContract.claim();

        uint256 autBalanceAfter = autToken.balanceOf(address(alice));

        uint256 participation = (stakedAmount * 100) / givenAmount;
        console.log("participation", participation);
        uint256 earnedTokens = ((givenAmount - stakedAmount) * stakedAmount * 100) / (givenAmount * 60);

        uint256 totalEarned = earnedTokens;
        console.log("earnings", earnedTokens);

        assertEq(autBalanceAfter, earnedTokens, "reward amounts do not match");
        // The other 40% should be transferred to the circular contract
        assertEq(
            autToken.balanceOf(address(circular)),
            cAutBalanceAfter - earnedTokens + circularAutBalanceBefore,
            "circular contract didn't receive appropriate leftover amount"
        );
        uint256 totalBurned = autToken.balanceOf(address(circular));

        // alice claims conditional tokens again
        vm.startPrank(alice);
        reputationMiningContract.claimConditionalToken();
        randomPeerValue = randomNumberGenerator.getRandomNumberForAccount(address(alice), 80, 160);
        randomGlobalReputation = randomNumberGenerator.getRandomNumberForAccount(address(alice), 80000, 160000);
        vm.stopPrank();

        givenAmount = randomPeerValue * (tokensForPeriod / randomGlobalReputation);
        if (givenAmount > MAX_MINT_PER_PERIOD) {
            givenAmount = MAX_MINT_PER_PERIOD;
        }
        console.log("given amount", givenAmount);

        // alice stakes 90% c-aut tokens in one of the tools and gets a reward for it after the period ends, we will use this contract as a "tool" for now to simulate this
        stakedAmount = (givenAmount * 90) / 100;
        console.log("staked amount", stakedAmount);
        vm.prank(alice);
        cAutToken.approve(address(this), stakedAmount);

        // put the tokens in this contract for now
        cAutToken.transferFrom(address(alice), address(this), stakedAmount);

        skip(28 days);

        vm.prank(alice);
        reputationMiningContract.claim();

        autBalanceAfter = autToken.balanceOf(address(alice)) - totalEarned;

        // remaining aut will be distributed 1:1
        earnedTokens = givenAmount - stakedAmount;
        totalEarned += earnedTokens;
        console.log("earnings", earnedTokens);

        assertEq(autBalanceAfter, earnedTokens, "reward amounts do not match");

        totalBurned = autToken.balanceOf(address(circular));

        // alice claims conditional tokens again
        vm.prank(alice);
        reputationMiningContract.claimConditionalToken();
    }

    function test_claimCAutTokensWithPreviousBalance() public {
        // start first period
        reputationMiningContract.activateMining();

        uint256 cAutBalanceBefore = cAutToken.balanceOf(address(alice));
        assertEq(cAutBalanceBefore, 0, "initial balance is not zero");

        vm.startPrank(alice);
        reputationMiningContract.claimConditionalToken();
        uint256 randomPeerValue = randomNumberGenerator.getRandomNumberForAccount(address(alice), 80, 160);
        uint randomGlobalReputation = randomNumberGenerator.getRandomNumberForAccount(address(alice), 80000, 160000);
        vm.stopPrank();

        uint256 tokensForPeriod = 500000 ether;
        uint256 givenAmount = randomPeerValue * (tokensForPeriod / randomGlobalReputation);
        console.log("given amount", givenAmount);

        if (givenAmount > MAX_MINT_PER_PERIOD) {
            givenAmount = MAX_MINT_PER_PERIOD;
        }

        uint256 cAutBalanceAfter = cAutToken.balanceOf(address(alice));

        assertEq(cAutBalanceAfter - cAutBalanceBefore, givenAmount, "received c-aut doesn't match");
        assertLe(
            cAutBalanceAfter,
            reputationMiningContract.MAX_MINT_PER_PERIOD(),
            "distribution exceeded maximum amount"
        );

        skip(28 days);

        cAutBalanceBefore = cAutToken.balanceOf(address(alice));
        assertEq(cAutBalanceBefore, givenAmount, "balance did not persist across periods");

        // alice claims conditional tokens again without claiming her rewards first
        vm.startPrank(alice);
        vm.expectRevert("unclaimed rewards from previous period");
        reputationMiningContract.claimConditionalToken();
        vm.stopPrank();
    }
}
