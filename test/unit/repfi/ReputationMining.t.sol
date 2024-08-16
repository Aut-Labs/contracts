// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "../../BaseTest.sol";

contract ReputationMiningTest is BaseTest {
    RepFi repfiToken;
    PRepFi pRepfiToken;
    address circular;
    ReputationMining reputationMiningContract;
    uint256 initialPRepFiBalance = 36000000 ether; // 36 million tokens

    function setUp() public override {
        super.setUp();
        repfiToken = new RepFi();
        pRepfiToken = new PRepFi(address(this), address(repFiRegistry));
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
                address(pRepfiToken),
                circular,
                address(randomNumberGenerator)
            )
        );
        reputationMiningContract = ReputationMining(address(reputationMiningProxy));

        // set reputationMining as burner for pRepFiToken
        pRepfiToken.grantRole(pRepfiToken.BURNER_ROLE(), address(reputationMiningContract));

        // configure reputationMining as a plugin
        repFiRegistry.registerPlugin(address(reputationMiningContract), "ReputationMiningTest");
        repFiRegistry.registerPlugin(address(this), "test contract");

        // send tokens to reputationMining
        repfiToken.transfer(address(reputationMiningContract), initialPRepFiBalance);
        pRepfiToken.transfer(address(reputationMiningContract), initialPRepFiBalance);

        vm.label(address(this), "ReputationMiningTest");
    }

    function test_updatePeriodNotOwner() public {
        vm.expectRevert();
        vm.prank(alice);
        reputationMiningContract.updatePeriod();
    }

    function test_updatePeriod() public {
        uint256 remainingPRepFiBalance = initialPRepFiBalance;
        // update through all the periods (should mine 0 tokens from period 49 onwards)
        for (uint256 i = 1; i < 50; i++) {
            remainingPRepFiBalance -= reputationMiningContract.getTokensForPeriod(i - 1);
            console.log("remaining balance for period", i, remainingPRepFiBalance);
            reputationMiningContract.updatePeriod();
            assertEq(reputationMiningContract.period(), i);
            assertEq(reputationMiningContract.lastPeriodChange(), block.timestamp);

            uint256 tokensForPeriod = 0;
            if (i <= 24) {
                tokensForPeriod = 500000 ether;
            }

            if (i > 24 && i <= 48) {
                tokensForPeriod = 1000000 ether;
            }

            assertEq(reputationMiningContract.getTokensForPeriod(i), tokensForPeriod);
            assertEq(reputationMiningContract.tokensLeft(i), tokensForPeriod);

            // check if tokens from previous period are burned
            assertEq(reputationMiningContract.tokensLeft(i - 1), 0);
            assertEq(pRepfiToken.balanceOf(address(reputationMiningContract)), remainingPRepFiBalance);

            skip(28 days);
        }
    }

    function test_updatePeriodTooEarly() public {
        reputationMiningContract.updatePeriod();

        skip(27 days);

        vm.expectRevert("previous period has not ended yet");
        reputationMiningContract.updatePeriod();
    }

    function test_claimPRepFiTokens() public {
        // start first period
        reputationMiningContract.updatePeriod();

        uint256 pRepFiBalanceBefore = pRepfiToken.balanceOf(address(alice));
        assertEq(pRepFiBalanceBefore, 0, "initial balance is not zero");

        vm.startPrank(alice);
        reputationMiningContract.claimUtilityToken();
        uint256 randomPeerValue = randomNumberGenerator.getRandomNumberForAccount(address(alice), 80, 160);
        vm.stopPrank();

        uint256 givenAmount = randomPeerValue;

        uint256 pRepFiBalanceAfter = pRepfiToken.balanceOf(address(alice));

        assertEq(pRepFiBalanceAfter - pRepFiBalanceBefore, givenAmount, "received pRepFi doesn't match");
        assertLe(
            pRepFiBalanceAfter,
            reputationMiningContract.MAX_MINT_PER_PERIOD(),
            "distribution exceeded maximum amount"
        );

        skip(28 days);

        // admin updates the period
        reputationMiningContract.updatePeriod();

        uint256 repfiBalanceBefore = repfiToken.balanceOf(address(alice));
        assertEq(repfiBalanceBefore, 0, "initial balance is not zero");

        vm.prank(alice);
        reputationMiningContract.claim();

        uint256 repfiBalanceAfter = repfiToken.balanceOf(address(alice));

        // since alice didn't do anything with her pRepFi tokens, she won't be rewarded any tokens
        // uint256 calculatedRewards = (pRepFiBalanceAfter / 60) * 100;
        uint256 calculatedRewards = 0;
        assertEq(repfiBalanceAfter, 0, "reward amounts do not match");
        // The other 40% should be transferred to the circular contract
        assertEq(
            repfiToken.balanceOf(address(circular)),
            pRepFiBalanceAfter - calculatedRewards,
            "circular contract didn't receive appropriate leftover amount"
        );

        // alice claims utility tokens again
        vm.prank(alice);
        reputationMiningContract.claimUtilityToken();
    }

    function test_claimPRepFiTokensWithPreviousBalance() public {
        // start first period
        reputationMiningContract.updatePeriod();

        uint256 pRepFiBalanceBefore = pRepfiToken.balanceOf(address(alice));
        assertEq(pRepFiBalanceBefore, 0, "initial balance is not zero");

        vm.startPrank(alice);
        reputationMiningContract.claimUtilityToken();
        uint256 randomPeerValue = randomNumberGenerator.getRandomNumberForAccount(address(alice), 80, 160);
        vm.stopPrank();

        uint256 givenAmount = randomPeerValue;

        uint256 pRepFiBalanceAfter = pRepfiToken.balanceOf(address(alice));

        assertEq(pRepFiBalanceAfter - pRepFiBalanceBefore, givenAmount, "received pRepFi doesn't match");
        assertLe(
            pRepFiBalanceAfter,
            reputationMiningContract.MAX_MINT_PER_PERIOD(),
            "distribution exceeded maximum amount"
        );

        skip(28 days);

        // admin updates the period
        reputationMiningContract.updatePeriod();

        pRepFiBalanceBefore = pRepfiToken.balanceOf(address(alice));
        assertEq(pRepFiBalanceBefore, givenAmount, "balance did not persist across periods");

        // alice claims utility tokens again without claiming her rewards first
        vm.startPrank(alice);
        reputationMiningContract.claimUtilityToken();
        randomPeerValue = randomNumberGenerator.getRandomNumberForAccount(address(alice), 80, 160);
        vm.stopPrank();

        givenAmount = randomPeerValue;

        pRepFiBalanceAfter = pRepfiToken.balanceOf(address(alice));

        // alice should have a total of 1000 pRepFi tokens again
        assertEq(pRepFiBalanceAfter, givenAmount, "previously allocated pRepFi was not burned");
        assertLe(
            pRepFiBalanceAfter,
            reputationMiningContract.MAX_MINT_PER_PERIOD(),
            "distribution exceeded maximum amount"
        );
    }
}
