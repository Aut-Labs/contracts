// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "../../BaseTest.sol";
import "../../../contracts/repfi/token/REPFI.sol";

contract RepFiTest is BaseTest {
    RepFi repfiToken;

    function setUp() public override {
        super.setUp();
        repfiToken = new RepFi();
    }

    function test_deployToken() public {
        repfiToken = new RepFi();
        assert(address(repfiToken) != address(0));
    }

    function test_tokenName() public view {
        assertEq("Aut Labs", repfiToken.name(), "Token name does not match");
    }

    function test_tokenSymbol() public view {
        assertEq("REPFI", repfiToken.symbol(), "Token symbol does not match");
    }

    function testTokenMint() public view {
        assertEq(repfiToken.balanceOf(address(this)), 100000000 ether, "Token mint does not match");
    }
}
