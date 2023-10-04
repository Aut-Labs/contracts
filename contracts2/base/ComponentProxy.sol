// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.19;

import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";

contract ComponentProxy is BeaconProxy {
    uint256[50] private __gap;
    
    constructor(address beacon, bytes memory data) BeaconProxy(beacon, data) {}
}
