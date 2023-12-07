// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

library UtilsLibrary {
    function packUint128Pair(uint128 left, uint128 right) internal pure returns(uint256 pair) {
        pair = (uint256(left) << 128) | uint256(right);
    }

    function unpackUint128Pair(uint256 pair) internal pure returns(uint128 left, uint128 right) {
        left = uint128(pair >> 128);
        right = uint128(pair << 128);
    }

    function packEntrypoint(address target, bytes4 signature) internal pure returns(bytes24) {
        return bytes24(abi.encodePacked(target, signature));
    }

    function unpackEntrypoint(bytes24 packed) internal pure returns(address target, bytes4 signature) {
        uint256 mask = uint256(bytes32(abi.encodePacked(packed, bytes8(0))));
        target = address(uint160(mask >> 96));
        signature = bytes4(uint32((mask << 160) >> 64));
    }    
}
