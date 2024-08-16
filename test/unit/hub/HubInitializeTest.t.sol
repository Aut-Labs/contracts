pragma solidity ^0.8.20;

import "../../BaseTest.sol";

contract HubInitializeTest is BaseTest {
    function setUp() public virtual override {
        /// @dev needed to invoke setUp of BaseTest
        super.setUp();
    }

    function test_Initialize_succeeds() public {
        // TODO: validate all state of initialize
    }

    function test_Initialize_twice_reverts() public {
        // TODO
    }
}