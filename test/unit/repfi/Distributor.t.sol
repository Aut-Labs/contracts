// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "../../BaseTest.sol";

contract DistributorTest is BaseTest {
    RepFi repfiToken;

    address airdrop;
    address partners;

    Distributor initialDistributionContract;
    uint256 salesAmount = 15000000 ether;
    uint256 communityAmount = 7000000 ether;
    uint256 reputationMiningAmount = 36000000 ether;
    uint256 airdropAmount = 4000000 ether;
    uint256 investorsAmount = 10000000 ether;
    uint256 teamAmount = 5000000 ether;
    uint256 partnersAmount = 10000000 ether;
    uint256 ecosystemAmount = 20000000 ether;

    function setUp() public override {
        // let's pretend these addresses are multisigs
        airdrop = makeAddr("airdrop");
        partners = makeAddr("partners");

        super.setUp();
        repfiToken = new RepFi();
        initialDistributionContract = new Distributor(
            repfiToken,
            sales,
            reputationMining,
            airdrop,
            investors,
            team,
            partners,
            ecosystem
        );
    }

    function test_deploy() public {
        initialDistributionContract = new Distributor(
            repfiToken,
            sales,
            reputationMining,
            airdrop,
            investors,
            team,
            partners,
            ecosystem
        );

        assert(address(initialDistributionContract) != address(0));
        assertEq(address(initialDistributionContract.sales()), address(sales));
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
        assertEq(repfiToken.balanceOf(address(sales)), salesAmount);
        assertEq(repfiToken.balanceOf(address(reputationMining)), reputationMiningAmount);
        assertEq(repfiToken.balanceOf(address(airdrop)), airdropAmount);
        assertEq(repfiToken.balanceOf(address(investors)), investorsAmount);
        assertEq(repfiToken.balanceOf(address(team)), teamAmount);
        assertEq(repfiToken.balanceOf(address(partners)), partnersAmount);
        assertEq(repfiToken.balanceOf(address(ecosystem)), ecosystemAmount);
    }
}
