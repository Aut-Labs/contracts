// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "../../BaseTest.sol";

contract InitialDistributionTest is BaseTest {
    RepFi repfiToken;

    address airdrop;
    address partners;
    address ecosystem;

    InitialDistribution initialDistributionContract;
    uint256 privatesaleAmount = 8000000 ether;
    uint256 communityAmount = 7000000 ether;
    uint256 reputationMiningAmount = 36000000 ether;
    uint256 airdropAmount = 4000000 ether;
    uint256 investorsAmount = 10000000 ether;
    uint256 teamAmount = 5000000 ether;
    uint256 partnersAmount = 15000000 ether;
    uint256 ecosystemAmount = 15000000 ether;

    function setUp() public override {
        // let's pretend these addresses are multisigs
        airdrop = makeAddr("airdrop");
        partners = makeAddr("partners");
        ecosystem = makeAddr("ecosystem");

        super.setUp();
        repfiToken = new RepFi();
        initialDistributionContract = new InitialDistribution(
            repfiToken,
            privateSale,
            community,
            reputationMining,
            airdrop,
            investors,
            team,
            partners,
            ecosystem
        );
    }

    function test_deploy() public {
        initialDistributionContract = new InitialDistribution(
            repfiToken,
            privateSale,
            community,
            reputationMining,
            airdrop,
            investors,
            team,
            partners,
            ecosystem
        );

        assert(address(initialDistributionContract) != address(0));
        assertEq(address(initialDistributionContract.privateSale()), address(privateSale));
        assertEq(address(initialDistributionContract.community()), address(community));
        assertEq(address(initialDistributionContract.reputationMining()), address(reputationMining));
        assertEq(address(initialDistributionContract.airdrop()), address(airdrop));
        assertEq(address(initialDistributionContract.investors()), address(investors));
        assertEq(address(initialDistributionContract.team()), address(team));
        assertEq(address(initialDistributionContract.partners()), address(partners));
        assertEq(address(initialDistributionContract.ecosystem()), address(ecosystem));
    }

    function test_DistributeRevertNotOwner() public {
        repfiToken.transfer(address(initialDistributionContract), 100000000 ether);
        vm.expectRevert("only owner can distribute");
        vm.prank(alice);
        initialDistributionContract.distribute();
    }

    function test_DistributeRevertNotEnoughTokens() public {
        vm.expectRevert("not enough RepFI in the contract for distribution");
        initialDistributionContract.distribute();
    }

    function test_Distribute() public {
        repfiToken.transfer(address(initialDistributionContract), 100000000 ether);
        initialDistributionContract.distribute();

        assertEq(repfiToken.balanceOf(address(initialDistributionContract)), 0);
        assertEq(repfiToken.balanceOf(address(privateSale)), privatesaleAmount);
        assertEq(repfiToken.balanceOf(address(community)), communityAmount);
        assertEq(repfiToken.balanceOf(address(reputationMining)), reputationMiningAmount);
        assertEq(repfiToken.balanceOf(address(airdrop)), airdropAmount);
        assertEq(repfiToken.balanceOf(address(investors)), investorsAmount);
        assertEq(repfiToken.balanceOf(address(team)), teamAmount);
        assertEq(repfiToken.balanceOf(address(partners)), partnersAmount);
        assertEq(repfiToken.balanceOf(address(ecosystem)), ecosystemAmount);
    }
}
