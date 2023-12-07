// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;


library CoreLibrary {
    struct TInteraction {
        uint128 interacitonSpecId;
        uint128 timestamp;
        address sender;
        bytes payload;
    }

    struct TEvmCompatibleTxPayload {
        uint16 chainId;
        address to;
        uint64 gas;
        uint64 nonce;
        uint256 blockNumber;
        uint256 value;
        bytes data;
    }
}
