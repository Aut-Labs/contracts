// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../../BaseTest.sol";
import "../../../contracts/repfi/token/cAUT.sol";

contract CAutTest is BaseTest {
    CAut cAutToken;

    function setUp() public override {
        super.setUp();
        cAutToken = new CAut(owner, address(utilsRegistry));
        utilsRegistry.registerPlugin(owner, "TestContract");
    }

    function test_deployToken() public {
        cAutToken = new CAut(owner, address(utilsRegistry));
        assert(address(cAutToken) != address(0));
        cAutToken.mintInitialSupply(address(this));
    }

    function test_TokenMint() public view {
        assertEq(cAutToken.balanceOf(address(this), 1), 100000000 ether, "Token mint does not match");
        // @todo check all the IDs like in reputation mining tests
    }

    function test_tokenBurnRevert() public {
        vm.expectRevert();
        cAutToken.burn(address(this), 1, 100 ether);
    }

    function test_tokenBurnWithRole() public {
        uint256 balanceBefore = cAutToken.balanceOf(address(this), 1);
        // grant burner role to this contract
        cAutToken.grantRole(cAutToken.BURNER_ROLE(), address(this));
        cAutToken.burn(address(this), 1, 100 ether);

        uint256 balanceAfter = cAutToken.balanceOf(address(this), 1);
        assertEq(balanceBefore - balanceAfter, 100 ether, "tokens were not burned");
    }

    function test_transferNotAllowed() public {
        // send tokens to Bob
        vm.prank(owner);
        cAutToken.safeTransferFrom(address(this), address(bob), 1, 100 ether, "");

        // try to send tokens to alice
        vm.expectRevert("Transfer not allowed");
        vm.prank(bob);
        cAutToken.safeTransferFrom(address(bob), address(alice), 1, 100 ether, "");
    }

    function test_transferAllowed() public {
        uint256 balanceBefore = cAutToken.balanceOf(address(alice), 1);
        // try to send tokens to alice
        cAutToken.safeTransferFrom(address(this), address(alice), 1, 100 ether, "");

        uint256 balanceAfter = cAutToken.balanceOf(address(alice), 1);

        // remove this contract as a plugin
        utilsRegistry.removePlugin(address(this));
        assertEq(cAutToken.balanceOf(address(alice), 1), 100 ether, "tokens were not transfered");
        assertEq(balanceAfter - balanceBefore, 100 ether, "tokens were not transfered");
    }

    function test_transferFromNotAllowed() public {
        // send tokens to Bob
        vm.prank(owner);
        cAutToken.safeTransferFrom(address(owner), address(bob), 1, 100 ether, "");

        vm.startPrank(bob);
        // try to send tokens to alice
        vm.expectRevert("Approve not allowed");
        cAutToken.setApprovalForAll(address(alice), true);
        vm.expectRevert("Transfer not allowed");
        cAutToken.safeTransferFrom(address(bob), address(alice), 1, 100 ether, "");
        vm.stopPrank();
    }

    function test_transferFromAllowed() public {
        uint256 balanceBefore = cAutToken.balanceOf(address(this), 1);
        // try to send tokens to plugin
        cAutToken.setApprovalForAll(address(reputationMining), true);

        // reputationMining contract should execute the transferFrom
        vm.prank(address(reputationMining));
        cAutToken.safeTransferFrom(address(this), address(reputationMining), 1, 100 ether, "");
        uint256 balanceAfter = cAutToken.balanceOf(address(this), 1);
        assertEq(cAutToken.balanceOf(address(reputationMining), 1), 100 ether, "tokens were not transfered");
        assertEq(balanceBefore - balanceAfter, 100 ether, "tokens were not transfered");
    }
}
