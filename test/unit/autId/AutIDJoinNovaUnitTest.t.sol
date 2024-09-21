pragma solidity ^0.8.20;

import "../../BaseTest.sol";

contract AutIDJoinHubUnitTest is BaseTest {
    function setUp() public virtual override {
        super.setUp();
    }

    function test_CreateRecordAndJoinHub_Succeeds() public {
        vm.prank(alice);
        autId.createRecordAndJoinHub(
            {
                role: 1,
                commitment: 3,
                hub: address(hub),
                username: "alice",
                optionalURI: "ipfs://QmXZnZ"
            }
        );
    }
}