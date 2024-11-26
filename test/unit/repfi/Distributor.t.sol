// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../../BaseTest.sol";

contract DistributorTest is BaseTest {
    Aut autToken;

    address airdrop;
    address listing;

    Distributor initialDistributionContract;
    uint256 saleAmount = 7000000 ether;
    uint256 reputationMiningAmount = 36000000 ether;
    uint256 airdropAmount = 4000000 ether;
    uint256 founderInvestorsAmount = 10000000 ether;
    uint256 earlyContributorsAmount = 5000000 ether;
    uint256 listingAmount = 8000000 ether;
    uint256 treasuryAmount = 25000000 ether;
    uint256 advisorAmount = 5000000 ether;

    function setUp() public override {
        // let's pretend these addresses are multisigs
        airdrop = makeAddr("airdrop");
        listing = makeAddr("listing");

        super.setUp();
        autToken = new Aut();
        initialDistributionContract = new Distributor(
            autToken,
            sale,
            address(reputationMining),
            airdrop,
            address(founderInvestors),
            address(earlyContributors),
            listing,
            treasury,
            address(kolsAdvisors)
        );
    }

    function test_deploy() public {
        initialDistributionContract = new Distributor(
            autToken,
            sale,
            address(reputationMining),
            airdrop,
            address(founderInvestors),
            address(earlyContributors),
            listing,
            treasury,
            address(kolsAdvisors)
        );

        assert(address(initialDistributionContract) != address(0));
        assertEq(address(initialDistributionContract.sale()), address(sale));
        assertEq(address(initialDistributionContract.reputationMining()), address(reputationMining));
        assertEq(address(initialDistributionContract.airdrop()), address(airdrop));
        assertEq(address(initialDistributionContract.founderInvestors()), address(founderInvestors));
        assertEq(address(initialDistributionContract.earlyContributors()), address(earlyContributors));
        assertEq(address(initialDistributionContract.listing()), address(listing));
        assertEq(address(initialDistributionContract.treasury()), address(treasury));
        assertEq(address(initialDistributionContract.kolsAdvisors()), address(kolsAdvisors));
    }

    function test_DistributeRevertNotOwner() public {
        autToken.transfer(address(initialDistributionContract), 100000000 ether);
        vm.expectRevert("only owner can distribute");
        vm.prank(alice);
        initialDistributionContract.distribute();
    }

    function test_DistributeRevertNotEnoughTokens() public {
        vm.expectRevert("not enough Aut in the contract for distribution");
        initialDistributionContract.distribute();
    }

    function test_Distribute() public {
        autToken.transfer(address(initialDistributionContract), 100000000 ether);
        initialDistributionContract.distribute();

        assertEq(autToken.balanceOf(address(initialDistributionContract)), 0);
        assertEq(autToken.balanceOf(address(sale)), saleAmount);
        assertEq(autToken.balanceOf(address(reputationMining)), reputationMiningAmount);
        assertEq(autToken.balanceOf(address(airdrop)), airdropAmount);
        assertEq(autToken.balanceOf(address(founderInvestors)), founderInvestorsAmount);
        assertEq(autToken.balanceOf(address(earlyContributors)), earlyContributorsAmount);
        assertEq(autToken.balanceOf(address(listing)), listingAmount);
        assertEq(autToken.balanceOf(address(treasury)), treasuryAmount);
        assertEq(autToken.balanceOf(address(kolsAdvisors)), advisorAmount);
    }
}
