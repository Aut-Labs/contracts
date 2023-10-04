// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.19;

import "@openzeppelin/contracts/utils/StorageSlot.sol";


contract Upgradeable {
    bytes32 private constant _IMPLEMENTATION_SLOT =
        bytes32(uint256(keccak256("id.aut.os.proxy.implementation")) - 1);

    // 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50
    bytes32 internal constant _BEACON_SLOT = bytes32(uint256(keccak256("eip1967.proxy.beacon")));

    uint256[50] private __gap;

    function _getImplementationSlot() internal pure returns (StorageSlot.AddressSlot storage) {
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT);
    }

    function _getBeaconSlot() internal pure returns (StorageSlot.AddressSlot storage) {
        return StorageSlot.getAddressSlot(_BEACON_SLOT);
    }
}
