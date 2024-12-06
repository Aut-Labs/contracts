pragma solidity ^0.8.20;

import "../../BaseTest.sol";

contract AutIDJoinHubUnitTest is BaseTest {
    function setUp() public virtual override {
        super.setUp();
    }

    function test_CreateRecordAndJoinHub_Succeeds() public {
        vm.prank(bob);
        autId.createRecordAndJoinHub({
            role: 1,
            commitmentLevel: 3,
            hub: address(hub),
            username: "bob",
            optionalURI: "https://facebook.com/bob"
        });
    }
}