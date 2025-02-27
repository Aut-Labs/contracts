// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../../BaseTest.sol";
import "../../../contracts/repfi/token/AUT.sol";

contract AutTest is BaseTest {
    Aut autToken;

    function setUp() public override {
        super.setUp();
        autToken = new Aut();
    }

    function test_deployToken() public {
        autToken = new Aut();
        assert(address(autToken) != address(0));
    }

    function test_tokenName() public view {
        assertEq("Aut Labs", autToken.name(), "Token name does not match");
    }

    function test_tokenSymbol() public view {
        assertEq("AUT", autToken.symbol(), "Token symbol does not match");
    }

    function testTokenMint() public view {
        assertEq(autToken.balanceOf(address(this)), 100000000 ether, "Token mint does not match");
    }
}
