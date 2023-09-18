// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

library DeploymentAddresses {
    function autIDAddr(uint256 chainID) public pure returns (address) {
        if (chainID == 5) return 0xF8f34cfBF160EF9AEC1F92f521FFcC057Bc9a5ED;
        if (chainID == 80001) return 0x22F55A832AA88493Abd6dA5366eB609FF6483314;
        // Add more conditions for other chain IDs as needed.
    }

    function novaFactoryAddr(uint256 chainID) public pure returns (address) {
        if (chainID == 5) return 0x78b41e5ae04b633CC92D28C968A93D98F4f62B0b;
        if (chainID == 80001) return 0x8FfD9e16576B631Ae537AaAaA64d2255D0F90991;
        // Add more conditions for other chain IDs as needed.
    }

    function moduleRegistryAddr(uint256 chainID) public pure returns (address) {
        if (chainID == 5) return 0x43103084D6D02b4F793A1EBE85854b4e0E8D18A2;
        if (chainID == 80001) return 0xD74C7d03AF2B04BAb0b3cd6cE5339E126A44a4f5;
        // Add more conditions for other chain IDs as needed.
    }

    function pluginRegistryAddr(uint256 chainID) public pure returns (address) {
        if (chainID == 5) return 0xd15d575021a1547183b865196f6d60Bf6a909432;
        if (chainID == 80001) return 0x39F88D86e608AcF50FA268e5c487b1b0c9798351;
        // Add more conditions for other chain IDs as needed.
    }

    function novaRegistryAddr(uint256 chainID) public pure returns (address) {
        if (chainID == 5) return 0xd52D1A77B4fF12d2f683Db20Aa9e437C5889E935;
        if (chainID == 80001) return 0x5bb9686501bAb529A8911d4B23768046b7218BeC;
        // Add more conditions for other chain IDs as needed.
    }

    function interactionAddr(uint256 chainID) public pure returns (address) {
        if (chainID == 5) return 0x2fe82fa4b6B5Dcaa19A8B8b36a6AF0e2b0958a49;
        if (chainID == 80001) return 0x4430012CCAC4640845fE8818232C15bC8BaEB08f;
        // Add more conditions for other chain IDs as needed.
    }

    function localReputationAddr(uint256 chainID) public pure returns (address) {
        if (chainID == 5) return 0x99d553F8Cb3F2d3C0cC5ccc7Edb05E054B216663;
        if (chainID == 80001) return 0x54d4Cc964e8e6d865bAaBbD1586ee1A43465F696;
        // Add more conditions for other chain IDs as needed.
    }
}
