// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {StorageSlot} from "@openzeppelin/contracts/utils/StorageSlot.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

abstract contract HubUpgradeable is Initializable {
    // bytes32(uint256(keccak256("eip1967.proxy.beacon")))
    bytes32 private constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    // bytes32(uint256(keccak256("aut.hub.implementation")) - 1)
    bytes32 private constant _IMPLEMENTATION_SLOT = 0xcd0912f71386cff9878081e1c75800d1c9ded2720c4f877d0b3f713d15203c60;

    function implementation() external view returns (address) {
        return _getImplementationSlot().value;
    }

    function beacon() external view returns (address) {
        return _getBeaconSlot().value;
    }

    function _getImplementationSlot() internal pure returns (StorageSlot.AddressSlot storage) {
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT);
    }

    function _getBeaconSlot() internal pure returns (StorageSlot.AddressSlot storage) {
        return StorageSlot.getAddressSlot(_BEACON_SLOT);
    }
}
