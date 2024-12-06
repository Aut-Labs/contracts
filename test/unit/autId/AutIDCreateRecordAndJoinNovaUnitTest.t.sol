pragma solidity ^0.8.20;

import "../../BaseTest.sol";

contract AutIDCreateRecordandJoinHubUnitTest is BaseTest {

    constructor() {}

    function setUp() public virtual override {
        super.setUp();
    }

    function test_createRecordAndJoinHub_succeeds() public {
        
        vm.prank(bob);
        autId.createRecordAndJoinHub({
            role: 1,
            commitmentLevel: 1,
            hub: address(hub),
            username: "bob",
            optionalURI: "https://facebook.com/bob"
        });

        // check autId.mintedAt()

        // check state change from _createRecord()

        // check state change from _joinHub
    }

    function test_createRecordAndJoinHub_InvalidHub_reverts() public {
        // TODO
    }

    function test_createRecordAndJoinHub_InvalidCommitment_reverts() public {
        // TODO
    }

    function test_createRecordAndJoinHub_CanNotJoinHub_reverts() public {
        // TODO
    }

    function test_createRecordAndJoinHub_MinCommitmentNotReached_reverts() public {
        // TODO
    }

}