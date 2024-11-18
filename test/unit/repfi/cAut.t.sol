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
    }

    function test_tokenName() public view {
        assertEq("Conditional AUT", cAutToken.name(), "Token name does not match");
    }

    function test_tokenSymbol() public view {
        assertEq("cAUT", cAutToken.symbol(), "Token symbol does not match");
    }

    function test_TokenMint() public view {
        assertEq(cAutToken.balanceOf(address(this)), 100000000 ether, "Token mint does not match");
    }

    function test_tokenBurnRevert() public {
        vm.expectRevert();
        cAutToken.burn(address(this), 100 ether);
    }

    function test_tokenBurnWithRole() public {
        uint256 balanceBefore = cAutToken.balanceOf(address(this));
        // grant burner role to this contract
        cAutToken.grantRole(cAutToken.BURNER_ROLE(), address(this));
        cAutToken.burn(address(this), 100 ether);

        uint256 balanceAfter = cAutToken.balanceOf(address(this));
        assertEq(balanceBefore - balanceAfter, 100 ether, "tokens were not burned");
    }

    function test_transferNotAllowed() public {
        // send tokens to Bob
        vm.prank(owner);
        cAutToken.transfer(address(bob), 100 ether);

        // try to send tokens to alice
        vm.expectRevert("Transfer not allowed");
        vm.prank(bob);
        cAutToken.transfer(address(alice), 100 ether);
    }

    function test_transferAllowed() public {
        uint256 balanceBefore = cAutToken.balanceOf(address(alice));
        // try to send tokens to alice
        cAutToken.transfer(address(alice), 100 ether);

        uint256 balanceAfter = cAutToken.balanceOf(address(alice));

        // remove this contract as a plugin
        utilsRegistry.removePlugin(address(this));
        assertEq(cAutToken.balanceOf(address(alice)), 100 ether, "tokens were not transfered");
        assertEq(balanceAfter - balanceBefore, 100 ether, "tokens were not transfered");
    }

    function test_transferFromNotAllowed() public {
        // send tokens to Bob
        vm.prank(owner);
        cAutToken.transfer(address(bob), 100 ether);

        vm.startPrank(bob);
        // try to send tokens to alice
        vm.expectRevert("Approve not allowed");
        cAutToken.approve(address(alice), 100 ether);
        vm.expectRevert("Transfer not allowed");
        cAutToken.transferFrom(address(bob), address(alice), 100 ether);
        vm.stopPrank();
    }

    function test_transferFromAllowed() public {
        uint256 balanceBefore = cAutToken.balanceOf(address(this));
        // try to send tokens to plugin
        cAutToken.approve(address(reputationMining), 100 ether);

        // reputationMining contract should execute the transferFrom
        vm.prank(address(reputationMining));
        cAutToken.transferFrom(address(this), address(reputationMining), 100 ether);
        uint256 balanceAfter = cAutToken.balanceOf(address(this));
        assertEq(cAutToken.balanceOf(address(reputationMining)), 100 ether, "tokens were not transfered");
        assertEq(balanceBefore - balanceAfter, 100 ether, "tokens were not transfered");
    }
}
