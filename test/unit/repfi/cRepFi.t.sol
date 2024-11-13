// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "../../BaseTest.sol";
import "../../../contracts/repfi/token/cREPFI.sol";

contract CRepFiTest is BaseTest {
    CRepFi cRepFiToken;

    function setUp() public override {
        super.setUp();
        cRepFiToken = new CRepFi(owner, address(utilsRegistry));
        utilsRegistry.registerPlugin(owner, "TestContract");
    }

    function test_deployToken() public {
        cRepFiToken = new CRepFi(owner, address(utilsRegistry));
        assert(address(cRepFiToken) != address(0));
    }

    function test_tokenName() public view {
        assertEq("Conditional REPFI", cRepFiToken.name(), "Token name does not match");
    }

    function test_tokenSymbol() public view {
        assertEq("cREPFI", cRepFiToken.symbol(), "Token symbol does not match");
    }

    function test_TokenMint() public view {
        assertEq(cRepFiToken.balanceOf(address(this)), 100000000 ether, "Token mint does not match");
    }

    function test_tokenBurnRevert() public {
        vm.expectRevert();
        cRepFiToken.burn(address(this), 100 ether);
    }

    function test_tokenBurnWithRole() public {
        uint256 balanceBefore = cRepFiToken.balanceOf(address(this));
        // grant burner role to this contract
        cRepFiToken.grantRole(cRepFiToken.BURNER_ROLE(), address(this));
        cRepFiToken.burn(address(this), 100 ether);

        uint256 balanceAfter = cRepFiToken.balanceOf(address(this));
        assertEq(balanceBefore - balanceAfter, 100 ether, "tokens were not burned");
    }

    function test_transferNotAllowed() public {
        // send tokens to Bob
        vm.prank(owner);
        cRepFiToken.transfer(address(bob), 100 ether);

        // try to send tokens to alice
        vm.expectRevert("Transfer not allowed");
        vm.prank(bob);
        cRepFiToken.transfer(address(alice), 100 ether);
    }

    function test_transferAllowed() public {
        uint256 balanceBefore = cRepFiToken.balanceOf(address(alice));
        // try to send tokens to alice
        cRepFiToken.transfer(address(alice), 100 ether);

        uint256 balanceAfter = cRepFiToken.balanceOf(address(alice));

        // remove this contract as a plugin
        utilsRegistry.removePlugin(address(this));
        assertEq(cRepFiToken.balanceOf(address(alice)), 100 ether, "tokens were not transfered");
        assertEq(balanceAfter - balanceBefore, 100 ether, "tokens were not transfered");
    }

    function test_transferFromNotAllowed() public {
        // send tokens to Bob
        vm.prank(owner);
        cRepFiToken.transfer(address(bob), 100 ether);

        vm.startPrank(bob);
        // try to send tokens to alice
        vm.expectRevert("Approve not allowed");
        cRepFiToken.approve(address(alice), 100 ether);
        vm.expectRevert("Transfer not allowed");
        cRepFiToken.transferFrom(address(bob), address(alice), 100 ether);
        vm.stopPrank();
    }

    function test_transferFromAllowed() public {
        uint256 balanceBefore = cRepFiToken.balanceOf(address(this));
        // try to send tokens to plugin
        cRepFiToken.approve(address(reputationMining), 100 ether);

        // reputationMining contract should execute the transferFrom
        vm.prank(address(reputationMining));
        cRepFiToken.transferFrom(address(this), address(reputationMining), 100 ether);
        uint256 balanceAfter = cRepFiToken.balanceOf(address(this));
        assertEq(cRepFiToken.balanceOf(address(reputationMining)), 100 ether, "tokens were not transfered");
        assertEq(balanceBefore - balanceAfter, 100 ether, "tokens were not transfered");
    }
}
