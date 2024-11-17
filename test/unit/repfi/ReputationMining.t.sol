// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../../BaseTest.sol";

contract ReputationMiningTest is BaseTest {
    RepFi repfiToken;
    CRepFi cRepFiToken;
    address circular;
    ReputationMining reputationMiningContract;
    uint256 initialCRepFiBalance = 36000000 ether; // 36 million tokens
    uint256 public constant MAX_MINT_PER_PERIOD = 100 ether;

    function setUp() public override {
        super.setUp();
        repfiToken = new RepFi();
        cRepFiToken = new CRepFi(address(this), address(utilsRegistry));
        reputationMiningContract = new ReputationMining();
        circular = makeAddr("circular");

        ReputationMining reputationMiningImplementation = new ReputationMining();
        AutProxy reputationMiningProxy = new AutProxy(
            address(reputationMiningImplementation),
            address(this),
            abi.encodeWithSelector(
                ReputationMining.initialize.selector,
                address(this),
                address(repfiToken),
                address(cRepFiToken),
                circular,
                address(randomNumberGenerator)
            )
        );
        reputationMiningContract = ReputationMining(address(reputationMiningProxy));

        // set reputationMining as burner for cRepFiToken
        cRepFiToken.grantRole(cRepFiToken.BURNER_ROLE(), address(reputationMiningContract));

        // configure reputationMining as a plugin
        utilsRegistry.registerPlugin(address(reputationMiningContract), "ReputationMiningTest");
        utilsRegistry.registerPlugin(owner, "TestContract");

        // send tokens to reputationMining
        repfiToken.transfer(address(reputationMiningContract), initialCRepFiBalance);
        cRepFiToken.transfer(address(reputationMiningContract), initialCRepFiBalance);

        vm.label(address(this), "ReputationMiningTest");
    }

    function test_activateMiningNotOwner() public {
        vm.expectRevert();
        vm.prank(alice);
        reputationMiningContract.activateMining();
    }

    function test_activateMining() public {
        uint256 remainingCRepFiBalance = initialCRepFiBalance;
        reputationMiningContract.activateMining();
        // update through all the periods (should mine 0 tokens from period 49 onwards)
        for (uint256 i = 1; i < 50; i++) {
            remainingCRepFiBalance -= reputationMiningContract.getTokensForPeriod(i - 1);
            console.log("remaining balance for period", i, remainingCRepFiBalance);
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
            assertEq(cRepFiToken.balanceOf(address(reputationMiningContract)), remainingCRepFiBalance, "balance error");

            skip(28 days);
        }
    }

    function test_claimCRepFiTokens() public {
        // start first period
        reputationMiningContract.activateMining();

        uint256 cRepFiBalanceBefore = cRepFiToken.balanceOf(address(alice));
        assertEq(cRepFiBalanceBefore, 0, "initial balance is not zero");

        vm.startPrank(alice);
        reputationMiningContract.claimUtilityToken();
        uint256 randomPeerValue = randomNumberGenerator.getRandomNumberForAccount(address(alice), 80, 160);
        uint randomGlobalReputation = randomNumberGenerator.getRandomNumberForAccount(address(alice), 80000, 160000);
        vm.stopPrank();

        uint256 tokensForPeriod = 500000 ether;
        uint256 givenAmount = randomPeerValue * (tokensForPeriod / randomGlobalReputation);
        if (givenAmount > MAX_MINT_PER_PERIOD) {
            givenAmount = MAX_MINT_PER_PERIOD;
        }
        console.log("given amount", givenAmount);

        uint256 cRepFiBalanceAfter = cRepFiToken.balanceOf(address(alice));

        assertEq(cRepFiBalanceAfter - cRepFiBalanceBefore, givenAmount, "received cRepFi doesn't match");
        assertLe(
            cRepFiBalanceAfter,
            reputationMiningContract.MAX_MINT_PER_PERIOD(),
            "distribution exceeded maximum amount"
        );

        skip(28 days);

        uint256 repfiBalanceBefore = repfiToken.balanceOf(address(alice));
        uint256 circularRepfiBalanceBefore = repfiToken.balanceOf(address(circular));
        assertEq(repfiBalanceBefore, 0, "initial balance is not zero");

        vm.prank(alice);
        reputationMiningContract.claim();

        uint256 repfiBalanceAfter = repfiToken.balanceOf(address(alice));

        // since alice didn't do anything with her cRepFi tokens, she won't be rewarded any tokens
        // uint256 calculatedRewards = (cRepFiBalanceAfter / 60) * 100;
        uint256 calculatedRewards = 0;
        assertEq(repfiBalanceAfter, 0, "reward amounts do not match");
        // The other 40% should be transferred to the circular contract
        assertEq(
            repfiToken.balanceOf(address(circular)),
            cRepFiBalanceAfter - calculatedRewards + circularRepfiBalanceBefore,
            "circular contract didn't receive appropriate leftover amount"
        );

        // alice claims utility tokens again
        vm.prank(alice);
        reputationMiningContract.claimUtilityToken();
    }

    function test_claimRepFiTokens() public {
        // start first period
        reputationMiningContract.activateMining();

        uint256 cRepFiBalanceBefore = cRepFiToken.balanceOf(address(alice));
        assertEq(cRepFiBalanceBefore, 0, "initial balance is not zero");

        vm.startPrank(alice);
        reputationMiningContract.claimUtilityToken();
        uint256 randomPeerValue = randomNumberGenerator.getRandomNumberForAccount(address(alice), 80, 160);
        uint randomGlobalReputation = randomNumberGenerator.getRandomNumberForAccount(address(alice), 80000, 160000);
        vm.stopPrank();

        uint256 tokensForPeriod = 500000 ether;
        uint256 givenAmount = randomPeerValue * (tokensForPeriod / randomGlobalReputation);
        if (givenAmount > MAX_MINT_PER_PERIOD) {
            givenAmount = MAX_MINT_PER_PERIOD;
        }
        console.log("given amount", givenAmount);

        uint256 cRepFiBalanceAfter = cRepFiToken.balanceOf(address(alice));

        assertEq(cRepFiBalanceAfter - cRepFiBalanceBefore, givenAmount, "received cRepFi doesn't match");
        assertLe(
            cRepFiBalanceAfter,
            reputationMiningContract.MAX_MINT_PER_PERIOD(),
            "distribution exceeded maximum amount"
        );

        // alice stakes 60% cRepFi tokens in one of the tools and gets a reward for it after the period ends, we will use this contract as a "tool" for now to simulate this
        uint256 stakedAmount = (givenAmount * 50) / 100;
        console.log("staked amount", stakedAmount);
        vm.prank(alice);
        cRepFiToken.approve(address(this), stakedAmount);

        // put the tokens in this contract for now
        cRepFiToken.transferFrom(address(alice), address(this), stakedAmount);

        skip(28 days);

        uint256 repfiBalanceBefore = repfiToken.balanceOf(address(alice));
        uint256 circularRepfiBalanceBefore = repfiToken.balanceOf(address(circular));
        assertEq(repfiBalanceBefore, 0, "initial balance is not zero");

        vm.prank(alice);
        reputationMiningContract.claim();

        uint256 repfiBalanceAfter = repfiToken.balanceOf(address(alice));

        uint256 participation = (stakedAmount * 100) / givenAmount;
        console.log("participation", participation);
        uint256 earnedTokens = ((givenAmount - stakedAmount) * stakedAmount * 100) / (givenAmount * 60);

        uint256 totalEarned = earnedTokens;
        console.log("earnings", earnedTokens);

        assertEq(repfiBalanceAfter, earnedTokens, "reward amounts do not match");
        // The other 40% should be transferred to the circular contract
        assertEq(
            repfiToken.balanceOf(address(circular)),
            cRepFiBalanceAfter - earnedTokens + circularRepfiBalanceBefore,
            "circular contract didn't receive appropriate leftover amount"
        );
        uint256 totalBurned = repfiToken.balanceOf(address(circular));

        // alice claims utility tokens again
        vm.startPrank(alice);
        reputationMiningContract.claimUtilityToken();
        randomPeerValue = randomNumberGenerator.getRandomNumberForAccount(address(alice), 80, 160);
        randomGlobalReputation = randomNumberGenerator.getRandomNumberForAccount(address(alice), 80000, 160000);
        vm.stopPrank();

        givenAmount = randomPeerValue * (tokensForPeriod / randomGlobalReputation);
        if (givenAmount > MAX_MINT_PER_PERIOD) {
            givenAmount = MAX_MINT_PER_PERIOD;
        }
        console.log("given amount", givenAmount);

        // alice stakes 90% cRepFi tokens in one of the tools and gets a reward for it after the period ends, we will use this contract as a "tool" for now to simulate this
        stakedAmount = (givenAmount * 90) / 100;
        console.log("staked amount", stakedAmount);
        vm.prank(alice);
        cRepFiToken.approve(address(this), stakedAmount);

        // put the tokens in this contract for now
        cRepFiToken.transferFrom(address(alice), address(this), stakedAmount);

        skip(28 days);

        vm.prank(alice);
        reputationMiningContract.claim();

        repfiBalanceAfter = repfiToken.balanceOf(address(alice)) - totalEarned;

        // remaining repfi will be distributed 1:1
        earnedTokens = givenAmount - stakedAmount;
        totalEarned += earnedTokens;
        console.log("earnings", earnedTokens);

        assertEq(repfiBalanceAfter, earnedTokens, "reward amounts do not match");

        totalBurned = repfiToken.balanceOf(address(circular));

        // alice claims utility tokens again
        vm.prank(alice);
        reputationMiningContract.claimUtilityToken();
    }

    function test_claimCRepFiTokensWithPreviousBalance() public {
        // start first period
        reputationMiningContract.activateMining();

        uint256 cRepFiBalanceBefore = cRepFiToken.balanceOf(address(alice));
        assertEq(cRepFiBalanceBefore, 0, "initial balance is not zero");

        vm.startPrank(alice);
        reputationMiningContract.claimUtilityToken();
        uint256 randomPeerValue = randomNumberGenerator.getRandomNumberForAccount(address(alice), 80, 160);
        uint randomGlobalReputation = randomNumberGenerator.getRandomNumberForAccount(address(alice), 80000, 160000);
        vm.stopPrank();

        uint256 tokensForPeriod = 500000 ether;
        uint256 givenAmount = randomPeerValue * (tokensForPeriod / randomGlobalReputation);
        console.log("given amount", givenAmount);

        if (givenAmount > MAX_MINT_PER_PERIOD) {
            givenAmount = MAX_MINT_PER_PERIOD;
        }

        uint256 cRepFiBalanceAfter = cRepFiToken.balanceOf(address(alice));

        assertEq(cRepFiBalanceAfter - cRepFiBalanceBefore, givenAmount, "received cRepFi doesn't match");
        assertLe(
            cRepFiBalanceAfter,
            reputationMiningContract.MAX_MINT_PER_PERIOD(),
            "distribution exceeded maximum amount"
        );

        skip(28 days);

        cRepFiBalanceBefore = cRepFiToken.balanceOf(address(alice));
        assertEq(cRepFiBalanceBefore, givenAmount, "balance did not persist across periods");

        // alice claims utility tokens again without claiming her rewards first
        vm.startPrank(alice);
        vm.expectRevert("unclaimed rewards from previous period");
        reputationMiningContract.claimUtilityToken();
        vm.stopPrank();
    }
}
