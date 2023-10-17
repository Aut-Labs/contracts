// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.19;

import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import "@openzeppelin/contracts/utils/StorageSlot.sol";

contract ComponentProxy is BeaconProxy {
    bytes32 private constant _NOVA_SLOT = bytes32("id.aut.os.proxy.nova");

    constructor(address beacon, bytes memory data, address nova) BeaconProxy(beacon, data) {
        StorageSlot.getAddressSlot(_NOVA_SLOT).value = nova;
    }
}
