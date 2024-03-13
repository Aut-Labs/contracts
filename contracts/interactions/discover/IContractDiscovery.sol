// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IContractDiscovery {
    function contractIdForName(string memory contractName) external pure returns(bytes32);
    function getContractAddress(bytes32 contractId) external view returns(address);
}
