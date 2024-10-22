// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "../../BaseTest.sol";
import "../../../contracts/repfi/token/cREPFI.sol";

contract PRepFiTest is BaseTest {
    PRepFi pRepfiToken;

    function setUp() public override {
        super.setUp();
        pRepfiToken = new PRepFi(address(this), address(utilsRegistry));
    }

    function test_deployToken() public {
        pRepfiToken = new PRepFi(address(this), address(utilsRegistry));
        assert(address(pRepfiToken) != address(0));
    }

    function test_tokenName() public view {
        assertEq("Conditional REPFI", pRepfiToken.name(), "Token name does not match");
    }

    function test_tokenSymbol() public view {
        assertEq("cREPFI", pRepfiToken.symbol(), "Token symbol does not match");
    }

    function test_TokenMint() public view {
        assertEq(pRepfiToken.balanceOf(address(this)), 100000000 ether, "Token mint does not match");
    }

    function test_tokenBurnRevert() public {
        vm.expectRevert();
        pRepfiToken.burn(address(this), 100 ether);
    }

    function test_tokenBurnWithRole() public {
        uint256 balanceBefore = pRepfiToken.balanceOf(address(this));
        // grant burner role to this contract
        pRepfiToken.grantRole(pRepfiToken.BURNER_ROLE(), address(this));
        pRepfiToken.burn(address(this), 100 ether);

        uint256 balanceAfter = pRepfiToken.balanceOf(address(this));
        assertEq(balanceBefore - balanceAfter, 100 ether, "tokens were not burned");
    }

    function test_transferNotAllowed() public {
        // try to send tokens to alice
        vm.expectRevert("Transfer not allowed");
        pRepfiToken.transfer(address(alice), 100 ether);
    }

    function test_transferAllowed() public {
        uint256 balanceBefore = pRepfiToken.balanceOf(address(alice));
        // add this contract as a plugin for now
        utilsRegistry.registerPlugin(address(this), "test");
        // try to send tokens to alice
        pRepfiToken.transfer(address(alice), 100 ether);

        uint256 balanceAfter = pRepfiToken.balanceOf(address(alice));

        // remove this contract as a plugin
        utilsRegistry.removePlugin(address(this));
        assertEq(pRepfiToken.balanceOf(address(alice)), 100 ether, "tokens were not transfered");
        assertEq(balanceAfter - balanceBefore, 100 ether, "tokens were not transfered");
    }

    function test_transferFromNotAllowed() public {
        // try to send tokens to alice
        vm.expectRevert("Approve not allowed");
        pRepfiToken.approve(address(alice), 100 ether);
        vm.expectRevert("Transfer not allowed");
        pRepfiToken.transferFrom(address(alice), address(this), 100 ether);
    }

    function test_transferFromAllowed() public {
        uint256 balanceBefore = pRepfiToken.balanceOf(address(this));
        // try to send tokens to plugin
        pRepfiToken.approve(address(reputationMining), 100 ether);

        // reputationMining contract should execute the transferFrom
        vm.prank(address(reputationMining));
        pRepfiToken.transferFrom(address(this), address(reputationMining), 100 ether);
        uint256 balanceAfter = pRepfiToken.balanceOf(address(this));
        assertEq(pRepfiToken.balanceOf(address(reputationMining)), 100 ether, "tokens were not transfered");
        assertEq(balanceBefore - balanceAfter, 100 ether, "tokens were not transfered");
    }
}
