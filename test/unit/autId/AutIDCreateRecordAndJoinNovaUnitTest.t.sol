pragma solidity ^0.8.20;

import "../../BaseTest.sol";

contract AutIDCreateRecordandJoinNovaUnitTest is BaseTest {

    constructor() {}

    function setUp() public virtual override {
        super.setUp();
    }

    function test_createRecordAndJoinNova_succeeds() public {
        // TODO

        // check autId.mintedAt()

        // check state change from _createRecord()

        // check state change from _joinNova
    }

    function test_createRecordAndJoinNova_InvalidNova_reverts() public {
        // TODO
    }

    function test_createRecordAndJoinNova_InvalidCommitment_reverts() public {
        // TODO
    }

    function test_createRecordAndJoinNova_CanNotJoinNova_reverts() public {
        // TODO
    }

    function test_createRecordAndJoinNova_MinCommitmentNotReached_reverts() public {
        // TODO
    }

}