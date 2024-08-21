//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract PeriodUtils {
    
    uint32 public immutable period0Start;
    uint32 public immutable initPeriodId;

    // struct PeriodUtilsStorage {
    //     uint32 period0Start;
    //     uint32 initPeriodId;
    // }

    // // keccak256(abi.encode(uint256(keccak256("aut.storage.PeriodUtils")) - 1))
    // bytes32 private constant PeriodUtilsStorageLocation = 0xbb30d154f2784c70f43e6e03f8bf8078407501460b7616d04bf445b7588c175a;

    constructor(uint32 _period0Start, uint32 _initPeriodId) {
        period0Start = _period0Start;
        initPeriodId = _initPeriodId;
    }

    function currentPeriodId() public view returns (uint32) {
        return TimeLibrary.periodId({period0Start: period0Start, timestamp: uint32(block.timestamp)});
    }

    function getPeriodId(uint32 timestamp) public view returns (uint32) {
        return TimeLibrary.periodId({period0Start: period0Start, timestamp: timestamp});
    }
}