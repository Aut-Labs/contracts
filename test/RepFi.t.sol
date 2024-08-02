// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "./BaseTest.sol";

contract RepFiTest is BaseTest {
    function setUp() public override {
        super.setUp();
    }

    function test_tokenName() public view {
        assertEq("Reputation Finance", repFi.name(), "Token name does not match");
    }
}
